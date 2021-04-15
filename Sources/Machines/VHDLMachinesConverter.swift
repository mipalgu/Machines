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
    
    func machineAttributes(machine: VHDLMachines.Machine) -> [AttributeGroup] {
        var attributes: [AttributeGroup] = []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "clocks", type: .table(columns: [
                    ("name", .line),
                    ("frequency", .integer)
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
                        ("frequency", .integer)
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
            .integer(Int(variable.frequency))
        ]
    }
    
    func toLineAttribute(actionOrder: [[String]]) -> [[LineAttribute]] {
        actionOrder.indices.map { timeslot in
            actionOrder[timeslot].flatMap { action in
                [LineAttribute.integer(timeslot), LineAttribute.line(action)]
            }
        }
    }
    
    func stateAttributes(state: VHDLMachines.State, machine: VHDLMachines.Machine) -> [AttributeGroup] {
        var attributes: [AttributeGroup] = []
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
                "externals": .table(state.externalVariables.map { [LineAttribute.line($0)] }, columns: [("name", .line)]),
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
                "action_order": .table(toLineAttribute(actionOrder: state.actionOrder), columns: [
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
//
//    func toTransition(source: State, transition: Transition, states: [CXXBase.State], index: Int) -> CXXBase.Transition {
//        guard let target = (states.first { $0.name == transition.target }) else {
//            fatalError("U dun goofed!")
//        }
//        return CXXBase.Transition(
//            source: source.name,
//            target: target.name,
//            condition: transition.condition ?? "true",
//            priority: UInt(index)
//        )
//    }
//
//    func toTransitions(state: State, states: [CXXBase.State]) -> [CXXBase.Transition] {
//        state.transitions.enumerated().map { toTransition(source: state, transition: $0.1, states: states, index: $0.0) }
//    }
//
//    func convert(machine: Machine) throws -> CXXBase.Machine {
//        let validator = CXXBaseMachineValidator()
//        try validator.validate(machine: machine)
//        let cxxStates = machine.states.map(toState)
//        let suspendedState = machine.attributes.first { $0.name == "settings" }?.attributes["suspended_state"]?.enumeratedValue
//        let suspendedStateName = suspendedState == "" ? nil : suspendedState
//        let suspendedIndex = suspendedStateName == nil ? nil : cxxStates.firstIndex { $0.name == suspendedStateName! }
//        var actionDisplayOrder: [String] = []
//        if machine.semantics == .clfsm {
//            actionDisplayOrder = ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
//        } else if machine.semantics == .ucfsm {
//            actionDisplayOrder = ["OnEntry", "OnExit", "Internal"]
//        }
//        return CXXBase.Machine(
//            name: machine.name,
//            path: machine.filePath,
//            includes: machine.attributes.first { $0.name == "includes" }?.attributes["includes"]?.codeValue ?? "",
//            includePaths: machine.attributes.first { $0.name == "includes" }?.attributes["include_paths"]?.textValue.components(separatedBy: .newlines) ?? [],
//            funcRefs: machine.attributes.first { $0.name == "func_refs" }?.attributes["func_refs"]?.codeValue ?? "",
//            states: cxxStates,
//            transitions: machine.states.flatMap { toTransitions(state: $0, states: cxxStates) },
//            machineVariables: machine.attributes.first { $0.name == "variables" }?.attributes["machine_variables"]?.tableValue.compactMap(toVariable) ?? [],
//            initialState: cxxStates.firstIndex { $0.name == machine.initialState } ?? 0,
//            suspendedState: suspendedIndex,
//            actionDisplayOrder: actionDisplayOrder
//        )
//    }
//
//}
//
//extension CXXBaseConverter: MachineMutator {
//
//    var dependencyLayout: [Field] {
//        []
//    }
//
//    private func perform(on machine: inout Machine, _ f: (inout Machine) throws -> Void) throws {
//        let backup = machine
//        do {
//            try f(&machine)
//            try CXXBaseMachineValidator().validate(machine: machine)
//        } catch let e {
//            machine = backup
//            throw e
//        }
//    }
//
//    func addItem<Path, T>(_ item: T, to attribute: Path, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
//        try perform(on: &machine) { machine in
//            machine[keyPath: attribute.path].append(item)
//        }
//    }
//
//    func moveItems<Path, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int) throws where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
//        try perform(on: &machine) { machine in
//            machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
//        }
//    }
//
//    private func createState(named name: String, forMachine machine: Machine) throws -> State {
//        guard
//            machine.attributes.count == 4,
//            machine.semantics == .ucfsm || machine.semantics == .clfsm
//        else {
//            throw ValidationError(message: "Missing attributes in machine", path: Machine.path.attributes)
//        }
//        let actions = machine.semantics == .ucfsm ? ["OnEntry", "OnExit", "Internal"] : ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
//        return State(
//            name: name,
//            actions: actions.map { Action(name: $0, implementation: Code(""), language: .cxx) },
//            transitions: [],
//            attributes: [
//                AttributeGroup(
//                    name: "variables",
//                    fields: [
//                        "state_variables": .table(columns: [
//                            ("type", .expression(language: .cxx)),
//                            ("name", .line),
//                            ("value", .expression(language: .cxx)),
//                            ("comment", .line)
//                        ])
//                    ],
//                    attributes: [
//                        "state_variables": .table(
//                            [],
//                            columns: [
//                                ("type", .expression(language: .cxx)),
//                                ("name", .line),
//                                ("value", .expression(language: .cxx)),
//                                ("comment", .line)
//                            ]
//                        )
//                    ]
//                )
//            ]
//        )
//    }
//
//    func newState(machine: inout Machine) throws {
//        try perform(on: &machine) { machine in
//            if machine.semantics != .clfsm || machine.semantics != .ucfsm {
//                throw MachinesError.unsupportedSemantics(machine.semantics)
//            }
//            let name = "State"
//            if nil == machine.states.first(where: { $0.name == name }) {
//                try machine.states.append(self.createState(named: name, forMachine: machine))
//                self.syncSuspendState(machine: &machine)
//                return
//            }
//            var num = 0
//            var stateName: String
//            repeat {
//                stateName = name + "\(num)"
//                num += 1
//            } while (nil != machine.states.reversed().first(where: { $0.name == stateName }))
//            try machine.states.append(self.createState(named: stateName, forMachine: machine))
//            self.syncSuspendState(machine: &machine)
//        }
//    }
//
//    private func syncSuspendState(machine: inout Machine) {
//        let validValues = Set(machine.states.map(\.name) + [""])
//        let currentValue = machine.attributes[3].attributes["suspend_state"]?.enumeratedValue ?? ""
//        let newValue = validValues.contains(currentValue) ? currentValue : ""
//        machine.attributes[3].fields[0].type = .enumerated(validValues: validValues)
//        machine.attributes[3].attributes["suspend_state"] = .enumerated(newValue, validValues: validValues)
//    }
//
//    func newTransition(source: StateName, target: StateName, condition: Expression?, machine: inout Machine) throws {
//        try perform(on: &machine) { machine in
//            guard
//                let index = machine.states.indices.first(where: { machine.states[$0].name == source }),
//                nil != machine.states.first(where: { $0.name == target })
//            else {
//                throw ValidationError(message: "You must attach a transition to a source and target state", path: Machine.path)
//            }
//            machine.states[index].transitions.append(Transition(condition: condition, target: target))
//        }
//    }
//
//    func delete(states: IndexSet, transitions: IndexSet, machine: inout Machine) throws {
//        try self.perform(on: &machine) { machine in
//            if
//                let initialIndex = machine.states.enumerated().first(where: { $0.1.name == machine.initialState })?.0,
//                states.contains(initialIndex)
//            {
//                throw ValidationError(message: "You cannot delete the initial state", path: Machine.path.states[initialIndex])
//            }
//            machine.states = machine.states.enumerated().filter { !states.contains($0.0) }.map { $1 }
//            self.syncSuspendState(machine: &machine)
//        }
//    }
//
//    func deleteState(atIndex index: Int, machine: inout Machine) throws {
//        try perform(on: &machine) { machine in
//            if machine.states.count >= index {
//                throw ValidationError(message: "Can't delete state that doesn't exist", path: Machine.path.states)
//            }
//            if machine.states[index].name == machine.initialState {
//                throw ValidationError(message: "Can't delete the initial state", path: Machine.path.states[index])
//            }
//            machine.states.remove(at: index)
//            self.syncSuspendState(machine: &machine)
//        }
//    }
//
//    func deleteTransition(atIndex index: Int, attachedTo sourceState: StateName, machine: inout Machine) throws {
//        try perform(on: &machine) { machine in
//            guard let index = machine.states.indices.first(where: { machine.states[$0].name == sourceState }) else {
//                throw ValidationError(message: "Cannot delete a transition attached to a state that does not exist", path: Machine.path.states)
//            }
//            guard machine.states[index].transitions.count >= index else {
//                throw ValidationError(message: "Cannot delete transition that does not exist", path: Machine.path.states[index].transitions)
//            }
//            machine.states[index].transitions.remove(at: index)
//        }
//    }
//
//    func deleteItem<Path, T>(attribute: Path, atIndex index: Int, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
//        try perform(on: &machine) { machine in
//            if machine[keyPath: attribute.path].count <= index || index < 0 {
//                throw ValidationError(message: "Invalid index '\(index)'", path: attribute)
//            }
//            machine[keyPath: attribute.path].remove(at: index)
//        }
//    }
//
//    private func changeName(ofState index: Int, to stateName: StateName, machine: inout Machine) throws {
//        let currentName = machine.states[index].name
//        if currentName == stateName {
//            return
//        }
//        if Set(machine.states.map(\.name)).contains(stateName) {
//            throw ValidationError(message: "Cannot rename state to '\(stateName)' since a state with that name already exists", path: machine.path.states[index].name)
//        }
//        machine[keyPath: machine.path.states[index].name.path] = stateName
//        if machine.initialState == currentName {
//            machine.initialState = stateName
//        }
//        if machine.attributes[3].attributes["suspend_state"]!.enumeratedValue == currentName {
//            machine.attributes[3].attributes["suspend_state"]!.enumeratedValue = stateName
//        }
//        self.syncSuspendState(machine: &machine)
//    }
//
//    private func whitelist(forMachine machine: Machine) -> [AnyPath<Machine>] {
//        let machinePaths = [
//            AnyPath(machine.path.filePath),
//            AnyPath(machine.path.initialState),
//            AnyPath(machine.path.attributes[0].attributes),
//            AnyPath(machine.path.attributes[1].attributes),
//            AnyPath(machine.path.attributes[2].attributes),
//            AnyPath(machine.path.attributes[3].attributes)
//        ]
//        let statePaths: [AnyPath<Machine>] = machine.states.indices.flatMap { (stateIndex) -> [AnyPath<Machine>] in
//            let attributes = [
//                AnyPath(machine.path.states[stateIndex].name),
//                AnyPath(machine.path.states[stateIndex].attributes[0].attributes)
//            ]
//            let actions = machine.states[stateIndex].actions.indices.map {
//                AnyPath(machine.path.states[stateIndex].actions[$0].implementation)
//            }
//            let transitions = machine.states[stateIndex].transitions.indices.flatMap {
//                return [
//                    AnyPath(machine.path.states[stateIndex].transitions[$0].condition),
//                    AnyPath(machine.path.states[stateIndex].transitions[$0].target)
//                ]
//            }
//            return attributes + actions + transitions
//        }
//        return machinePaths + statePaths
//    }
//
//    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine {
//        try perform(on: &machine) { machine in
//            if let index = machine.states.indices.first(where: { Machine.path.states[$0].name.path == attribute.path }) {
//                guard let stateName = value as? StateName else {
//                    throw ValidationError(message: "Invalid value \(value)", path: attribute)
//                }
//                try self.changeName(ofState: index, to: stateName, machine: &machine)
//            }
//            if nil == self.whitelist(forMachine: machine).first(where: { $0.isParent(of: attribute) || $0.isSame(as: attribute) }) {
//                throw ValidationError(message: "Attempting to modify a value which is not allowed to be modified", path: attribute)
//            }
//            machine[keyPath: attribute.path] = value
//        }
//    }
//
//    func validate(machine: Machine) throws {
//        try CXXBaseMachineValidator().validate(machine: machine)
//    }
//
//
}
