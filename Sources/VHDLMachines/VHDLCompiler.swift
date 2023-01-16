//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO
import VHDLParsing

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// A struct that compiles a VHDL machine into a VHDL source file (vhd). The source file is located
/// within the machine folder at <machine_name>.vhd.
public struct VHDLCompiler {

    /// Helper struct for defining transitions.
    private struct VHDLTransition {

        /// The source state.
        var source: VariableName

        /// The target state.
        var target: VariableName

        /// The condition that causes the transition to fire.
        var condition: String

        /// Create a new VHDL transition.
        /// - Parameters:
        ///   - source: The source state.
        ///   - target: The target state.
        ///   - condition: The condition that causes the transition to fire.
        init(source: VariableName, target: VariableName, condition: String) {
            self.source = source
            self.target = target
            self.condition = condition
        }

        /// Convert a transition into this struct.
        /// - Parameters:
        ///   - transition: The transition to convert.
        ///   - machine: The machine that the transition belongs to.
        init(transition: Transition, machine: Machine) {
            self.init(
                source: machine.states[transition.source].name,
                target: machine.states[transition.target].name,
                condition: transition.condition
            )
        }

    }

    /// A file helper.
    private let helper = FileHelpers()

    /// The suspension command VHDL constants for a machine.
    private var suspensionCommands: String {
        foldWithNewLine(
            components: [
                "constant COMMAND_NULL: std_logic_vector(1 downto 0) := \"00\";",
                "constant COMMAND_RESTART: std_logic_vector(1 downto 0) := \"01\";",
                "constant COMMAND_SUSPEND: std_logic_vector(1 downto 0) := \"10\";",
                "constant COMMAND_RESUME: std_logic_vector(1 downto 0) := \"11\";"
            ],
            initial: "-- Suspension Commands",
            indentation: 1
        )
    }

    /// Create a VHDL compiler.
    public init() {}

    /// Compile a machine into a VHDL source file within the machine folder specified by the machines path.
    /// - Parameter machine: The machine to compile.
    /// - Returns: Whether the compilation was successful.
    public func compile(_ machine: Machine) -> Bool {
        let format = generateVHDLFile(machine)
        let fileName = "\(machine.name).vhd"
        if !helper.directoryExists(machine.path.path) {
            let manager = FileManager()
            guard (try? manager.createDirectory(
                at: machine.path, withIntermediateDirectories: true
            )) != nil else {
                return false
            }
        }
        return helper.createFile(fileName, inDirectory: machine.path, withContents: format + "\n") != nil
    }

    /// Generate the VHDL source code for a machine.
    /// - Parameter machine: The machine to compile.
    /// - Returns: The VHDL source code.
    func generateVHDLFile(_ machine: Machine) -> String {
        foldWithNewLine(
            components: [
                createIncludes(includes: machine.includes) + "\n",
                createEntity(machine: machine) + "\n\n",
                createArhictecure(machine: machine)
            ],
            initial: ""
        )
    }

    /// The internal states used in the VHDL machine.
    /// - Parameter machine: The machine to generate the VHDL source file for.
    /// - Returns: The internal states.
    private func internalStates(machine: Machine) -> String {
        let suspensibleComponents = [
            "constant ReadSnapshot: std_logic_vector(3 downto 0) := \"0000\";",
            "constant OnSuspend: std_logic_vector(3 downto 0) := \"0001\";",
            "constant OnResume: std_logic_vector(3 downto 0) := \"0010\";",
            "constant OnEntry: std_logic_vector(3 downto 0) := \"0011\";",
            "constant NoOnEntry: std_logic_vector(3 downto 0) := \"0100\";",
            "constant CheckTransition: std_logic_vector(3 downto 0) := \"0101\";",
            "constant OnExit: std_logic_vector(3 downto 0) := \"0110\";",
            "constant Internal: std_logic_vector(3 downto 0) := \"0111\";",
            "constant WriteSnapshot: std_logic_vector(3 downto 0) := \"1000\";",
            "signal internalState: std_logic_vector(3 downto 0) := ReadSnapshot;"
        ]
        let defaultComponents = [
            "constant ReadSnapshot: std_logic_vector(2 downto 0) := \"000\";",
            "constant OnEntry: std_logic_vector(2 downto 0) := \"001\";",
            "constant NoOnEntry: std_logic_vector(2 downto 0) := \"010\";",
            "constant CheckTransition: std_logic_vector(2 downto 0) := \"011\";",
            "constant OnExit: std_logic_vector(2 downto 0) := \"100\";",
            "constant Internal: std_logic_vector(2 downto 0) := \"101\";",
            "constant WriteSnapshot: std_logic_vector(2 downto 0) := \"110\";",
            "signal internalState: std_logic_vector(2 downto 0) := ReadSnapshot;"
        ]
        return foldWithNewLine(
            components: machine.suspendedState == nil ? defaultComponents : suspensibleComponents,
            initial: "-- Internal State Representation Bits",
            indentation: 1
        )
    }

    /// The logic that reads the parameters when a machine is restarted.
    /// - Parameter machine: The machine to generate the VHDL source file for.
    /// - Returns: The parameter logic.
    private func readParameterLogic(machine: Machine) -> [String] {
        ["    if (command = COMMAND_RESTART) then"] +
            machine.parameterSignals.map { "    \($0.name) <= \(toParameter(name: $0.name));" } +
        ["end if;"]
    }

    /// The logic that writes the returnables when a machine is suspended.
    /// - Parameter machine: The machine to generate the VHDL source file for.
    /// - Returns: The returnable logic.
    private func writeOutputLogic(machine: Machine) -> [String] {
        if !machine.isParameterised {
            return []
        }
        guard let index = machine.suspendedState else {
            return []
        }
        let returnables = machine.returnableSignals.map {
            "    \(toReturnable(name: $0.name)) <= \($0.name);"
        }
        return ["if (currentState = \(toStateName(name: machine.states[index].name)))"] +
                returnables + ["end if;"]
    }

    // swiftlint:disable function_body_length

    /// Create the command logic for a parameterised machine. This logic determines whether the parameters
    /// need to be snapshot or an OnResume needs to execute.
    /// - Parameters:
    ///   - initialState: The initial state of the machine.
    ///   - suspendedState: The suspended state of the machine.
    ///   - indentation: The indentation level.
    ///   - parameters: The parameters of the machine.
    /// - Returns: The command logic.
    private func commandLogic(
        initialState: String, suspendedState: String, indentation: Int, parameters: [String]
    ) -> String {
        foldWithNewLineExceptFirst(
            components: parameters + [
                "if (command = COMMAND_RESTART and currentState /= \(initialState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    currentState <= \(initialState);",
                        "suspended <= '0';",
                        "suspendedFrom <= \(initialState);",
                        "targetState <= \(initialState);",
                        "if (previousRinglet = \(suspendedState)) then",
                        foldWithNewLine(
                            components: ["internalState <= onResume;"], initial: "", indentation: 1
                        ),
                        "elsif (previousRinglet = \(initialState)) then",
                        foldWithNewLine(
                            components: ["internalState <= NoOnEntry;"], initial: "", indentation: 1
                        ),
                        "else",
                        foldWithNewLine(
                            components: ["internalState <= onEntry;"], initial: "", indentation: 1
                        ),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (command = COMMAND_RESUME and currentState = \(suspendedState) and suspendedFrom /= " +
                    "\(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspended <= '0';",
                        "currentState <= suspendedFrom;",
                        "targetState <= suspendedFrom;",
                        "if (previousRinglet = suspendedFrom) then",
                        foldWithNewLine(
                            components: ["internalState <= NoOnEntry;"], initial: "", indentation: 1
                        ),
                        "else",
                        foldWithNewLine(
                            components: ["internalState <= onResume;"], initial: "", indentation: 1
                        ),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (command = COMMAND_SUSPEND and currentState /= \(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspendedFrom <= currentState;",
                        "suspended <= '1';",
                        "currentState <= \(suspendedState);",
                        "targetState <= \(suspendedState);",
                        "if (previousRinglet = \(suspendedState)) then",
                        foldWithNewLine(
                            components: ["internalState <= NoOnEntry;"], initial: "", indentation: 1
                        ),
                        "else",
                        foldWithNewLine(
                            components: ["internalState <= onSuspend;"], initial: "", indentation: 1
                        ),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (currentState = \(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspended <= '1';",
                        "if (previousRinglet /= \(suspendedState)) then",
                        foldWithNewLine(
                            components: ["internalState <= onSuspend;"], initial: "", indentation: 1
                        ),
                        "else",
                        foldWithNewLine(
                            components: ["internalState <= NoOnEntry;"], initial: "", indentation: 1
                        ),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "elsif (previousRinglet = \(suspendedState)) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    internalState <= OnResume;",
                        "suspended <= '0';",
                        "suspendedFrom <= currentState;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "else",
                foldWithNewLineExceptFirst(
                    components: [
                        "    suspended <= '0';",
                        "suspendedFrom <= currentState;",
                        "if (previousRinglet /= currentState) then",
                        foldWithNewLine(
                            components: ["internalState <= onEntry;"], initial: "", indentation: 1
                        ),
                        "else",
                        foldWithNewLine(
                            components: ["internalState <= NoOnEntry;"], initial: "", indentation: 1
                        ),
                        "end if;"
                    ],
                    initial: "",
                    indentation: indentation + 1
                ),
                "end if;"
            ],
            initial: "",
            indentation: indentation
        )
    }

    // swiftlint:enable function_body_length

    /// Generate the VHDL code for the read snapshot logic. This logic reads the external variables during
    /// the ReadSnapshot internal state.
    /// - Parameters:
    ///   - machine: The machine.
    ///   - indentation: The indentation level.
    /// - Returns: The read snapshot logic.
    private func readSnapshotLogic(machine: Machine, indentation: Int) -> String {
        let parameters = machine.isParameterised ? readParameterLogic(machine: machine) : []
        if let index = machine.suspendedState {
            let initialState = toStateName(name: machine.states[machine.initialState].name)
            let suspendedState = toStateName(name: machine.states[index].name)
            return commandLogic(
                initialState: initialState,
                suspendedState: suspendedState,
                indentation: indentation,
                parameters: parameters
            )
        }
        return foldWithNewLineExceptFirst(
            components: parameters + [
                "if (previousRinglet /= currentState) then",
                foldWithNewLine(components: ["internalState <= onEntry;"], initial: "", indentation: 1),
                "else",
                foldWithNewLine(components: ["internalState <= NoOnEntry;"], initial: "", indentation: 1),
                "end if;"
            ],
            initial: "",
            indentation: indentation
        )
    }

    /// Generate the logic that reads the external variables into their snapshot copies.
    /// - Parameters:
    ///   - machine: The machine.
    ///   - indentation: The indentation level.
    /// - Returns: The logic that reads the external variables into their snapshot copies.
    private func readSnapshotVariables(machine: Machine, indentation: Int) -> String {
        var signals = machine.externalSignals.filter {
            $0.mode == .input || $0.mode == .inputoutput || $0.mode == .buffer
        }
        .map { "\($0.name) <= \(toExternal(name: $0.name));" }
        if !signals.isEmpty {
            signals[0] = "    " + signals[0]
        } else {
            return ""
        }
        return foldWithNewLineExceptFirst(
            components: signals,
            initial: "",
            indentation: indentation
        )
    }

    /// Generate the ReadSnapshot internal state.
    /// - Parameters:
    ///   - machine: The machine.
    ///   - indentation: The indentation level.
    /// - Returns: The ReadSnapshot internal state.
    private func readSnapshot(machine: Machine, indentation: Int) -> String {
        foldWithNewLineExceptFirst(
            components: [
                readSnapshotVariables(machine: machine, indentation: indentation + 1),
                readSnapshotLogic(machine: machine, indentation: indentation + 1)
            ],
            initial: "",
            indentation: indentation
        )
    }

    /// Generate the internal state switch statement that decides which action to execute.
    /// - Parameters:
    ///   - names: The state names.
    ///   - code: The code for each state.
    ///   - indentation: The indentation level.
    ///   - trailer: The code to execute after the switch statement.
    ///   - internalVar: The internal variable to switch on.
    ///   - defaultCode: The code to execute if no case matches.
    /// - Returns: The internal state switch statement.
    private func codeForStatesStatement(
        names: [VariableName],
        code: [String],
        indentation: Int,
        trailer: String,
        internalVar: String = "currentState",
        defaultCode: String = "null;"
    ) -> String {
        guard names.count == code.count else {
            fatalError("Invalid call of codeForStatesStatement. Size of parameters does not match")
        }
        if code.allSatisfy(\.isEmpty) {
            return "    " + trailer
        }
        var data = names.indices.flatMap { (i: Int) -> [String] in
            guard code[i] != "" else {
                return [""]
            }
            return [
                "when \(toStateName(name: names[i])) =>"
            ] + code[i].split(separator: "\n").map { "    " + String($0) }
        }
        if data.isEmpty {
            return ""
        }
        data[0] = "    " + data[0]
        data.append("when others =>")
        data.append("    \(defaultCode)")
        return foldWithNewLineExceptFirst(
            components: [
                "    case \(internalVar) is",
                foldWithNewLineExceptFirst(components: data, initial: "", indentation: indentation + 1),
                "end case;",
                trailer
            ],
            initial: "",
            indentation: indentation
        )
    }

    /// Generate the code for a particular action.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - actionName: The name of the action.
    ///   - trailers: Any trailers to add to the code.
    /// - Returns: The code for the action.
    private func actionForStates(
        machine: Machine, actionName: ActionName, trailers: [String]? = nil
    ) -> [String] {
        guard let unwrappedTrailers = trailers else {
            return machine.states.map { $0.actions[actionName] ?? "" }
        }
        return machine.states.indices.map { (i: Int) -> String in
            let actionCode = machine.states[i].actions[actionName] ?? ""
            return foldWithNewLine(components: [actionCode, unwrappedTrailers[i]])
        }
    }

    /// Generate the OnEntry internal state.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - indentation: The indentation level.
    /// - Returns: The OnEntry internal state.
    private func onEntry(machine: Machine, indentation: Int) -> String {
        let trailers: [String] = machine.states.indices.map {
            hasAfterInTransition(state: $0, machine: machine)
        }
        .map {
            if $0 {
                return "ringlet_counter := 0;"
            }
            return ""
        }
        return codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionForStates(
                machine: machine, actionName: VariableName.onEntry, trailers: trailers
            ),
            indentation: indentation,
            trailer: "internalState <= CheckTransition;"
        )
    }

    /// Generate the OnExit internal state.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - indentation: The indentation level.
    /// - Returns: The OnExit internal state.
    private func onExit(machine: Machine, indentation: Int) -> String {
        codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionForStates(machine: machine, actionName: VariableName.onExit),
            indentation: indentation,
            trailer: "internalState <= WriteSnapshot;"
        )
    }

    /// Generate the internal actions internal state.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - indentation: The indentation level.
    /// - Returns: The internal internal state.
    private func internalAction(machine: Machine, indentation: Int) -> String {
        let trailers: [String] = machine.states.indices.map {
            hasAfterInTransition(state: $0, machine: machine)
        }
        .map {
            if $0 {
                return "ringlet_counter := ringlet_counter + 1;"
            }
            return ""
        }
        return codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionForStates(
                machine: machine, actionName: VariableName.internal, trailers: trailers
            ),
            indentation: indentation,
            trailer: "internalState <= WriteSnapshot;"
        )
    }

    /// Generate all of the action code for a particular state.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - actionsNames: The names of the actions.
    ///   - trailers: The trailers to add to the code.
    /// - Returns: The code for the actions.
    private func actionsForStates(
        machine: Machine, actionsNames: [ActionName], trailers: [String]? = nil
    ) -> [String] {
        guard let unwrappedTrailers = trailers else {
            return machine.states.map { state in
                let actions = actionsNames.map { name in
                    state.actions[name] ?? ""
                }
                return foldWithNewLine(components: actions)
            }
        }
        return machine.states.indices.map { index in
            let state = machine.states[index]
            let actions = actionsNames.map { name in
                state.actions[name] ?? ""
            }
            return foldWithNewLine(components: actions + [unwrappedTrailers[index]])
        }
    }

    /// Generate the OnResume internal state.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - indentation: The indentation level.
    /// - Returns: The OnResume internal state.
    private func onResume(machine: Machine, indentation: Int) -> String {
        let trailers = machine.states.indices.map { (index: Int) -> String in
            if hasAfterInTransition(state: index, machine: machine) {
                return "ringlet_counter := 0;"
            }
            return ""
        }
        return codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actionsForStates(
                machine: machine,
                actionsNames: [VariableName.onResume, VariableName.onEntry],
                trailers: trailers
            ),
            indentation: indentation,
            trailer: "internalState <= CheckTransition;"
        )
    }

    /// Generate the OnSuspend internal state.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - indentation: The indentation level.
    /// - Returns: The OnSuspend internal state.
    private func onSuspend(machine: Machine, indentation: Int) -> String {
        // swiftlint:disable:next force_unwrapping
        let onEntry = (machine.states[machine.suspendedState!].actions[VariableName.onEntry] ?? "")
            .split(separator: "\n").map { String($0) }
//        if onEntry.count > 0 {
//            onEntry[0] = "    " + onEntry[0]
//        }
        let actions = actionForStates(machine: machine, actionName: VariableName.onSuspend)
        return codeForStatesStatement(
            names: machine.states.map(\.name),
            code: actions,
            indentation: indentation,
            trailer: foldWithNewLineExceptFirst(
                components: onEntry + ["internalState <= CheckTransition;"],
                initial: "",
                indentation: indentation
            ),
            internalVar: "suspendedFrom"
        )
    }

    /// Generate the writeSnapshot internal state.
    /// - Parameters:
    ///   - machine: The machine to generate.
    ///   - indentation: The indentation level.
    /// - Returns: The writeSnapshot internal state.
    private func writeSnapshot(machine: Machine, indentation: Int) -> String {
        let externalSignals = machine.externalSignals.filter {
            $0.mode == .output || $0.mode == .inputoutput || $0.mode == .buffer
        }
        .map {
            "\(toExternal(name: $0.name)) <= \($0.name);"
        }
        var combined = externalSignals + [
            "internalState <= ReadSnapshot;",
            "previousRinglet <= currentState;",
            "currentState <= targetState;"
        ]
        combined[0] = "    " + combined[0]
        return foldWithNewLineExceptFirst(
            components: combined + writeOutputLogic(machine: machine), initial: "", indentation: indentation
        )
    }

    /// Convert an expression to a decimal.
    /// - Parameter expression: The expression to convert.
    /// - Returns: The decimal expression.
    private func toDecimal(expression: String) -> String {
        guard let decimal = Double(expression) else {
            return expression
        }
        return String(decimal)
    }

    /// Replace after calls with the appropriate ringlet counter.
    /// - Parameters:
    ///   - expression: The expression to replace.
    ///   - after: The after call.
    /// - Returns: The expression with the after call replaced.
    private func replaceAfter(expression: String, after: String) -> String {
        let expression = toDecimal(expression: expression)
        if after == "after_ps" {
            return "(ringlet_counter >= (\(expression)) * RINGLETS_PER_PS)"
        }
        if after == "after_ns" {
            return "(ringlet_counter >= (\(expression)) * RINGLETS_PER_NS)"
        }
        if after == "after_us" {
            return "(ringlet_counter >= (\(expression)) * RINGLETS_PER_US)"
        }
        if after == "after_ms" {
            return "(ringlet_counter >= (\(expression)) * RINGLETS_PER_MS)"
        }
        if after == "after" {
            return "(ringlet_counter >= (\(expression)) * RINGLETS_PER_S)"
        }
        return "(ringlet_counter >= (\(expression)))"
    }

    // swiftlint:disable function_body_length

    /// Replace after calls with the appropriate ringlet counter.
    /// - Parameter condition: The condition to replace.
    /// - Returns: The condition with the after calls replaced.
    private func replaceAfters(condition: String) -> String {
        var aftersStack: String = ""
        var afterStack: String = ""
        let afters: Set<String> = ["after_ps(", "after_ns(", "after_us(", "after_ms(", "after_rt("]
        let after: Set<String> = ["after("]
        var creatingAfter = false
        var bracketCount: Int = 0
        var expression: String = ""
        var currentAfter: String = ""
        var newString = ""
        // swiftlint:disable:next closure_body_length
        condition.forEach {
            if creatingAfter {
                if $0 == ")" {
                    bracketCount -= 1
                    if bracketCount == 0 {
                        let replacement = replaceAfter(expression: expression, after: currentAfter)
                        expression = ""
                        newString.append(replacement)
                        creatingAfter = false
                        return
                    }
                } else if $0 == "(" {
                    bracketCount += 1
                }
                expression.append($0)
                return
            }
            aftersStack.append($0)
            afterStack.append($0)
            newString.append($0)
            if aftersStack.count > 9 {
                aftersStack = String(
                    aftersStack[
                        String.Index(
                            utf16Offset: 1, in: aftersStack
                        )..<String.Index(utf16Offset: aftersStack.count, in: aftersStack)
                    ]
                )
            }
            if afterStack.count > 6 {
                afterStack = String(
                    afterStack[
                        String.Index(
                            utf16Offset: 1, in: afterStack
                        )..<String.Index(utf16Offset: afterStack.count, in: afterStack)
                    ]
                )
            }
            if afters.contains(aftersStack) {
                bracketCount = 1
                creatingAfter = true
                currentAfter = String(
                    aftersStack[
                        String.Index(
                            utf16Offset: 0, in: aftersStack
                        )..<String.Index(utf16Offset: 8, in: aftersStack)
                    ]
                )
                newString.removeSubrange(
                    String.Index(
                        utf16Offset: newString.count - 9, in: newString
                    )..<String.Index(utf16Offset: newString.count, in: newString)
                )
            }
            if after.contains(afterStack) {
                bracketCount = 1
                creatingAfter = true
                currentAfter = "after"
                newString.removeSubrange(
                    String.Index(
                        utf16Offset: newString.count - 6, in: newString
                    )..<String.Index(utf16Offset: newString.count, in: newString)
                )
            }
        }
        return newString
    }

    // swiftlint:enable function_body_length

    /// Generate transition expressions that take into account the previous transitions.
    /// - Parameters:
    ///   - expression: The expression to generate.
    ///   - transitionBefore: The previous transition.
    /// - Returns: The transition expression.
    private func transitionExpression(expression: String, transitionBefore: String?) -> String {
        let transformedExpression = replaceAfters(condition: expression)
        guard let before = transitionBefore else {
            return transformedExpression
        }
        return "(\(transformedExpression)) and (not (\(before)))"
    }

    /// Generate the transition VHDL code for an array of order transitions.
    /// - Parameter transitions: The transitions to convert.
    /// - Returns: The VHDL code for the transitions.
    private func transitionsToCode(transitions: [VHDLTransition]) -> String {
        if transitions.isEmpty {
            return "internalState <= Internal;"
        }
        if transitions.count == 1 && transitions[0].condition.lowercased() == "true" {
            return "targetState <= \(toStateName(name: transitions[0].target));\ninternalState <= OnExit;"
        }
        var previous: String = ""
        let expressions = transitions.indices.map { (i: Int) -> String in
            if i == 0 {
                previous = transitionExpression(expression: transitions[i].condition, transitionBefore: nil)
                return previous
            }
            previous = transitionExpression(expression: transitions[i].condition, transitionBefore: previous)
            return previous
        }
        let ifCases = expressions.indices.map { (i: Int) -> String in
            if i == 0 {
                return "if (\(expressions[i])) then"
            }
            return "elsif (\(expressions[i])) then"
        }
        let code = expressions.indices.flatMap { (i: Int) -> [String] in
            [
                ifCases[i],
                "    targetState <= \(toStateName(name: transitions[i].target));",
                "    internalState <= OnExit;"
            ]
        }
        return foldWithNewLine(components: code + ["else", "    internalState <= Internal;", "end if;"])
    }

    /// Generate the code that checks the transitions.
    /// - Parameters:
    ///   - machine: The machine to generate the code for.
    ///   - indentation: The indentation level.
    /// - Returns: The code that checks the transitions.
    private func checkTransition(machine: Machine, indentation: Int) -> String {
        guard !machine.transitions.isEmpty else {
            return "    internalState <= Internal;"
        }
        let transitions = machine.transitions.map { VHDLTransition(transition: $0, machine: machine) }
        let groupedTransitions = transitions.grouped { $0.source == $1.source }
        let code: [(VariableName, [VHDLTransition])] = Dictionary(
            uniqueKeysWithValues: groupedTransitions.map {
                ($0[0].source, $0)
            }
        )
        .sorted {
            $0.0 < $1.0
        }
        let vhdlCode = code.map { transitionsToCode(transitions: $0.1) }
        return codeForStatesStatement(
            names: code.map(\.0),
            code: vhdlCode,
            indentation: indentation,
            trailer: "",
            defaultCode: "internalState <= Internal;"
        )
    }

    /// Generate the switch statement for the different actions.
    /// - Parameters:
    ///   - machine: The machine to generate the code for.
    ///   - indentation: The indentation level.
    /// - Returns: The switch statement for the different actions.
    private func actionCase(machine: Machine, indentation: Int) -> String {
        var suspendActions: [String] = []
        if machine.suspendedState != nil {
            suspendActions = [
                "when OnResume =>",
                onResume(machine: machine, indentation: indentation + 1),
                "when OnSuspend =>",
                onSuspend(machine: machine, indentation: indentation + 1)
            ]
        }
        let components = [
            "    when ReadSnapshot =>",
            readSnapshot(machine: machine, indentation: indentation)
        ] + suspendActions + [
            "when OnEntry =>",
            onEntry(machine: machine, indentation: indentation + 1),
            "when NoOnEntry =>",
            "    internalState <= CheckTransition;",
            "when CheckTransition =>",
            checkTransition(machine: machine, indentation: indentation + 1),
            "when OnExit =>",
            onExit(machine: machine, indentation: indentation + 1),
            "when Internal =>",
            internalAction(machine: machine, indentation: indentation + 1),
            "when WriteSnapshot =>",
            writeSnapshot(machine: machine, indentation: indentation + 1),
            "when others =>",
            "    null;"
        ]
        return foldWithNewLineExceptFirst(components: components, initial: "", indentation: indentation)
    }

    /// Generate the counters for the after calls.
    /// - Parameter clock: The clock to generate the counters for.
    /// - Returns: The counters for the after calls.
    private func afterVariables(driving clock: Clock) -> String {
        let period = String(format: "%0.2f", clock.period.seconds_d.rawValue * 1_000_000_000_000 )
        return foldWithNewLine(
            components: [
                "shared variable ringlet_counter: natural := 0;",
                "constant clockPeriod: real := \(period); -- ps", // clock period is in picoseconds
                "constant ringletLength: real := 5.0 * clockPeriod;",
                "constant RINGLETS_PER_PS: real := 1.0 / ringletLength;",
                "constant RINGLETS_PER_NS: real := 1000.0 * RINGLETS_PER_PS;",
                "constant RINGLETS_PER_US: real := 1000000.0 * RINGLETS_PER_PS;",
                "constant RINGLETS_PER_MS: real := 1000000000.0 * RINGLETS_PER_PS;",
                "constant RINGLETS_PER_S: real := 1000000000000.0 * RINGLETS_PER_PS;"
            ],
            initial: "-- After Variables",
            indentation: 1
        )
    }

    /// Create the include statements.
    /// - Parameter includes: The includes to create.
    /// - Returns: The include statements.
    private func createIncludes(includes: [Include]) -> String {
        includes.map { $0.rawValue + ";" }.joined(separator: "\n")
    }

    /// Create the entity statement for the machine.
    /// - Parameter machine: The machine to create the entity for.
    /// - Returns: The entity statement for the machine.
    private func createEntity(machine: Machine) -> String {
        let parameters = foldWithNewLine(
            components: [createGenericsBlock(variables: machine.generics), createPortBlock(machine: machine)],
            initial: ""
        )
        return """
         entity \(machine.name) is
         \(parameters)
         end \(machine.name);
         """
    }

    /// Create the generic block in the entity.
    /// - Parameter variables: The generic variables.
    /// - Returns: The generic block in the entity.
    private func createGenericsBlock(variables: [LocalSignal]) -> String {
        guard !variables.isEmpty else {
            return ""
        }
        return """
             generic (
         \(foldWithNewLine(
            components: variables.indices.map {
                if $0 == variables.count - 1 {
                    return variableToGeneric(variable: variables[$0], withSemicolon: false)
                }
                return variableToGeneric(variable: variables[$0], withSemicolon: true)
            },
            initial: "",
            indentation: 2
         )
         )
             );
         """
    }

    /// Convert a variable to a generic.
    /// - Parameters:
    ///   - variable: The variable to convert.
    ///   - withSemicolon: True if the generic should end with a semicolon.
    /// - Returns: The generic.
    private func variableToGeneric(variable: LocalSignal, withSemicolon: Bool) -> String {
        let semiColon = withSemicolon ? ";" : ""
        let variableComment = variable.comment?.rawValue ?? ""
        guard let defaultValue = variable.defaultValue else {
            return "\(variable.name): \(variable.type)\(semiColon) \(variableComment)"
        }
        return "\(variable.name): \(variable.type) := \(defaultValue)\(semiColon) \(variableComment)"
    }

    /// Generate a variable that goes in a port statement.
    /// - Parameters:
    ///   - variable: The variable to generate.
    ///   - withSemicolon: True if the variable should end with a semicolon.
    /// - Returns: The variable that goes in a port statement.
    private func variableToPort(variable: ExternalVariable, withSemicolon: Bool) -> String {
        let semiColon = withSemicolon ? ";" : ""
        let comment = variable.comment?.rawValue ?? ""
        let variableComment = comment.isEmpty ? "" : "\(comment)"
        guard let range = variable.range else {
            guard let defaultValue = variable.defaultValue else {
                return "\(variable.name): \(variable.type)\(semiColon)" + " \(variableComment)"
            }
            return "\(variable.name): \(variable.type) := \(defaultValue)\(semiColon)" + " \(variableComment)"
        }
        guard let defaultValue = variable.defaultValue else {
            return "\(variable.name): \(variable.type) range \(range.0) to \(range.1)\(semiColon)" +
                " \(variableComment)"
        }
        return "\(variable.name): \(variable.type) range \(range.0) to \(range.1) := \(defaultValue)" +
            "\(semiColon)" + " \(variableComment)"
    }

    /// Removes the last semicolon from a string.
    /// - Parameter data: The string to remove the semicolon from.
    /// - Returns: The string without the last semicolon.
    private func removeLastSemicolon(data: String) -> String {
        var splitData = data.split(separator: "\n")
        guard var lastLine = splitData.last else {
            return data
        }
        guard let lastIndex = lastLine.indices.reversed().first(where: { lastLine[$0] == ";" }) else {
            return data
        }
        lastLine.remove(at: lastIndex)
        splitData[splitData.count - 1] = lastLine
        return foldWithNewLine(components: splitData.map { String($0) })
    }

    /// Create the port block in the entity.
    /// - Parameter machine: The machine to create the port block for.
    /// - Returns: The port block in the entity.
    private func createPortBlock(machine: Machine) -> String {
        guard !machine.clocks.isEmpty else {
            fatalError("No clock found for machine")
        }
        let declaration = removeLastSemicolon(data: foldWithNewLineExceptFirst(
            components: [
                foldWithNewLineExceptFirst(
                    components: machine.clocks.map { clockToSignal(clk: $0) }, initial: "", indentation: 2
                ),
                foldWithNewLineExceptFirst(
                    components: machine.externalSignals.map { signalToEntityDeclaration(signal: $0) },
                    initial: "",
                    indentation: 2
                ),
                machine.suspendedState != nil ? "suspended: out std_logic;" : "",
                foldWithNewLineExceptFirst(
                   components: machine.isParameterised ?
                    machine.parameterSignals.map { toParameterDeclaration(parameter: $0) } : [],
                   initial: "",
                   indentation: 2
                ),
                foldWithNewLineExceptFirst(
                    components: machine.isParameterised ?
                        machine.returnableSignals.map(toReturnDeclaration) : [],
                    initial: "",
                    indentation: 2
                ),
                machine.suspendedState != nil ? "command: in std_logic_vector(1 downto 0);" : ""
            ],
            initial: "",
            indentation: 2
        ))
        return """
             port (
                 \(declaration)
             );
         """
    }

    /// Create the parameter variable.
    /// - Parameter parameter: The parameter to create the variable for.
    /// - Returns: The variable.
    private func toParameterDeclaration(parameter: Parameter) -> String {
        let name = toParameter(name: parameter.name)
        let parameterComment = parameter.comment?.rawValue ?? ""
        guard let defaultValue = parameter.defaultValue else {
            return "\(name): in \(parameter.type);" +
                (parameter.comment == nil ? "" : " \(parameterComment)")
        }
        return "\(name): in \(parameter.type) := \(defaultValue);" +
            (parameter.comment == nil ? "" : " \(parameterComment)")
    }

    /// Create the returnable variable.
    /// - Parameter returnable: The returnable to create the variable for.
    /// - Returns: The variable.
    private func toReturnDeclaration(returnable: ReturnableVariable) -> String {
        let name = toReturnable(name: returnable.name)
        let returnableComment = returnable.comment?.rawValue ?? ""
        return "\(name): out \(returnable.type);" +
            (returnable.comment == nil ? "" : " \(returnableComment)")
    }

    /// Create the Returnable name.
    /// - Parameter name: The name of the returnable.
    /// - Returns: The new returnable name.
    private func toReturnable(name: VariableName) -> String {
        "OUTPUT_\(name)"
    }

    /// Create the parameter name.
    /// - Parameter name: The name of the parameter.
    /// - Returns: The new parameter name.
    private func toParameter(name: VariableName) -> String {
        "PARAMETER_\(name)"
    }

    /// Create the external name.
    /// - Parameter name: The name of the external signal.
    /// - Returns: The new external name.
    private func toExternal(name: VariableName) -> String {
        "EXTERNAL_\(name)"
    }

    /// Generate clock definition.
    /// - Parameter clk: The clock to generate the definition for.
    /// - Returns: The clock definition.
    private func clockToSignal(clk: Clock) -> String {
        "\(clk.name): in std_logic;"
    }

    /// Reduce a list of components by placing new lines between them.
    /// - Parameters:
    ///   - components: The components to reduce.
    ///   - initial: The initial value.
    ///   - indentation: The indentation level.
    /// - Returns: The reduced string.
    private func foldWithNewLine(components: [String], initial: String = "", indentation: Int = 0) -> String {
        components.reduce(initial) {
            if $0.isEmpty && $1.isEmpty {
                return ""
            }
            if $0.isEmpty {
                return String(indent(count: indentation)) + $1
            }
            if $1.isEmpty {
                return $0
            }
            return $0 + "\n\(indent(count: indentation))" + $1
        }
    }

    /// Create a port parameter for the entity declaration.
    /// - Parameter signal: The signal to create the parameter for.
    /// - Returns: The parameter.
    private func signalToEntityDeclaration(signal: PortSignal) -> String {
        let name = toExternal(name: signal.name)
        let signalComment = signal.comment?.rawValue ?? ""
        guard let defaultValue = signal.defaultValue else {
            return "\(name): \(signal.mode.rawValue) \(signal.type);" +
                (signal.comment == nil ? "" : " \(signalComment)")
        }
        return "\(name): \(signal.mode.rawValue) \(signal.type) := \(defaultValue);" +
            (signal.comment == nil ? "" : " \(signalComment)")
    }

    /// Generate a signal architecture declaration.
    /// - Parameters:
    ///   - signal: The signal to generate the declaration for.
    ///   - value: The value to assign to the signal.
    ///   - comment: The comment to add to the signal.
    /// - Returns: The signal declaration.
    private func signalToArchitectureDeclaration<T: Variable>(
        signal: T, with value: Bool = false, and comment: Bool = false
    ) -> String {
        let comment = comment ? " \(signal.comment?.rawValue ?? "")" : ""
        guard let defaultVal = signal.defaultValue else {
            return "signal \(signal.name): \(signal.type);\(comment)"
        }
        if value {
            return "signal \(signal.name): \(signal.type) := \(defaultVal);\(comment)"
        }
        return "signal \(signal.name): \(signal.type);\(comment)"
    }

    /// Find the number of bits required for an integer.
    /// - Parameter count: The integer to find the number of bits for.
    /// - Returns: The number of bits.
    private func findBinaryLength(count: Int) -> Int {
        if count <= 1 {
            return 1
        }
        if count.isMultiple(of: 2) {
            return Int(ceil(log2(Double(count + 1))))
        }
        return Int(ceil(log2(Double(count))))
    }

    /// Generate the state name for a state.
    /// - Parameter name: The name of the state.
    /// - Returns: The state name.
    private func toStateName(name: VariableName) -> String {
        "STATE_\(name)"
    }

    /// Convert a number to it's binary representation.
    /// - Parameters:
    ///   - number: The number to convert.
    ///   - binaryPosition: The position in the binary representation.
    /// - Returns: The binary representation.
    private func toBinary(number: Int, binaryPosition: Int) -> String {
        if number <= 0 && binaryPosition >= 0 {
            return "0" + toBinary(number: number, binaryPosition: binaryPosition - 1)
        }
        if binaryPosition < 0 {
            return ""
        }
        let length = findBinaryLength(count: number)
        if length - 1 == binaryPosition {
            return "1" + toBinary(
                number: number - Int(pow(2, Double(binaryPosition))), binaryPosition: binaryPosition - 1
            )
        }
        return "0" + toBinary(number: number, binaryPosition: binaryPosition - 1)
    }

    /// Create the state representation.
    /// - Parameters:
    ///   - name: The name of the state.
    ///   - length: The length of the state.
    ///   - index: The index of the binary representation.
    /// - Returns: The state representation.
    private func toStateVar(name: VariableName, length: Int, index: Int) -> String {
        let l = max(1, length)
        return "constant \(toStateName(name: name)): std_logic_vector(\(l - 1) downto 0) := \"" +
            "\(toBinary(number: index, binaryPosition: l - 1))\";"
    }

    /// Generate the state representation for all states.
    /// - Parameter machine: The machine to generate the state representation for.
    /// - Returns: The state representation.
    private func stateRepresenation(machine: Machine) -> String {
        let states = machine.states
        let initialState = machine.states[machine.initialState].name
        let defaultState: VariableName
        if let suspendIndex = machine.suspendedState {
            if machine.isParameterised {
                defaultState = machine.states[suspendIndex].name
            } else {
                defaultState = initialState
            }
        } else {
            defaultState = initialState
        }
        let stateLength = findBinaryLength(count: states.count)
        return """
         -- State Representation Bits
         \(foldWithNewLine(
                components: states.indices.map {
                    toStateVar(name: states[$0].name, length: stateLength, index: $0)
                },
                initial: "",
                indentation: 1
            )
         )
         \(
         foldWithNewLine(
            components: [
                "signal currentState: std_logic_vector(\(stateLength - 1) downto 0) := " +
                    "\(toStateName(name: defaultState));",
                "signal targetState: std_logic_vector(\(stateLength - 1) downto 0) := " +
                    "\(toStateName(name: defaultState));",
                "signal previousRinglet: std_logic_vector(\(stateLength - 1) downto 0) := " +
                    "\"\(String(repeating: "Z", count: stateLength) )\";"
            ] + (machine.suspendedState == nil ? [] : [
                "signal suspendedFrom: std_logic_vector(\(stateLength - 1) downto 0) := " +
                    "\(toStateName(name: initialState));"
            ]),
            initial: "",
            indentation: 1
         ))
         """
    }

    /// Generate the variable architecture representation.
    /// - Parameter variable: The variable to generate the architecture representation for.
    /// - Returns: The variable architecture representation.
    private func variableToArchitectureDeclaration(variable: LocalSignal) -> String {
        let comment = nil == variable.comment ? "" : " \(variable.comment?.rawValue ?? "")"
        return "shared variable \(variable.name): \(variable.type);\(comment)"
    }

    /// Generate the snapshot variables.
    /// - Parameter machine: The machine to generate the snapshot variables for.
    /// - Returns: The snapshot variables.
    private func snapshots(machine: Machine) -> String {
        foldWithNewLine(
            components: [],
            initial: foldWithNewLine(
                components: machine.externalSignals.map { signalToArchitectureDeclaration(signal: $0) },
                initial: "-- Snapshot of External Signals and Variables",
                indentation: 1
            ),
            indentation: 1
        )
    }

    /// Generate the machine variables.
    /// - Parameters:
    ///   - signals: The signals to generate the machine variables for.
    ///   - variables: The variables to generate the machine variables for.
    /// - Returns: The machine variables.
    private func machineVariables(signals: [LocalSignal]) -> String {
        foldWithNewLine(
            components: signals.map {
                signalToArchitectureDeclaration(
                    signal: $0, with: $0.defaultValue != nil, and: $0.comment != nil
                )
            },
            initial: "-- Machine Signals",
            indentation: 1
        )
    }

    /// A string representation of an indentation.
    /// - Parameter count: The number of indentations.
    /// - Returns: The string representation of the indentation.
    private func indent(count: Int) -> String {
        String(repeating: "    ", count: count)
    }

    /// Generate the architecture head.
    /// - Parameter head: The head to generate.
    /// - Returns: The architecture head.
    private func architectureHead(head: String?) -> String {
        guard let head = head else {
            return ""
        }
        return foldWithNewLine(
            components: head.split(separator: "\n").map { String($0) },
            initial: "-- User-Specific Code for Architecture Head",
            indentation: 1
        )
    }

    /// Generate the body.
    /// - Parameter body: The body to generate.
    /// - Returns: The body.
    private func architectureBody(body: String?) -> String {
        guard let body = body else {
            return ""
        }
        return foldWithNewLine(
            components: body.split(separator: "\n").map { String($0) },
            initial: "-- User-Specific Code for Architecture Body",
            indentation: 1
        ) + "\n"
    }

    /// Generate the architecture process code.
    /// - Parameter machine: The machine to generate the architecture process code for.
    /// - Returns: The architecture process code.
    private func createArchitectureBody(machine: Machine) -> String {
        foldWithNewLineExceptFirst(
            components: [
                "    if (rising_edge(\(machine.clocks[machine.drivingClock].name))) then",
                foldWithNewLineExceptFirst(
                    components: [
                        "    case internalState is",
                        actionCase(machine: machine, indentation: 4),
                        "end case;"
                    ],
                    initial: "",
                    indentation: 3
                ),
                "end if;"
            ],
            initial: "",
            indentation: 2
        )
    }

    /// Generate the parameter snapshots for the machine.
    /// - Parameter machine: The machine to generate the parameter snapshots for.
    /// - Returns: The parameter snapshots.
    private func parameters(machine: Machine) -> String {
        foldWithNewLine(
            components: [],
            initial: foldWithNewLine(
                components: machine.parameterSignals.map { signalToArchitectureDeclaration(signal: $0) },
                initial: "-- Snapshot of Parameter Signals and Variables",
                indentation: 1
            ),
            indentation: 1
        )
    }

    /// Generate the returnable snapshot.
    /// - Parameter signal: The signal to generate the returnable snapshot for.
    /// - Returns: The returnable snapshot.
    private func returnableSignalToArchitectureDeclaration(signal: ReturnableVariable) -> String {
        "signal \(signal.name): \(signal.type);"
    }

    /// Generate the returnable snapshot for a variable.
    /// - Parameter variable: The variable to generate the returnable snapshot for.
    /// - Returns: The returnable snapshot.
    private func returnableVariableToArchitectureDeclaration(variable: ReturnableVariable) -> String {
        "shared variable \(variable.name): \(variable.type);"
    }

    /// Generate the returnable snapshots for the machine.
    /// - Parameter machine: The machine to generate the returnable snapshots for.
    /// - Returns: The returnable snapshots.
    private func outputs(machine: Machine) -> String {
        foldWithNewLine(
            components: [],
            initial: foldWithNewLine(
                components: machine.returnableSignals.map {
                    returnableSignalToArchitectureDeclaration(signal: $0)
                },
                initial: "-- Snapshot of Output Signals and Variables",
                indentation: 1
            ),
            indentation: 1
        )
    }

    /// Create the entire architecture.
    /// - Parameter machine: The machine to create the architecture for.
    /// - Returns: The architecture.
    private func createArhictecure(machine: Machine) -> String {
        let parameters = machine.isParameterised ? self.parameters(machine: machine) : ""
        let returns = machine.isParameterised ? outputs(machine: machine) : ""
        let hasAfters = machine.states.indices.contains { hasAfterInTransition(state: $0, machine: machine) }
        return foldWithNewLine(
            components: [
                internalStates(machine: machine),
                stateRepresenation(machine: machine),
                machine.suspendedState != nil ? suspensionCommands : "",
                hasAfters ? afterVariables(driving: machine.clocks[machine.drivingClock]) : "",
                snapshots(machine: machine)
            ] + [
                parameters,
                returns
            ] + [
                machineVariables(signals: machine.machineSignals),
                architectureHead(head: machine.architectureHead)
            ],
            initial: "architecture Behavioral of \(machine.name) is",
            indentation: 1
        ) + "\nbegin\n" + foldWithNewLine(
            components: [
                "process(\(machine.clocks[machine.drivingClock].name))",
                "begin",
                createArchitectureBody(machine: machine),
                "end process;"
            ],
            initial: foldWithNewLine(
                components: [
                    architectureBody(body: machine.architectureBody)
                ],
                initial: "",
                indentation: 1
            ),
            indentation: 1
        ) + "\nend Behavioral;"
    }

    /// Merge lines into a single statement without adding a newline to the first element.
    /// - Parameters:
    ///   - components: The components to merge.
    ///   - initial: The initial value.
    ///   - indentation: The indentation level.
    /// - Returns: The merged lines.
    private func foldWithNewLineExceptFirst(
        components: [String], initial: String = "", indentation: Int = 0
    ) -> String {
        if components.isEmpty {
            return initial
        }
        guard components.count > 1 else {
            return components[0]
        }
        let newList = Array(components[1..<components.count])
        return foldWithNewLine(components: [components[0]], initial: initial, indentation: 0) +
            "\n" + foldWithNewLine(components: newList, initial: "", indentation: indentation)
    }

    /// Check if a condition has an after statement.
    /// - Parameter condition: The condition to check.
    /// - Returns: Whether the condition has an after statement.
    private func hasAfter(condition: String) -> Bool {
        condition.contains("after(") || condition.contains("after_ps(") ||
            condition.contains("after_ns(") || condition.contains("after_us(") ||
            condition.contains("after_ms(") || condition.contains("after_rt(")
    }

    /// Check if a state has an after statement in its transitions.
    /// - Parameters:
    ///   - index: The index of the state to check.
    ///   - machine: The machine to check.
    /// - Returns: True if the state has an after statement in its transitions.
    private func hasAfterInTransition(state index: Int, machine: Machine) -> Bool {
        let transitions = machine.transitions.filter { $0.source == index }
        return transitions.contains { hasAfter(condition: $0.condition) }
    }

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
