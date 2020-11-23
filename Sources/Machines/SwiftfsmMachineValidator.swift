/*
 * SwiftfsmMachineValidator.swift
 * Machines
 *
 * Created by Callum McColl on 3/11/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Attributes

struct SwiftfsmMachineValidator: MachineValidator {
    
    private let validator: AnyValidator<Machine> = {
        Machine.path.validate { validator in
            validator.name.alphadash().notEmpty().maxLength(64)
            validator.initialState.in(Machine.path.states, transform: { Set($0.map { $0.name }) })
            //validator.suspendState.in(machine.path.states, transform: { Set($0.map { $0.name }) })
            validator.states.maxLength(128)
            validator.states.each { (stateIndex, state: ValidationPath<ReadOnlyPath<Machine, State>>) in
                state.name
                    .alphadash()
                    .notEmpty()
                    .maxLength(64)
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
                    variables.attributes["state_variables"].required()
                    variables.attributes["state_variables"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, stateVariable) in
                            stateVariable[0].enumeratedValue.in(["let", "var"])
                            stateVariable[1].lineValue.notEmpty().maxLength(128)
                            stateVariable[2].expressionValue.notEmpty().maxLength(128)
                            stateVariable[3].expressionValue.maxLength(128)
                        }
                    }
                }
                state.attributes[1].validate { settings in
                    settings.attributes["access_external_variables"].required()
                    settings.attributes["access_external_variables"].wrappedValue
                        .if { $0.boolValue } then: {
                            settings.attributes["external_variables"].required()
                            settings.attributes["external_variables"].wrappedValue.enumerableCollectionValue.each { (_, external) in
                                external.in(Machine.path.attributes[0].attributes["external_variables"].wrappedValue.tableValue) {
                                    Set($0.map { $0[1].lineValue })
                                }
                            }
                            settings.attributes["imports"].required()
                            settings.attributes["imports"].wrappedValue.codeValue.maxLength(10240)
                        }
                }
            }
            validator.attributes.length(3)
            validator.attributes.validate { attributes in
                attributes[0].validate { variables in
                    variables.attributes["external_variables"].required()
                    variables.attributes["external_variables"].wrappedValue.tableValue.validate { table in
                        table.unique { $0.map { $0[1].lineValue } }
                        table.each { (_, externalVariables) in
                            externalVariables[0].enumeratedValue.in(["actuator", "sensor", "external"])
                            externalVariables[1].lineValue.notEmpty().maxLength(128)
                            externalVariables[2].expressionValue.notEmpty().maxLength(128)
                            externalVariables[3].expressionValue.notEmpty().maxLength(128)
                        }
                    }
                    variables.attributes["machine_variables"].required()
                    variables.attributes["machine_variables"].wrappedValue.tableValue.validate { table in
                        table.unique() { $0.map { $0[1].lineValue } }
                        table.each { (_, machineVariables) in
                            machineVariables[0].enumeratedValue.in(["let", "var"])
                            machineVariables[1].lineValue.notEmpty().maxLength(128)
                            machineVariables[2].expressionValue.notEmpty().maxLength(128)
                            machineVariables[3].expressionValue.maxLength(128)
                        }
                    }
                    variables.attributes["parameters"].required()
                    variables.attributes["parameters"].wrappedValue.complexValue.validate { attributes in
                        attributes["enable_parameters"].required().if { $0.boolValue } then: {
                            attributes["parameters"].required()
                            attributes["parameters"].wrappedValue.tableValue.validate { table in
                                table.unique() { $0.map { $0[0].lineValue } }
                                table.each { (_, parameters) in
                                    parameters[0].lineValue.notEmpty().maxLength(128)
                                    parameters[1].expressionValue.notEmpty().maxLength(128)
                                    parameters[2].expressionValue.maxLength(128)
                                }
                            }
                            attributes["result_type"].required()
                            attributes["result_type"].wrappedValue.expressionValue.notEmpty().maxLength(128)
                        }
                    }
                }
                attributes[1].validate { ringlet in
                    ringlet.attributes["use_custom_ringlet"].required()
                        .if { $0.boolValue }
                        then: {
                            ringlet.attributes["actions"].required()
                            ringlet.attributes["actions"].wrappedValue.collectionValue.validate { collection in
                                collection.notEmpty()
                                collection.unique { $0.map(\.lineValue) }
                                collection.each { (_, action) in
                                    action.lineValue.alphadash().notEmpty().maxLength(128)
                                }
                            }
                            ringlet.attributes["ringlet_variables"].required()
                            ringlet.attributes["ringlet_variables"].wrappedValue.tableValue.validate { table in
                                table.unique() { $0.map { $0[1].lineValue } }
                                table.each { (_, ringletVariables) in
                                    ringletVariables[0].enumeratedValue.in(["let", "var"])
                                    ringletVariables[1].lineValue.notEmpty().maxLength(128)
                                    ringletVariables[2].expressionValue.notEmpty().maxLength(128)
                                    ringletVariables[3].expressionValue.maxLength(128)
                                }
                            }
                            ringlet.attributes["imports"].required()
                            ringlet.attributes["imports"].wrappedValue.codeValue.maxLength(10240)
                            ringlet.attributes["execute"].required()
                            ringlet.attributes["execute"].wrappedValue.codeValue.maxLength(10240)
                        }
                }
                attributes[2].validate { settings in
                    settings.attributes["suspend_state"].required()
                    settings.attributes["suspend_state"].wrappedValue.enumeratedValue.validate { suspendState in
                        suspendState.in(Machine.path.states, transform: { Set($0.map {$0.name} + [""]) })
                    }
                    settings.attributes["module_dependencies"].required()
                    settings.attributes["module_dependencies"].wrappedValue.complexValue.validate { moduleDependencies in
                        moduleDependencies["packages"].required()
                        moduleDependencies["packages"].wrappedValue.collectionValue.each { (packageIndex, packageRow) in
                            packageRow.complexValue.validate { package in
                                package["products"].required()
                                package["products"].wrappedValue.collectionValue.validate { collection in
                                    collection.unique() { $0.map { $0.lineValue } }
                                    collection.each { (_, product) in
                                        product.lineValue.notEmpty().maxLength(128)
                                    }
                                }
                                package["qualifiers"].wrappedValue.collectionValue.validate { collection in
                                    collection.unique() { $0.map(\.lineValue) }
                                    collection.each { (_, product) in
                                        product.lineValue.notEmpty().maxLength(128)
                                    }
                                }
                                package["targets_to_import"].wrappedValue.collectionValue.validate { collection in
                                    collection.unique() { $0.map(\.lineValue) }
                                    collection.each { (_, product) in
                                        product.lineValue.notEmpty().maxLength(128)
                                    }
                                }
                                package["url"].wrappedValue.collectionValue.validate { collection in
                                    collection.unique() { $0.map(\.lineValue) }
                                    collection.each { (_, product) in
                                        product.lineValue.notEmpty().maxLength(128)
                                    }
                                }
                            }
                        }
                        moduleDependencies.validate { moduleDependencies in
                            moduleDependencies["system_imports"].required()
                            moduleDependencies["system_imports"].wrappedValue.codeValue.maxLength(10240)
                            moduleDependencies["system_includes"].required()
                            moduleDependencies["system_includes"].wrappedValue.codeValue.maxLength(10240)
                            moduleDependencies["swift_search_paths"].required()
                            moduleDependencies["swift_search_paths"].wrappedValue.collectionValue.each { (_, swiftSearchPath) in
                                swiftSearchPath.lineValue.notEmpty().maxLength(1024)
                            }
                            moduleDependencies["c_header_search_paths"].required()
                            moduleDependencies["c_header_search_paths"].wrappedValue.collectionValue.each { (_, cHeaderSearchPaths) in
                                cHeaderSearchPaths.lineValue.notEmpty().maxLength(1024)
                            }
                            moduleDependencies["linker_search_paths"].required()
                            moduleDependencies["linker_search_paths"].wrappedValue.collectionValue.each { (_, linkerSearchPaths) in
                                linkerSearchPaths.lineValue.notEmpty().maxLength(1024)
                            }
                        }
                    }
                }
            }
        }
    }()
    
    func validate(machine: Machine) throws {
        if machine.semantics != .swiftfsm {
            throw MachinesError.unsupportedSemantics(machine.semantics)
        }
        try self.validator.performValidation(machine)
    }
    
}
