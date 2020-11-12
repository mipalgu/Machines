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
    
    func validate(machine: Machine) throws {
        if machine.semantics != .swiftfsm {
            throw ValidationError.unsupportedSemantics(machine.semantics)
        }
        try self.validate(machine)
    }
    
    private func validate(_ machine: Machine) throws {
        try machine.validate { (validator: ValidationPath<Path<Machine, Machine>>) in
            validator.name.alphadash().notEmpty().maxLength(64)
            validator.initialState.in(machine.path.states, transform: { Set($0.map { $0.name }) })
            //validator.suspendState.in(machine.path.states, transform: { Set($0.map { $0.name }) })
            validator.states.maxLength(128)
            validator.states.each { (state: ValidationPath<ReadOnlyPath<Machine, State>>) in
                state.name
                    .alphadash()
                    .notEmpty()
                    .maxLength(64)
                state.attributes.length(2)
                state.attributes[1].validate { settings in
                    settings.name.equals("settings")
                    settings.fields["access_external_variables"].required()
                    settings.fields["access_external_variables"].wrappedValue.equals(AttributeType.bool)
                    settings.attributes["access_external_variables"].required()
                    settings.attributes["access_external_variables"].wrappedValue
                        .if { $0.boolValue ?? false } then: {
                            settings.fields["imports"].required()
                            settings.fields["imports"].wrappedValue.equals(AttributeType.code(language: .swift))
                            settings.attributes["imports"].required()
                            settings.attributes["imports"].wrappedValue.codeValue.required()
                            settings.attributes["imports"].wrappedValue.codeValue.wrappedValue.maxLength(1024)
                        }
                }
            }
            validator.transitions.maxLength(128)
            validator.transitions.each { transition in
                transition.source.if { $0 != nil } then: {
                    transition.source.wrappedValue.in(machine.path.states, transform: { Set($0.map { $0.name }) })
                }
                transition.target.if { $0 != nil } then: {
                    transition.target.wrappedValue.in(machine.path.states, transform: { Set($0.map { $0.name }) })
                }
                transition.condition.if { $0 != nil } then: {
                    transition.condition.wrappedValue.maxLength(1024)
                }
                transition.attributes.empty()
            }
            validator.attributes.length(5)
            validator.attributes.validate { attributes in
                attributes[0].validate { variables in
                    variables.name.equals("variables")
                }
                attributes[1].validate { parameters in
                    parameters.name.equals("parameters")
                }
                attributes[2].validate { ringlet in
                    ringlet.name.equals("ringlet")
                    ringlet.attributes["use_custom_ringlet"].required()
                        .if { $0?.boolValue ?? false }
                        then: {
                            ringlet.attributes["ringlet_variables"].required()
//                            ringlet.attributes["ringlet_variables"].wrappedValue.validate { table in
//                                list.enabled.equalsTrue()
//                            }
                        }
                }
                attributes[3].validate { moduleDependencies in
                    moduleDependencies.name.equals("module_dependencies")
                }
                attributes[4].validate { settings in
                    settings.name.equals("settings")
                    settings.fields["suspend_state"].required()
                    settings.fields["suspend_state"].wrappedValue.equals(AttributeType.enumerated(validValues: Set(machine.states.map { $0.name })))
                    settings.attributes["suspend_state"].required()
                    settings.attributes["suspend_state"].wrappedValue.enumeratedValue.required()
                    settings.attributes["suspend_state"].wrappedValue.enumeratedValue.wrappedValue.in(Machine.path.states, transform: { Set($0.map {$0.name}) })
                }
            }
        }
    }
    
}
