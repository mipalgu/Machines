//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLMachines
import Attributes

struct VHDLMachinesConverter {
    
    public func initialVHDLMachine(filePath: URL) -> Machine {
        let name = filePath.lastPathComponent.components(separatedBy: ".machine")[0]
        let defaultActions = [
            "OnEntry": "",
            "OnExit": "",
            "Internal": "",
            "OnResume": "",
            "OnSuspend": ""
        ]
        let machine = VHDLMachines.Machine(
            name: name,
            path: filePath,
            includes: [],
            externalSignals: [],
            externalVariables: [],
            clocks: [Clock(name: "clk", frequency: 50, unit: .MHz)],
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [],
            machineSignals: [],
            states: [
                VHDLMachines.State(
                    name: "Initial",
                    actions: defaultActions,
                    actionOrder: [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]],
                    signals: [],
                    variables: [],
                    externalVariables: []
                ),
                VHDLMachines.State(
                    name: "Suspended",
                    actions: defaultActions,
                    actionOrder: [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]],
                    signals: [],
                    variables: [],
                    externalVariables: []
                )
            ],
            transitions: [],
            initialState: 0,
            suspendedState: 1
        )
        return self.toMachine(machine: machine)
    }
    
    func arrangementAttributes(arrangement: VHDLMachines.Arrangement) -> [AttributeGroup] {
        var attributes: [AttributeGroup] = []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "clocks", type: .table(columns: [
                    ("name", .line),
                    ("frequency", .integer),
                    ("unit", .enumerated(validValues: Set(VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue })))
                ])),
                Field(name: "external_signals", type: .table(columns: [
                    ("mode", .enumerated(validValues: Set(VHDLMachines.ExternalSignal.Mode.allCases.map { $0.rawValue }))),
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("comment", .line)
                ])),
                Field(name: "external_variables", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("comment", .line)
                ]))
            ],
            attributes: [
                "clocks": .table(
                    arrangement.clocks.map(toLineAttribute),
                    columns: [
                        ("name", .line),
                        ("frequency", .integer),
                        ("unit", .enumerated(validValues: Set(VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue })))
                    ]
                ),
                "external_signals": .table(
                    arrangement.externalSignals.map(toLineAttribute),
                    columns: [
                        ("mode", .enumerated(validValues: Set(VHDLMachines.ExternalSignal.Mode.allCases.map { $0.rawValue }))),
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("comment", .line)
                    ]
                ),
                "external_variables": .table(
                    arrangement.externalVariables.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        )
        attributes.append(variables)
        return attributes
    }
    
    func toArrangement(arrangement: VHDLMachines.Arrangement) -> Arrangement {
        Arrangement(
            semantics: .swiftfsm,
            filePath: arrangement.path,
            dependencies: arrangement.parents.compactMap {
                guard let path = arrangement.machines[$0] else {
                    return nil
                }
                return MachineDependency(filePath: path)
                
            },
            attributes: [],
            metaData: []
        )
    }
    
    func machineAttributes(machine: VHDLMachines.Machine) -> [AttributeGroup] {
        var attributes: [AttributeGroup] = []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "clocks", type: .table(columns: [
                    ("name", .line),
                    ("frequency", .integer),
                    ("unit", .enumerated(validValues: Set(VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue })))
                ])),
                Field(name: "external_signals", type: .table(columns: [
                    ("mode", .enumerated(validValues: Set(VHDLMachines.ExternalSignal.Mode.allCases.map { $0.rawValue }))),
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ])),
                Field(name: "external_variables", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ])),
                Field(name: "machine_signals", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ])),
                Field(name: "machine_variables", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ])),
                Field(name: "driving_clock", type: .enumerated(validValues: Set(machine.clocks.map { $0.name })))
            ],
            attributes: [
                "clocks": .table(
                    machine.clocks.map(toLineAttribute),
                    columns: [
                        ("name", .line),
                        ("frequency", .integer),
                        ("unit", .enumerated(validValues: Set(VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue })))
                    ]
                ),
                "external_signals": .table(
                    machine.externalSignals.map(toLineAttribute),
                    columns: [
                        ("mode", .enumerated(validValues: Set(VHDLMachines.ExternalSignal.Mode.allCases.map { $0.rawValue }))),
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                ),
                "external_variables": .table(
                    machine.externalVariables.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                ),
                "machine_signals": .table(
                    machine.machineSignals.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                ),
                "machine_variables": .table(
                    machine.machineVariables.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                ),
                "driving_clock": .enumerated(machine.clocks[machine.drivingClock].name, validValues: Set(machine.clocks.map { $0.name }))
            ],
            metaData: [:]
        )
        attributes.append(variables)
        let includes = AttributeGroup(
            name: "includes",
            fields: [
                Field(name: "includes", type: .code(language: .vhdl))
            ],
            attributes: [
                "includes": .code(machine.includes.reduce("", addNewline), language: .vhdl)
            ],
            metaData: [:]
        )
        attributes.append(includes)
        let settings = AttributeGroup(
            name: "settings",
            fields: [
                Field(name: "initial_state", type: .enumerated(validValues: Set([""] + machine.states.map(\.name)))),
                Field(name: "suspended_state", type: .enumerated(validValues: Set([""] + machine.states.map(\.name))))
            ],
            attributes: [
                "initial_state": .enumerated(machine.states[machine.initialState].name, validValues: Set(machine.states.map(\.name))),
                "suspended_state": .enumerated(machine.suspendedState.map { machine.states[$0].name } ?? "", validValues: Set([""] + machine.states.map(\.name)))
            ],
            metaData: [:]
        )
        attributes.append(settings)
        return attributes
    }
    
    func toMachine(machine: VHDLMachines.Machine) -> Machine {
        Machine(
            semantics: .vhdl,
            filePath: machine.path,
            initialState: machine.states[machine.initialState].name,
            states: machine.states.map { toState(state: $0, machine: machine) },
            dependencies: [],
            attributes: machineAttributes(machine: machine),
            metaData: []
        )
    }
    
    func addNewline(lhs: String, rhs: String) -> String {
        if lhs == "" {
            return rhs
        }
        if rhs == "" {
            return lhs
        }
        return lhs + "\n" + rhs
    }
    
    func toLineAttribute(variable: VHDLMachines.Variable) -> [LineAttribute] {
        [
            .expression(variable.type, language: .vhdl),
            .line(variable.name),
            .expression(variable.defaultValue ?? "", language: .vhdl),
            .line(variable.comment ?? "")
        ]
    }
    
    func toLineAttribute(variable: VHDLMachines.ExternalSignal) -> [LineAttribute] {
        [
            .enumerated(variable.mode.rawValue, validValues: Set(VHDLMachines.ExternalSignal.Mode.allCases.map { $0.rawValue })),
            .expression(variable.type, language: .vhdl),
            .line(variable.name),
            .expression(variable.defaultValue ?? "", language: .vhdl),
            .line(variable.comment ?? "")
        ]
    }
    
    func toLineAttribute(variable: VHDLMachines.Clock) -> [LineAttribute] {
        [
            .line(variable.name),
            .integer(Int(variable.frequency)),
            .enumerated(variable.unit.rawValue, validValues: Set(VHDLMachines.Clock.FrequencyUnit.allCases.map { $0.rawValue }))
        ]
    }
    
    func toLineAttribute(actionOrder: [[String]], validValues: Set<String>) -> [[LineAttribute]] {
        actionOrder.indices.map { timeslot in
            actionOrder[timeslot].flatMap { action in
                [LineAttribute.integer(timeslot), LineAttribute.enumerated(action, validValues: validValues)]
            }
        }
    }
    
    func stateAttributes(state: VHDLMachines.State, machine: VHDLMachines.Machine) -> [AttributeGroup] {
        var attributes: [AttributeGroup] = []
        let externals = machine.externalSignals.map { $0.name } + machine.externalVariables.map { $0.name }
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "externals", type: .table(columns: [
                    ("name", .enumerated(validValues: Set(machine.externalSignals.map(\.name) + machine.externalVariables.map(\.name))))
                ])),
                Field(name: "state_signals", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ])),
                Field(name: "state_variables", type: .table(columns: [
                    ("type", .expression(language: .vhdl)),
                    ("lower_range", .line),
                    ("upper_range", .line),
                    ("name", .line),
                    ("value", .expression(language: .vhdl)),
                    ("comment", .line)
                ]))
            ],
            attributes: [
                "externals": .table(state.externalVariables.map { [LineAttribute.line($0)] }, columns: [("name", .enumerated(validValues: Set(externals)))]),
                "state_signals": .table(
                    state.signals.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                ),
                "state_variables": .table(
                    state.variables.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .vhdl)),
                        ("lower_range", .line),
                        ("upper_range", .line),
                        ("name", .line),
                        ("value", .expression(language: .vhdl)),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        )
        attributes.append(variables)
        let order = AttributeGroup(
            name: "actions",
            fields: [
                Field(name: "action_names", type: .table(columns: [
                    ("name", .line)
                ])),
                Field(name: "action_order", type: .table(columns: [
                    ("timeslot", .integer),
                    ("action", .enumerated(validValues: Set(state.actions.keys)))
                ]))
            ],
            attributes: [
                "action_names": .table(state.actions.keys.map { [LineAttribute.line($0)] }, columns: [
                    ("name", .line)
                ]),
                "action_order": .table(toLineAttribute(actionOrder: state.actionOrder, validValues: Set(state.actions.keys)), columns: [
                    ("timeslot", .integer),
                    ("action", .enumerated(validValues: Set(state.actions.keys)))
                ])
            ],
            metaData: [:]
        )
        attributes.append(order)
        return attributes
    }

    func toState(state: VHDLMachines.State, machine: VHDLMachines.Machine) -> State {
        let actions = state.actionOrder.reduce([]){ $0 + $1 }.map {
            toAction(actionName: $0, code: state.actions[$0] ?? "")
        }
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == state.name }) else {
            fatalError("Cannot find state with name: \(state.name).")
        }
        return State(
            name: state.name,
            actions: actions,
            transitions: machine.transitions.filter({ $0.source == stateIndex }).map({ toTransition(transition: $0, machine: machine) }),
            attributes: stateAttributes(state: state, machine: machine),
            metaData: []
        )
    }

    func toAction(actionName: String, code: String) -> Action {
        Action(name: actionName, implementation: code, language: .vhdl)
    }

    func toTransition(transition: VHDLMachines.Transition, machine: VHDLMachines.Machine) -> Transition {
        Transition(
            condition: transition.condition,
            target: machine.states[transition.target].name,
            attributes: [],
            metaData: []
        )
    }


    func fromAction(action: Action) -> (String, String) {
        (
            action.name,
            action.implementation
        )
    }
    
    func actionOrder(state: State) -> [[VHDLMachines.ActionName]] {
        guard let order = state.attributes.first(where: { $0.name == "actions" })?.attributes["action_order"] else {
            fatalError("Failed to retrieve action attributes.")
        }
        if order.tableValue.isEmpty {
            return [[]]
        }
        let maxIndex = order.tableValue.reduce(0) {
            max($0, $1[0].integerValue)
        }
        var actionOrder: [[VHDLMachines.ActionName]] = Array(repeating: [], count: maxIndex + 1)
        actionOrder.indices.forEach { timeslot in
            actionOrder[timeslot] = order.tableValue.compactMap { row in
                if row[0].integerValue == timeslot {
                    return row[1].enumeratedValue.trimmingCharacters(in: .whitespaces)
                }
                return nil
            }
        }
        return actionOrder
    }
    
    func stateSignals(state: State) -> [VHDLMachines.MachineSignal] {
        guard let rows = state.attributes.first(where: { $0.name == "variables" })?.attributes["state_signals"]?.tableValue else {
            return []
        }
        return rows.map {
            VHDLMachines.MachineSignal(
                type: $0[0].expressionValue.trimmingCharacters(in: .whitespaces),
                name: $0[1].lineValue.trimmingCharacters(in: .whitespaces),
                defaultValue: $0[2].expressionValue.trimmingCharacters(in: .whitespaces) == "" ? nil : $0[2].expressionValue.trimmingCharacters(in: .whitespaces),
                comment: $0[3].lineValue.trimmingCharacters(in: .whitespaces) == "" ? nil : $0[3].lineValue.trimmingCharacters(in: .whitespaces)
            )
        }
    }
    
    func stateVariables(state: State) -> [VHDLMachines.VHDLVariable] {
        guard let rows = state.attributes.first(where: { $0.name == "variables" })?.attributes["state_variables"]?.tableValue else {
            return []
        }
        return rows.map {
            let lowerRange = Int($0[1].lineValue.trimmingCharacters(in: .whitespaces))
            let upperRange = Int($0[2].lineValue.trimmingCharacters(in: .whitespaces))
            return VHDLMachines.VHDLVariable(
                type: $0[0].expressionValue.trimmingCharacters(in: .whitespaces),
                name: $0[3].lineValue.trimmingCharacters(in: .whitespaces),
                defaultValue: $0[4].expressionValue.trimmingCharacters(in: .whitespaces) == "" ? nil : $0[4].expressionValue.trimmingCharacters(in: .whitespaces),
                range: lowerRange == nil || upperRange == nil ? nil : (lowerRange!, upperRange!),
                comment: $0[5].lineValue.trimmingCharacters(in: .whitespaces) == "" ? nil : $0[5].lineValue.trimmingCharacters(in: .whitespaces)
            )
        }
    }
    
    func externalVariables(state: State) -> [String] {
        guard let rows = state.attributes.first(where: { $0.name == "variables" })?.attributes["externals"]?.tableValue else {
            return []
        }
        return rows.compactMap {
            let data = $0[0].lineValue.trimmingCharacters(in: .whitespaces)
            if data == "" {
                return nil
            }
            return data
        }
    }

    func toState(state: State) -> VHDLMachines.State {
        VHDLMachines.State(
            name: state.name,
            actions: Dictionary(uniqueKeysWithValues: state.actions.map(fromAction)),
            actionOrder: actionOrder(state: state),
            signals: stateSignals(state: state),
            variables: stateVariables(state: state),
            externalVariables: externalVariables(state: state)
        )
    }
    
    func getIncludes(machine: Machine) -> [String] {
        guard
            machine.attributes.count == 3,
            let includes = machine.attributes[1].attributes["includes"]?.codeValue
        else {
            fatalError("Cannot retrieve includes")
        }
        return includes.split(separator: "\n").map { String($0) }
    }
    
    func getExternalSignals(machine: Machine) -> [ExternalSignal] {
        guard
            machine.attributes.count == 3,
            let signals = machine.attributes[0].attributes["external_signals"]?.tableValue
        else {
            fatalError("Cannot retrieve external signals")
        }
        return signals.map {
            let value = $0[3].expressionValue == "" ? nil : $0[3].expressionValue
            let comment = $0[4].lineValue == "" ? nil : $0[4].lineValue
            guard let mode = ExternalSignal.Mode(rawValue: $0[0].enumeratedValue) else {
                fatalError("Cannot convert Mode!")
            }
            return ExternalSignal(type: $0[1].expressionValue, name: $0[2].lineValue, mode: mode, defaultValue: value, comment: comment)
        }
    }
    
    func getExternalVariables(machine: Machine) -> [VHDLVariable] {
        guard
            machine.attributes.count == 3,
            let variables = machine.attributes[0].attributes["external_variables"]?.tableValue
        else {
            fatalError("Cannot retrieve external variables")
        }
        return variables.map {
            VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                range: nil,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }
    
    func getClocks(machine: Machine) -> [Clock] {
        guard
            machine.attributes.count == 3,
            let clocks = machine.attributes[0].attributes["clocks"]?.tableValue
        else {
            fatalError("Cannot retrieve clocks")
        }
        return clocks.map {
            guard let unit = Clock.FrequencyUnit(rawValue: $0[2].enumeratedValue) else {
                fatalError("Clock unit is invalid: \($0[2])")
            }
            return Clock(name: $0[0].lineValue, frequency: UInt(clamping: $0[1].integerValue), unit: unit)
        }
    }
    
    func getDrivingClock(machine: Machine) -> Int {
        guard
            machine.attributes.count == 3,
            let clock = machine.attributes[0].attributes["driving_clock"]?.enumeratedValue,
            let index = machine.attributes[0].attributes["clocks"]?.tableValue.firstIndex(where: { $0[0].lineValue == clock })
        else {
            fatalError("Cannot retrieve driving clock")
        }
        return index
    }
    
    func getDependentMachines(machine: Machine) -> [MachineName: URL] {
        var machines: [MachineName: URL] = [:]
        machine.dependencies.forEach {
            machines[$0.name] = $0.filePath
        }
        return machines
    }
    
    func getMachineVariables(machine: Machine) -> [VHDLVariable] {
        guard
            machine.attributes.count == 3,
            let variables = machine.attributes[0].attributes["machine_variables"]?.tableValue
        else {
            fatalError("Cannot retrieve machine variables")
        }
        return variables.map {
            VHDLVariable(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                range: nil,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }
    
    func getMachineSignals(machine: Machine) -> [MachineSignal] {
        guard
            machine.attributes.count == 3,
            let signals = machine.attributes[0].attributes["machine_signals"]?.tableValue
        else {
            fatalError("Cannot retrieve machine signals")
        }
        return signals.map {
            MachineSignal(
                type: $0[0].expressionValue,
                name: $0[1].lineValue,
                defaultValue: $0[2].expressionValue == "" ? nil : $0[2].expressionValue,
                comment: $0[3].lineValue == "" ? nil : $0[3].lineValue
            )
        }
    }

    func getTransitions(machine: Machine) -> [VHDLMachines.Transition] {
        machine.states.indices.flatMap { stateIndex in
            machine.states[stateIndex].transitions.map { transition in
                guard let targetIndex = machine.states.firstIndex(where: { transition.target == $0.name }) else {
                    fatalError("Cannot find target state \(transition.target) for transition \(transition) from state \(machine.states[stateIndex].name)")
                }
                return VHDLMachines.Transition(condition: transition.condition ?? "true", source: stateIndex, target: targetIndex)
            }
        }
    }

    func convert(machine: Machine) throws -> VHDLMachines.Machine {
        let validator = VHDLMachinesValidator()
        try validator.validate(machine: machine)
        let vhdlStates = machine.states.map(toState)
        let suspendedState = machine.attributes.first { $0.name == "settings" }?.attributes["suspended_state"]?.enumeratedValue
        let suspendedStateName = suspendedState == "" ? nil : suspendedState
        let suspendedIndex = suspendedStateName == nil ? nil : vhdlStates.firstIndex { $0.name == suspendedStateName! }
        return VHDLMachines.Machine(
            name: machine.name,
            path: machine.filePath,
            includes: getIncludes(machine: machine),
            externalSignals: getExternalSignals(machine: machine),
            externalVariables: getExternalVariables(machine: machine),
            clocks: getClocks(machine: machine),
            drivingClock: getDrivingClock(machine: machine),
            dependentMachines: getDependentMachines(machine: machine),
            machineVariables: getMachineVariables(machine: machine),
            machineSignals: getMachineSignals(machine: machine),
            states: machine.states.map(toState),
            transitions: getTransitions(machine: machine),
            initialState: machine.states.firstIndex(where: { machine.initialState == $0.name }) ?? 0,
            suspendedState: suspendedIndex
        )
    }
}

extension VHDLMachinesConverter: MachineMutator {
    
    
    var dependencyLayout: [Field] {
        []
    }

    func addItem<Path, T>(_ item: T, to attribute: Path, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        machine[keyPath: attribute.path].append(item)
        return .success(false)
    }

    func moveItems<Path, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
        return .success(false)
    }
    
    func newDependency(_ dependency: MachineDependency, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        .failure(AttributeError<Machine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    private func createState(named name: String, forMachine machine: Machine) throws -> State {
        guard
            machine.attributes.count == 3,
            machine.semantics == .vhdl
        else {
            throw ValidationError(message: "Missing attributes in machine", path: Machine.path.attributes)
        }
        let actions = ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        guard
            let variables = machine.attributes.first(where: { $0.name == "variables" }),
            let externalSignals = variables.attributes["external_signals"]?.tableValue,
            let externalVariables = variables.attributes["external_variables"]?.tableValue
        else {
            fatalError("Cannot find variables when creating new state.")
        }
        let externals = externalSignals.map { $0[2].lineValue } + externalVariables.map { $0[1].lineValue }
        let defaultActionOrder = [["OnResume", "OnEntry"], ["OnExit", "Internal"], ["OnSuspend"]]
        return State(
            name: name,
            actions: actions.map { Action(name: $0, implementation: Code(""), language: .vhdl) },
            transitions: [],
            attributes: [
                AttributeGroup(
                    name: "variables",
                    fields: [
                        Field(name: "externals", type: .table(columns: [
                            ("name", .enumerated(validValues: Set(externals)))
                        ])),
                        Field(name: "state_signals", type: .table(columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ])),
                        Field(name: "state_variables", type: .table(columns: [
                            ("type", .expression(language: .vhdl)),
                            ("lower_range", .line),
                            ("upper_range", .line),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]))
                    ],
                    attributes: [
                        "externals": .table([], columns: [
                            ("name", .enumerated(validValues: Set(externals)))
                        ]),
                        "state_signals": .table(
                            [],
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        ),
                        "state_variables": .table(
                            [],
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("lower_range", .line),
                                ("upper_range", .line),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        )
                    ],
                    metaData: [:]
                ),
                AttributeGroup(
                    name: "actions",
                    fields: [
                        Field(name: "action_names", type: .table(columns: [
                            ("name", .line)
                        ])),
                        Field(name: "action_order", type: .table(columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: Set(actions)))
                        ]))
                    ],
                    attributes: [
                        "action_names": .table(actions.map { [LineAttribute.line($0)] }, columns: [
                            ("name", .line)
                        ]),
                        "action_order": .table(toLineAttribute(actionOrder: defaultActionOrder, validValues: Set(actions)), columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: Set(actions)))
                        ])
                    ],
                    metaData: [:]
                )
            ]
        )
    }

    func newState(machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        let name = "State"
        if nil == machine.states.first(where: { $0.name == name }) {
            do {
                machine.states.append(try self.createState(named: name, forMachine: machine))
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to create new state", path: Machine.path.states))
            }
            self.syncSuspendState(machine: &machine)
            return .success(true)
        }
        var num = 0
        var stateName: String
        repeat {
            stateName = name + "\(num)"
            num += 1
        } while (nil != machine.states.reversed().first(where: { $0.name == stateName }))
        do {
            try machine.states.append(self.createState(named: stateName, forMachine: machine))
        } catch let e as AttributeError<Machine> {
            return .failure(e)
        } catch {
            return .failure(AttributeError(message: "Unable to create new state", path: Machine.path.states))
        }
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }

    private func syncSuspendState(machine: inout Machine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[2].attributes["suspended_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[2].fields[1].type = .enumerated(validValues: validValues)
        machine.attributes[2].attributes["suspend_state"] = .enumerated(newValue, validValues: validValues)
    }

    func newTransition(source: StateName, target: StateName, condition: Expression?, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard
            let index = machine.states.indices.first(where: { machine.states[$0].name == source }),
            nil != machine.states.first(where: { $0.name == target })
        else {
            return .failure(ValidationError(message: "You must attach a transition to a source and target state", path: Machine.path))
        }
        machine.states[index].transitions.append(Transition(condition: condition, target: target))
        return .success(false)
    }
    
    func delete(dependencies: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        .failure(AttributeError<Machine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    func delete(states: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        if
            let initialIndex = machine.states.enumerated().first(where: { $0.1.name == machine.initialState })?.0,
            states.contains(initialIndex)
        {
            return .failure(ValidationError(message: "You cannot delete the initial state", path: Machine.path.states[initialIndex]))
        }
        machine.states = machine.states.enumerated().filter { !states.contains($0.0) }.map { $1 }
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }
    
    func delete(transitions: IndexSet, attachedTo sourceState: StateName, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == sourceState }) else {
            return .failure(ValidationError(message: "Unable to find state with name \(sourceState)", path: Machine.path.states))
        }
        machine.states[stateIndex].transitions = machine.states[stateIndex].transitions.enumerated().filter { !transitions.contains($0.0) }.map { $1 }
        return .success(false)
    }
    
    func deleteDependency(atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        .failure(AttributeError<Machine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    func deleteState(atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        if machine.states.count >= index {
            return .failure(ValidationError(message: "Can't delete state that doesn't exist", path: Machine.path.states))
        }
        if machine.states[index].name == machine.initialState {
            return .failure(ValidationError(message: "Can't delete the initial state", path: Machine.path.states[index]))
        }
        machine.states.remove(at: index)
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }

    func deleteTransition(atIndex index: Int, attachedTo sourceState: StateName, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let index = machine.states.indices.first(where: { machine.states[$0].name == sourceState }) else {
            return .failure(ValidationError(message: "Cannot delete a transition attached to a state that does not exist", path: Machine.path.states))
        }
        guard machine.states[index].transitions.count >= index else {
            return .failure(ValidationError(message: "Cannot delete transition that does not exist", path: Machine.path.states[index].transitions))
        }
        machine.states[index].transitions.remove(at: index)
        return .success(false)
    }

    func deleteItem<Path, T>(attribute: Path, atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        if machine[keyPath: attribute.path].count <= index || index < 0 {
            return .failure(ValidationError(message: "Invalid index '\(index)'", path: attribute))
        }
        machine[keyPath: attribute.path].remove(at: index)
        return .success(false)
    }

    private func changeName(ofState index: Int, to stateName: StateName, machine: inout Machine) throws {
        let currentName = machine.states[index].name
        if currentName == stateName {
            return
        }
        if Set(machine.states.map(\.name)).contains(stateName) {
            throw ValidationError(message: "Cannot rename state to '\(stateName)' since a state with that name already exists", path: machine.path.states[index].name)
        }
        machine[keyPath: machine.path.states[index].name.path] = stateName
        if machine.initialState == currentName {
            machine.initialState = stateName
        }
        if machine.attributes[2].attributes["suspend_state"]!.enumeratedValue == currentName {
            machine.attributes[2].attributes["suspend_state"]!.enumeratedValue = stateName
        }
        self.syncSuspendState(machine: &machine)
    }

    private func whitelist(forMachine machine: Machine) -> [AnyPath<Machine>] {
        let machinePaths = [
            AnyPath(machine.path.filePath),
            AnyPath(machine.path.initialState),
            AnyPath(machine.path.attributes[0].attributes),
            AnyPath(machine.path.attributes[1].attributes),
            AnyPath(machine.path.attributes[2].attributes)
        ]
        let statePaths: [AnyPath<Machine>] = machine.states.indices.flatMap { (stateIndex) -> [AnyPath<Machine>] in
            let attributes = [
                AnyPath(machine.path.states[stateIndex].name),
                AnyPath(machine.path.states[stateIndex].attributes[0].attributes),
                AnyPath(machine.path.states[stateIndex].attributes[1].attributes)
            ]
            let actions = machine.states[stateIndex].actions.indices.map {
                AnyPath(machine.path.states[stateIndex].actions[$0].implementation)
            }
            let transitions = machine.states[stateIndex].transitions.indices.flatMap {
                return [
                    AnyPath(machine.path.states[stateIndex].transitions[$0].condition),
                    AnyPath(machine.path.states[stateIndex].transitions[$0].target)
                ]
            }
            return attributes + actions + transitions
        }
        return machinePaths + statePaths
    }
    
    private func addClock(value: String, machine: inout Machine) {
        let currentClocks = machine.attributes[0].attributes["driving_clock"]!
        var newValidValues = currentClocks.enumeratedValidValues
        newValidValues.insert(value)
        machine.attributes[0].attributes["driving_clock"]!.enumeratedValidValues = newValidValues
    }

    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine {
        if let index = machine.states.indices.first(where: { Machine.path.states[$0].name.path == attribute.path }) {
            guard let stateName = value as? StateName else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            do {
                try self.changeName(ofState: index, to: stateName, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to change name of state", path: attribute))
            }
            if attribute.path == Machine.path.attributes[0].attributes["clocks"].wrappedValue.path {
                guard let newValue = (value as? Attribute)?.tableValue, let clockName = newValue.last?[0].lineValue else {
                    return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
                }
                addClock(value: clockName, machine: &machine)
                machine[keyPath: attribute.path] = value
                return .success(true)
            } else if attribute.path == machine.path.attributes[0].attributes["external_signals"].wrappedValue.path {
                
            }
            machine[keyPath: attribute.path] = value
            return .success(true)
        }
        machine[keyPath: attribute.path] = value
        return .success(false)
    }

    func validate(machine: Machine) throws {
        try VHDLMachinesValidator().validate(machine: machine)
    }


}
