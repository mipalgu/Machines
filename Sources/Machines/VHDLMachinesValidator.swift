//
//  File.swift
//  
//
//  Created by Morgan McColl on 16/4/21.
//

import Foundation
import Attributes

class VHDLMachinesValidator: MachineValidator {
    
    private let dataTypes: Set<String> = [
        "std_logic",
        "std_ulogic",
        "signed",
        "unsigned",
        "std_logic_vector",
        "std_ulogic_vector",
        "bit",
        "boolean",
        "bit_vector",
        "integer",
        "natural",
        "positive"
    ]
    
    private let vhdlTypes: Set<String> = [
        "signal",
        "variable"
    ]
    
    private let reservedWords: Set<String> = [
        "abs", "access", "after", "alias", "all", "and", "architecture", "array",
        "assert", "attribute", "begin", "block", "body", "buffer", "bus", "case",
        "component", "configuration", "constant", "disconnect", "downto", "else",
        "elsif", "end", "entity", "exit", "file", "for", "function", "generate",
        "generic", "group", "guarded", "if", "impure", "in", "inertial", "inout",
        "is", "label", "library", "linkage", "literal", "loop", "map", "mod", "nand",
        "new", "next", "nor", "not", "null", "of", "on", "open", "or", "others",
        "out", "package", "port", "postponed", "procedure", "process", "pure",
        "range", "record", "register", "reject", "return", "rol", "ror", "select",
        "severity", "signal", "shared", "sla", "sli", "sra", "srl", "subtype",
        "then", "to", "transport", "type", "unaffected", "units", "until", "use",
        "variable", "wait", "when", "while", "with", "xnor", "xor"
    ]
    
    private var allReservedWords: Set<String> {
        dataTypes.union(vhdlTypes).union(reservedWords)
    }
    
    private lazy var validator: AnyValidator<Machine> = {
        Machine.path.validate { validator in
            validator.name.alphadash().notEmpty().maxLength(64)
            validator.initialState.in(Machine.path.states, transform: { Set($0.map { $0.name }) })
            validator.states.maxLength(128)
            validator.states.each { (stateIndex, state: ValidationPath<ReadOnlyPath<Machine, State>>) in
                state.name
                    .notEmpty()
                    .alphafirst()
                    .alphaunderscore()
                    .maxLength(64)
                state.actions.unique() { $0.map { $0.name } }
                state.actions.length(5)
                state.actions.each { (_, action) in
                    action.name.in(["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"])
                }
                state.actions.each { (_, action) in
                    action.implementation.maxLength(2048)
                    action.language.equals(.vhdl)
                }
                state.transitions.maxLength(128)
                state.transitions.each { (_, transition) in
                    transition.target.in(Machine.path.states, transform: { Set($0.map { $0.name }) })
                    transition.condition.if { $0 != nil } then: {
                        transition.condition.wrappedValue.maxLength(1024)
                    }
                    transition.attributes.empty()
                }
                state.attributes.length(2)
                state.attributes[0].validate { variables in
                    variables.attributes["externals"].required()
                    variables.attributes["externals"].wrappedValue.blockAttribute.enumerableCollectionValue.each { (_, external) in
                        external.in(Machine.path.attributes[0].attributes["externals"].wrappedValue.tableValue) {
                            Set($0.map { $0[1].lineValue })
                        }
                    }
                    variables.attributes["state_signals"].required()
                    variables.attributes["state_signals"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, stateSignal) in
                            stateSignal[0].expressionValue.notEmpty().maxLength(128)
                            stateSignal[1].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            stateSignal[2].expressionValue.maxLength(128)
                            stateSignal[3].lineValue.maxLength(128)
                        }
                    }
                    variables.attributes["state_variables"].required()
                    variables.attributes["state_variables"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[3].lineValue } }
                        table.each { (_, stateVariable) in
                            stateVariable[0].expressionValue.notEmpty().maxLength(128)
                            stateVariable[1].lineValue.numeric()
                            stateVariable[2].lineValue.numeric()
                            stateVariable[3].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            stateVariable[4].expressionValue.maxLength(128)
                            stateVariable[5].lineValue.maxLength(128)
                        }
                    }
                }
                state.attributes[1].validate { actions in
                    actions.attributes["action_names"].required()
                    actions.attributes["action_names"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[0].lineValue } }
                        table.each { (_, actionName) in
                            actionName[0].lineValue.notEmpty().alpha().blacklist(self.allReservedWords).maxLength(128)
                        }
                    }
                    actions.attributes["action_order"].required()
                    actions.attributes["action_order"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].enumeratedValue } }
                        table.each { (_, actionSlot) in
                            actionSlot[0].integerValue.between(min: 0, max: 128)
                            actionSlot[1].enumeratedValue.notEmpty().alpha().maxLength(128)
                        }
                    }
                }
            }
            validator.attributes.length(3)
            validator.attributes.validate { attributes in
                attributes[0].validate { variables in
                    variables.attributes["clocks"].required()
                    variables.attributes["clocks"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[0].lineValue } }
                        table.each { (_, clock) in
                            clock[0].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            clock[1].integerValue.between(min: 0, max: 999)
                            clock[2].enumeratedValue.notEmpty().alpha().maxLength(3)
                        }
                    }
                    variables.attributes["external_signals"].required()
                    variables.attributes["external_signals"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[2].lineValue } }
                        table.each { (_, signal) in
                            signal[0].enumeratedValue.notEmpty().alpha().maxLength(6)
                            signal[1].expressionValue.notEmpty().alphadash().maxLength(128)
                            signal[2].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            signal[3].expressionValue.maxLength(128)
                            signal[4].lineValue.maxLength(128)
                        }
                    }
                    variables.attributes["external_variables"].required()
                    variables.attributes["external_variables"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[2].lineValue } }
                        table.each { (_, variable) in
                            variable[0].enumeratedValue.notEmpty().alpha().maxLength(6)
                            variable[1].expressionValue.notEmpty().maxLength(128)
                            variable[2].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            variable[3].expressionValue.maxLength(128)
                            variable[4].lineValue.maxLength(128)
                        }
                    }
                    variables.attributes["machine_signals"].required()
                    variables.attributes["machine_signals"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, variable) in
                            variable[0].expressionValue.notEmpty().maxLength(128)
                            variable[1].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            variable[2].expressionValue.maxLength(128)
                            variable[3].lineValue.maxLength(128)
                        }
                    }
                    variables.attributes["machine_variables"].required()
                    variables.attributes["machine_variables"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, variable) in
                            variable[0].expressionValue.notEmpty().maxLength(128)
                            variable[1].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            variable[2].expressionValue.maxLength(128)
                            variable[3].lineValue.maxLength(128)
                        }
                    }
                    variables.attributes["driving_clock"].required()
                    variables.attributes["driving_clock"].wrappedValue.enumeratedValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                }
                attributes[0].validate { variables in
                    variables.attributes["generics"].required()
                    variables.attributes["generics"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, variable) in
                            variable[0].expressionValue.notEmpty().maxLength(128)
                            variable[1].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            variable[2].expressionValue.maxLength(128)
                            variable[3].lineValue.maxLength(128)
                        }
                    }
                }
                attributes[1].validate { parameters in
                    parameters.attributes["is_parameterised"].required()
                    parameters.attributes["parameter_signals"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, variable) in
                            variable[0].expressionValue.notEmpty().maxLength(128)
                            variable[1].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            variable[2].expressionValue.maxLength(128)
                            variable[3].lineValue.maxLength(128)
                        }
                    }
                    parameters.attributes["parameter_variables"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, variable) in
                            variable[0].expressionValue.notEmpty().maxLength(128)
                            variable[1].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            variable[2].expressionValue.maxLength(128)
                            variable[3].lineValue.maxLength(128)
                        }
                    }
                    parameters.attributes["outputs"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, variable) in
                            variable[0].expressionValue.notEmpty().maxLength(128)
                            variable[1].lineValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(128)
                            variable[2].lineValue.maxLength(128)
                        }
                    }
                }
                attributes[2].validate { includes in
                    includes.attributes["includes"].required()
                    includes.attributes["includes"].wrappedValue.codeValue.maxLength(2048)
                }
                attributes[3].validate { settings in
                    settings.attributes["initial_state"].required()
                    settings.attributes["initial_state"].wrappedValue.enumeratedValue.notEmpty().alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(64)
                    settings.attributes["suspended_state"].required()
                    settings.attributes["suspended_state"].wrappedValue.enumeratedValue.alphafirst().alphaunderscore().blacklist(self.allReservedWords).maxLength(64)
                }
            }
        }
    }()
    
    func validate(machine: Machine) throws {
        if machine.semantics != .vhdl {
            throw MachinesError.unsupportedSemantics(machine.semantics)
        }
        try self.validator.performValidation(machine)
    }
    
    
}
