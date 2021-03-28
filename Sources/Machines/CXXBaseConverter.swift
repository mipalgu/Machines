//
//  File.swift
//  
//
//  Created by Morgan McColl on 27/3/21.
//

import Foundation
import CXXBase
import UCFSMMachines
import CLFSMMachines
import Attributes

struct CXXBaseConverter {
    
    func machineAttributes(machine: CXXBase.Machine) -> [AttributeGroup] {
        var attributes: [AttributeGroup] = []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "machine_variables", type: .table(columns: [
                    ("type", .expression(language: .cxx)),
                    ("name", .line),
                    ("value", .expression(language: .cxx)),
                    ("comment", .line)
                ]))
            ],
            attributes: [
                "machine_variables": .table(
                    machine.machineVariables.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .cxx)),
                        ("name", .line),
                        ("value", .expression(language: .cxx)),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        )
        attributes.append(variables)
        let funcRefs = AttributeGroup(
            name: "func_refs",
            fields: [
                Field(name: "func_refs", type: .code(language: .cxx))
            ],
            attributes: [
                "func_refs": .code(machine.funcRefs, language: .cxx)
            ],
            metaData: [:]
        )
        attributes.append(funcRefs)
        let includes = AttributeGroup(
            name: "includes",
            fields: [
                Field(name: "include_paths", type: .text),
                Field(name: "includes", type: .code(language: .cxx))
            ],
            attributes: [
                "include_paths": .text(machine.includePaths.reduce("") { $0 == "" ? $1 : $0 + "\n" + $1 }),
                "includes": .code(machine.includes, language: .cxx)
            ],
            metaData: [:]
        )
        attributes.append(includes)
        let settings = AttributeGroup(
            name: "settings",
            fields: [
                Field(name: "suspended_state", type: .enumerated(validValues: Set([""] + machine.states.map(\.name))))
            ],
            attributes: [
                "suspended_state": .enumerated(machine.suspendedState.map { machine.states[$0].name } ?? "", validValues: Set([""] + machine.states.map(\.name)))
            ],
            metaData: [:]
        )
        attributes.append(settings)
        return attributes
    }
    
    func toMachine(machine: CXXBase.Machine, semantics: Machine.Semantics) -> Machine {
        Machine(
            semantics: semantics,
            filePath: machine.path,
            initialState: machine.states[machine.initialState].name,
            states: machine.states.map { state in toState(state: state, transitionsForState: machine.transitions.filter { $0.source == state.name }.sorted(by: { $0.priority < $1.priority }) ) },
            dependencies: [],
            attributes: machineAttributes(machine: machine),
            metaData: []
        )
    }
    
    func toLineAttribute(variable: CXXBase.Variable) -> [LineAttribute] {
        [
            .expression(variable.type, language: .cxx),
            .line(variable.name),
            .expression(variable.value ?? "", language: .cxx),
            .line(variable.comment)
        ]
    }
    
    func stateAttributes(state: CXXBase.State) -> [AttributeGroup] {
        var attributes: [AttributeGroup] = []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                Field(name: "state_variables", type: .table(columns: [
                    ("type", .expression(language: .cxx)),
                    ("name", .line),
                    ("value", .expression(language: .cxx)),
                    ("comment", .line)
                ]))
            ],
            attributes: [
                "state_variables": .table(
                    state.variables.map(toLineAttribute),
                    columns: [
                        ("type", .expression(language: .cxx)),
                        ("name", .line),
                        ("value", .expression(language: .cxx)),
                        ("comment", .line)
                    ]
                )
            ],
            metaData: [:]
        )
        attributes.append(variables)
        return attributes
    }
    
    func toState(state: CXXBase.State, transitionsForState: [CXXBase.Transition]) -> State {
        return State(
            name: state.name,
            actions: state.actions.map{ toAction(actionName: $0.0, code: $0.1) },
            transitions: transitionsForState.map(toTransition),
            attributes: stateAttributes(state: state),
            metaData: []
        )
    }
    
    func toAction(actionName: String, code: String) -> Action {
        Action(name: actionName, implementation: code, language: .cxx)
    }
    
    func toTransition(transition: CXXBase.Transition) -> Transition {
        Transition(
            condition: transition.condition,
            target: transition.target,
            attributes: [],
            metaData: []
        )
    }
    
    func toVariable(variable: [LineAttribute]) -> Variable? {
        guard
            variable.count == 4,
            variable[0].type == .expression(language: .cxx),
            variable[1].type == .line,
            variable[2].type == .expression(language: .cxx),
            variable[3].type == .line
        else {
            return nil
        }
        return Variable(
            type: variable[0].expressionValue,
            name: variable[1].lineValue,
            value: variable[2].expressionValue == "" ? nil : variable[2].expressionValue,
            comment: variable[3].lineValue
        )
    }
    
    func fromAction(action: Action) -> (String, String) {
        (
            action.name,
            action.implementation
        )
    }
    
    func toState(state: State) -> CXXBase.State {
        CXXBase.State(
            name: state.name,
            variables: state.attributes.first { $0.name == "variables" }?.attributes["state_variables"]?.tableValue.compactMap(toVariable) ?? [],
            actions: Dictionary<String, String>(uniqueKeysWithValues: state.actions.map(fromAction))
        )
    }
    
    func toTransition(source: State, transition: Transition, states: [CXXBase.State], index: Int) -> CXXBase.Transition {
        guard let target = (states.first { $0.name == transition.target }) else {
            fatalError("U dun goofed!")
        }
        return CXXBase.Transition(
            source: source.name,
            target: target.name,
            condition: transition.condition ?? "true",
            priority: UInt(index)
        )
    }
    
    func toTransitions(state: State, states: [CXXBase.State]) -> [CXXBase.Transition] {
        state.transitions.enumerated().map { toTransition(source: state, transition: $0.1, states: states, index: $0.0) }
    }
    
    func convert(machine: Machine) throws -> CXXBase.Machine {
        let validator = CXXBaseMachineValidator()
        try validator.validate(machine: machine)
        let cxxStates = machine.states.map(toState)
        let suspendedState = machine.attributes.first { $0.name == "settings" }?.attributes["suspended_state"]?.enumeratedValue
        let suspendedStateName = suspendedState == "" ? nil : suspendedState
        let suspendedIndex = suspendedStateName == nil ? nil : cxxStates.firstIndex { $0.name == suspendedStateName! }
        var actionDisplayOrder: [String] = []
        if machine.semantics == .clfsm {
            actionDisplayOrder = ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        } else if machine.semantics == .ucfsm {
            actionDisplayOrder = ["OnEntry", "OnExit", "Internal"]
        }
        return CXXBase.Machine(
            name: machine.name,
            path: machine.filePath,
            includes: machine.attributes.first { $0.name == "includes" }?.attributes["includes"]?.codeValue ?? "",
            includePaths: machine.attributes.first { $0.name == "includes" }?.attributes["include_paths"]?.textValue.components(separatedBy: .newlines) ?? [],
            funcRefs: machine.attributes.first { $0.name == "func_refs" }?.attributes["func_refs"]?.codeValue ?? "",
            states: cxxStates,
            transitions: machine.states.flatMap { toTransitions(state: $0, states: cxxStates) },
            machineVariables: machine.attributes.first { $0.name == "variables" }?.attributes["machine_variables"]?.tableValue.compactMap(toVariable) ?? [],
            initialState: cxxStates.firstIndex { $0.name == machine.initialState } ?? 0,
            suspendedState: suspendedIndex,
            actionDisplayOrder: actionDisplayOrder
        )
    }
    
}

extension CXXBaseConverter: MachineMutator {
    
    var dependencyLayout: [Field] {
        []
    }
    
    private func perform(on machine: inout Machine, _ f: (inout Machine) throws -> Void) throws {
        let backup = machine
        do {
            try f(&machine)
            try CXXBaseMachineValidator().validate(machine: machine)
        } catch let e {
            machine = backup
            throw e
        }
    }
    
    func addItem<Path, T>(_ item: T, to attribute: Path, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        try perform(on: &machine) { machine in
            machine[keyPath: attribute.path].append(item)
        }
    }
    
    func moveItems<Path, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int) throws where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        try perform(on: &machine) { machine in
            machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
        }
    }
    
    private func createState(named name: String, forMachine machine: Machine) throws -> State {
        guard
            machine.attributes.count == 4,
            machine.semantics == .ucfsm || machine.semantics == .clfsm
        else {
            throw ValidationError(message: "Missing attributes in machine", path: Machine.path.attributes)
        }
        let actions = machine.semantics == .ucfsm ? ["OnEntry", "OnExit", "Internal"] : ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        return State(
            name: name,
            actions: actions.map { Action(name: $0, implementation: Code(""), language: .cxx) },
            transitions: [],
            attributes: [
                AttributeGroup(
                    name: "variables",
                    fields: [
                        "state_variables": .table(columns: [
                            ("type", .expression(language: .cxx)),
                            ("name", .line),
                            ("value", .expression(language: .cxx)),
                            ("comment", .line)
                        ])
                    ],
                    attributes: [
                        "state_variables": .table(
                            [],
                            columns: [
                                ("type", .expression(language: .cxx)),
                                ("name", .line),
                                ("value", .expression(language: .cxx)),
                                ("comment", .line)
                            ]
                        )
                    ]
                )
            ]
        )
    }
    
    func newState(machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            if machine.semantics != .clfsm || machine.semantics != .ucfsm {
                throw MachinesError.unsupportedSemantics(machine.semantics)
            }
            let name = "State"
            if nil == machine.states.first(where: { $0.name == name }) {
                try machine.states.append(self.createState(named: name, forMachine: machine))
                self.syncSuspendState(machine: &machine)
                return
            }
            var num = 0
            var stateName: String
            repeat {
                stateName = name + "\(num)"
                num += 1
            } while (nil != machine.states.reversed().first(where: { $0.name == stateName }))
            try machine.states.append(self.createState(named: stateName, forMachine: machine))
            self.syncSuspendState(machine: &machine)
        }
    }
    
    private func syncSuspendState(machine: inout Machine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[3].attributes["suspend_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[3].fields[0].type = .enumerated(validValues: validValues)
        machine.attributes[3].attributes["suspend_state"] = .enumerated(newValue, validValues: validValues)
    }
    
    func newTransition(source: StateName, target: StateName, condition: Expression?, machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            guard
                let index = machine.states.indices.first(where: { machine.states[$0].name == source }),
                nil != machine.states.first(where: { $0.name == target })
            else {
                throw ValidationError(message: "You must attach a transition to a source and target state", path: Machine.path)
            }
            machine.states[index].transitions.append(Transition(condition: condition, target: target))
        }
    }
    
    func delete(states: IndexSet, transitions: IndexSet, machine: inout Machine) throws {
        try self.perform(on: &machine) { machine in
            if
                let initialIndex = machine.states.enumerated().first(where: { $0.1.name == machine.initialState })?.0,
                states.contains(initialIndex)
            {
                throw ValidationError(message: "You cannot delete the initial state", path: Machine.path.states[initialIndex])
            }
            machine.states = machine.states.enumerated().filter { !states.contains($0.0) }.map { $1 }
            self.syncSuspendState(machine: &machine)
        }
    }
    
    func deleteState(atIndex index: Int, machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            if machine.states.count >= index {
                throw ValidationError(message: "Can't delete state that doesn't exist", path: Machine.path.states)
            }
            if machine.states[index].name == machine.initialState {
                throw ValidationError(message: "Can't delete the initial state", path: Machine.path.states[index])
            }
            machine.states.remove(at: index)
            self.syncSuspendState(machine: &machine)
        }
    }
    
    func deleteTransition(atIndex index: Int, attachedTo sourceState: StateName, machine: inout Machine) throws {
        try perform(on: &machine) { machine in
            guard let index = machine.states.indices.first(where: { machine.states[$0].name == sourceState }) else {
                throw ValidationError(message: "Cannot delete a transition attached to a state that does not exist", path: Machine.path.states)
            }
            guard machine.states[index].transitions.count >= index else {
                throw ValidationError(message: "Cannot delete transition that does not exist", path: Machine.path.states[index].transitions)
            }
            machine.states[index].transitions.remove(at: index)
        }
    }
    
    func deleteItem<Path, T>(attribute: Path, atIndex index: Int, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        try perform(on: &machine) { machine in
            if machine[keyPath: attribute.path].count <= index || index < 0 {
                throw ValidationError(message: "Invalid index '\(index)'", path: attribute)
            }
            machine[keyPath: attribute.path].remove(at: index)
        }
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
        if machine.attributes[3].attributes["suspend_state"]!.enumeratedValue == currentName {
            machine.attributes[3].attributes["suspend_state"]!.enumeratedValue = stateName
        }
        self.syncSuspendState(machine: &machine)
    }
    
    private func whitelist(forMachine machine: Machine) -> [AnyPath<Machine>] {
        let machinePaths = [
            AnyPath(machine.path.filePath),
            AnyPath(machine.path.initialState),
            AnyPath(machine.path.attributes[0].attributes),
            AnyPath(machine.path.attributes[1].attributes),
            AnyPath(machine.path.attributes[2].attributes),
            AnyPath(machine.path.attributes[3].attributes)
        ]
        let statePaths: [AnyPath<Machine>] = machine.states.indices.flatMap { (stateIndex) -> [AnyPath<Machine>] in
            let attributes = [
                AnyPath(machine.path.states[stateIndex].name),
                AnyPath(machine.path.states[stateIndex].attributes[0].attributes)
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
    
    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) throws where Path : PathProtocol, Path.Root == Machine {
        try perform(on: &machine) { machine in
            if let index = machine.states.indices.first(where: { Machine.path.states[$0].name.path == attribute.path }) {
                guard let stateName = value as? StateName else {
                    throw ValidationError(message: "Invalid value \(value)", path: attribute)
                }
                try self.changeName(ofState: index, to: stateName, machine: &machine)
            }
            if nil == self.whitelist(forMachine: machine).first(where: { $0.isParent(of: attribute) || $0.isSame(as: attribute) }) {
                throw ValidationError(message: "Attempting to modify a value which is not allowed to be modified", path: attribute)
            }
            machine[keyPath: attribute.path] = value
        }
    }
    
    func validate(machine: Machine) throws {
        try CXXBaseMachineValidator().validate(machine: machine)
    }
    
    
}
