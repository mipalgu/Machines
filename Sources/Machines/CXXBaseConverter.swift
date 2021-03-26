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
    
    func initial(filePath: URL, semantics: Machine.Semantics) -> Machine? {
        var parsedMachine: CXXBase.Machine?
        switch semantics {
            case .clfsm: parsedMachine = CXXBase.Machine(clfsmMachineAtPath: filePath)
            case .ucfsm: parsedMachine = CXXBase.Machine(ucfsmMachineAtPath: filePath)
            default: parsedMachine = nil
        }
        guard let machine = parsedMachine else {
            return nil
        }
        return toMachine(machine: machine, semantics: semantics)
    }
    
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
            states: machine.states.map { state in toState(state: state, transitionsForState: machine.transitions.filter { $0.source.name == state.name }.sorted(by: { $0.priority < $1.priority }) ) },
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
            target: transition.target.name,
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
            source: toState(state: source),
            target: target,
            condition: transition.condition ?? "true",
            priority: UInt(index)
        )
    }
    
    func toTransitions(state: State, states: [CXXBase.State]) -> [CXXBase.Transition] {
        state.transitions.enumerated().map { toTransition(source: state, transition: $0.1, states: states, index: $0.0) }
    }
    
    func convert(machine: Machine) -> CXXBase.Machine {
        let cxxStates = machine.states.map(toState)
        let suspendedState = machine.attributes.first { $0.name == "settings" }?.attributes["suspended_state"]?.enumeratedValue
        let suspendedStateName = suspendedState == "" ? nil : suspendedState
        let suspendedIndex = suspendedStateName == nil ? nil : cxxStates.firstIndex { $0.name == suspendedStateName! }
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
            suspendedState: suspendedIndex
        )
    }
    
}
