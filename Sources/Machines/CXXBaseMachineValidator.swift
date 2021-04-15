//
//  CXXBaseMachineValidator.swift
//  
//
//  Created by Morgan McColl on 27/3/21.
//

import Foundation
import Attributes

struct CXXBaseMachineValidator: MachineValidator {
    
    private var validator: AnyValidator<Machine> = {
        Machine.path.validate { validator in
            validator.name.alphadash().notEmpty().maxLength(64)
            validator.initialState.in(Machine.path.states, transform: { Set($0.map { $0.name }) })
            validator.states.maxLength(128)
            validator.states.each { (stateIndex, state: ValidationPath<ReadOnlyPath<Machine, State>>) in
                state.name
                    .alphadash()
                    .notEmpty()
                    .maxLength(64)
                state.actions.unique() { $0.map { $0.name } }
                validator.semantics.if { $0 == .clfsm || $0 == .spartanfsm } then: {
                    state.actions.length(5)
                    state.actions.each { (_, action) in
                        action.name.in(["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"])
                    }
                }
                validator.semantics.if { $0 == .ucfsm } then: {
                    state.actions.length(3)
                    state.actions.each { (_, action) in
                        action.name.in(["OnEntry", "OnExit", "Internal"])
                    }
                }
                state.actions.each { (_, action) in
                    action.implementation.maxLength(2048)
                    action.language.equals(.cxx)
                }
                state.transitions.maxLength(128)
                state.transitions.each { (_, transition) in
                    transition.target.in(Machine.path.states, transform: { Set($0.map { $0.name }) })
                    transition.condition.if { $0 != nil } then: {
                        transition.condition.wrappedValue.maxLength(1024)
                    }
                    transition.attributes.empty()
                }
                state.attributes.length(1)
                state.attributes[0].validate { variables in
                    variables.attributes["state_variables"].required()
                    variables.attributes["state_variables"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, stateVariable) in
                            stateVariable[0].expressionValue.notEmpty().maxLength(128)
                            stateVariable[1].lineValue.notEmpty().maxLength(128)
                            stateVariable[2].expressionValue.maxLength(128)
                            stateVariable[3].lineValue.maxLength(128)
                        }
                    }
                }
            }
            validator.attributes.length(4)
            validator.attributes.validate { attributes in
                attributes[0].validate { variables in
                    variables.attributes["machine_variables"].required()
                    variables.attributes["machine_variables"].wrappedValue.tableValue.validate { table in
                        table.unique { $0.map { $0[1].lineValue } }
                        table.each { (_, machineVariables) in
                            machineVariables[0].expressionValue.notEmpty().maxLength(128)
                            machineVariables[1].lineValue.notEmpty().maxLength(128)
                            machineVariables[2].expressionValue.maxLength(128)
                            machineVariables[3].lineValue.maxLength(128)
                        }
                    }
                }
                attributes[1].attributes["func_refs"].required()
                attributes[1].attributes["func_refs"].wrappedValue.codeValue.maxLength(2048)
                attributes[2].attributes["include_paths"].required()
                attributes[2].attributes["include_paths"].wrappedValue.textValue.maxLength(2048)
                attributes[2].attributes["includes"].required()
                attributes[2].attributes["includes"].wrappedValue.codeValue.maxLength(2048)
                attributes[3].attributes["suspended_state"].wrappedValue.enumeratedValue.in(Machine.path.states, transform: { Set([""] + $0.map { $0.name }) })
            }
        }
    }()
    
    func validate(machine: Machine) throws {
        if machine.semantics != .ucfsm && machine.semantics != .clfsm && machine.semantics != .spartanfsm {
            throw MachinesError.unsupportedSemantics(machine.semantics)
        }
        try self.validator.performValidation(machine)
    }
    
}
