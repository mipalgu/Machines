//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO

public struct VHDLCompiler {
    
    var helper: FileHelpers = FileHelpers()
    
    var internalStates: String {
        foldWithNewLine(
            components: [
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
            ],
            initial: "-- Internal State Representation Bits",
            indentation: 1
        )
    }
    
    var suspensionCommands: String {
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
    
    private func afterVariables(driving clock: Clock) -> String {
        foldWithNewLine(
            components: [
                "shared variable ringlet_counter: natural := 0;",
                "constant clockPeriod: real := \( String(format: "0.2f", clock.period * 1_000_000_000 )); -- ns",
                "constant ringletLength: real := 5.0 * clockPeriod;",
                "constant RINGLETS_PER_NS: real := 1.0 / ringletLength;",
                "constant RINGLETS_PER_US: real := 1000.0 * RINGLETS_PER_NS;",
                "constant RINGLETS_PER_MS: real := 1000000.0 * RINGLETS_PER_NS;",
                "constant RINGLETS_PER_S: real := 1000000000.0 * RINGLETS_PER_NS;"
            ],
            initial: "-- After Variables",
            indentation: 1
        )
    }
    
    public func compile(_ machine: Machine) -> Bool {
        let format = foldWithNewLine(
            components: [
                createIncludes(includes: machine.includes) + "\n",
                createEntity(machine: machine) + "\n\n",
                createArhictecure(machine: machine)
            ],
            initial: ""
        )
        let fileName = "\(machine.name).vhd"
        return helper.createFile(fileName, inDirectory: machine.path, withContents: format + "\n") != nil
    }
    
    private func createIncludes(includes: [String]) -> String {
        return includes.reduce("") {
            if $0 == $1 && $0 == "" {
                return ""
            }
            if $0 == "" {
                return String($1)
            }
            return $0 + "\n" + $1
        }
    }
    
    private func createEntity(machine: Machine) -> String {
        """
         entity \(machine.name) is
         \(foldWithNewLine(components: [createGenericsBlock(variables: machine.externalVariables), createPortBlock(clocks: machine.clocks, signals: machine.externalSignals)], initial: ""))
         end \(machine.name);
         """
    }
    
    private func createGenericsBlock(variables: [VHDLVariable]) -> String {
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
    
    private func variableToGeneric(variable: VHDLVariable, withSemicolon: Bool) -> String {
        let semiColon = withSemicolon ? ";" : ""
        guard let range = variable.range else {
            guard let defaultValue = variable.defaultValue else {
                return "\(variable.name): \(variable.type)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
            }
            return "\(variable.name): \(variable.type) := \(defaultValue)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
        }
        guard let defaultValue = variable.defaultValue else {
            return "\(variable.name): \(variable.type) range \(range.0) to \(range.1)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
        }
        return "\(variable.name): \(variable.type) range \(range.0) to \(range.1) := \(defaultValue)\(semiColon)" + (variable.comment == nil ? "" : " -- \(variable.comment!)")
    }
    
    private func createPortBlock(clocks: [Clock], signals: [ExternalSignal]) -> String {
        guard !clocks.isEmpty else {
            fatalError("No clock found for machine")
        }
        return """
             port (
         \(foldWithNewLine(components: clocks.map { clockToSignal(clk: $0) }, initial: "", indentation: 2));
         \(foldWithNewLine(components: signals.map { signalToEntityDeclaration(signal: $0) }, initial: indent(count: 2) + "suspended: out std_logic;", indentation: 2))
                 command: in std_logic_vector(1 downto 0)
             );
         """
    }
    
    private func clockToSignal(clk: Clock) -> String {
        "\(clk.name): in std_logic"
    }
    
    private func foldWithNewLine(components: [String], initial: String, indentation: Int = 0) -> String {
        return components.reduce(initial) {
            if $0 == "" && $1 == "" {
                return ""
            }
            if $0 == "" {
                return String(indent(count: indentation)) + $1
            }
            if $1 == "" {
                return $0
            }
            return $0 + "\n\(indent(count: indentation))" + $1
        }
    }
    
    private func signalToEntityDeclaration(signal: ExternalSignal) -> String {
        guard let defaultValue = signal.defaultValue else {
            return "\(signal.name): \(signal.mode.rawValue) \(signal.type);" + (signal.comment == nil ? "" : " -- \(signal.comment!)")
        }
        return "\(signal.name): \(signal.mode.rawValue) \(signal.type) := \(defaultValue);" + (signal.comment == nil ? "" : " -- \(signal.comment!)")
    }
    
    private func findBinaryLength(count: Int) -> Int {
        if count <= 1 {
            return 1
        }
        if count % 2 == 0 {
            return Int(ceil(log2(Double(count + 1))))
        }
        return Int(ceil(log2(Double(count))))
    }
    
    private func toStateName(name: String) -> String {
        "STATE_\(name)"
    }
    
    private func toBinary(number: Int, binaryPosition: Int) -> String {
        if number <= 0 && binaryPosition >= 0 {
            return "0" + toBinary(number: number, binaryPosition: binaryPosition - 1)
        }
        if binaryPosition < 0 {
            return ""
        }
        let length = findBinaryLength(count: number)
        print(number)
        print("Length for \(number): \(length)")
        print("Binary position: \(binaryPosition)")
        if length - 1 == binaryPosition {
            return "1" + toBinary(number: number - Int(pow(2, Double(binaryPosition))), binaryPosition: binaryPosition - 1)
        }
        return "0" + toBinary(number: number, binaryPosition: binaryPosition - 1)
    }
    
    private func toStateVar(name: String, length: Int, index: Int) -> String {
        let l = max(1, length)
        print(name)
        return "constant \(toStateName(name: name)): std_logic_vector(\(l - 1) downto 0) := \"\(toBinary(number: index, binaryPosition: l - 1))\""
    }
    
    private func stateRepresenation(states: [State], initialState: String) -> String {
        let stateLength = findBinaryLength(count: states.count)
        return """
         -- State Representation Bits
         \(foldWithNewLine(
            components: states.indices.map { toStateVar(name: states[$0].name, length: stateLength, index: $0) },
            initial: "",
            indentation: 1)
         )
         \(
         foldWithNewLine(
            components: [
                "signal currentState: std_logic_vector(1 downto 0) := \(toStateName(name: initialState));",
                "signal targetState: std_logic_vector(1 downto 0) := \(toStateName(name: initialState));",
                "signal previousRinglet: std_logic_vector(1 downto 0) := \"ZZ\";",
                "signal suspendedFrom: std_logic_vector(1 downto 0) := \(toStateName(name: initialState));"
            ],
            initial: "",
            indentation: 1
         ))
         """
    }
    
    private func indent(count: Int) -> String {
        String(repeating: "    ", count: count)
    }
    
    private func createArhictecure(machine: Machine) -> String {
        return foldWithNewLine(
            components: [
                internalStates,
                stateRepresenation(states: machine.states, initialState: machine.states[machine.initialState].name),
                suspensionCommands,
                afterVariables(driving: machine.clocks[machine.drivingClock])
            ],
            initial: "architecture Behavioral of \(machine.name) is",
            indentation: 1
        )
    }
    
}
