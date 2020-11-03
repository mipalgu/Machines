/*
 * Machine+SwiftMachinesConvertible.swift
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

import Foundation
import SwiftMachines

extension Machine: SwiftMachinesConvertible {
    
    /// Convert a `SwiftMachines.Machine` to a `Machine`.
    public init(from swiftMachine: SwiftMachines.Machine) {
        var attributes: [AttributeGroup] = []
        if let model = swiftMachine.model {
            let group = AttributeGroup(
                name: "ringlet",
                variables: VariableList(
                    name: "ringlet_variables",
                    enabled: true,
                    variables: model.ringlet.vars.map {
                        Variable(
                            label: $0.label,
                            type: $0.type,
                            extraFields: [
                                "access_type": .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                                "initial_value": .expression($0.initialValue ?? "", language: .swift)
                            ]
                        )
                    },
                    extraFields: [
                        "access_type": .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                        "initial_value": .expression(language: .swift)
                    ]
                ),
                fields: [
                    "use_custom_ringlet": .bool,
                    "actions": .collection(type: .line),
                    "imports": .code(language: .swift),
                    "execute": .code(language: .swift)
                ],
                attributes: [
                    "use_custom_ringlet": .bool(true),
                    "actions": .collection(lines: model.actions),
                    "imports": .code(model.ringlet.imports, language: .swift),
                    "execute": .code(model.ringlet.execute, language: .swift)
                ]
            )
            attributes.append(group)
        } else {
            let group = AttributeGroup(
                name: "ringlet",
                variables: nil,
                fields: [
                    "use_custom_ringlet": .bool
                ],
                attributes: [
                    "use_custom_ringlet": .bool(false)
                ]
            )
            attributes.append(group)
        }
        let moduleDependencies = AttributeGroup(
            name: "module_dependencies",
            fields: [
                "packages": .collection(type: .complex(layout: [
                    "products": .collection(type: .line),
                    "qualifiers": .collection(type: .line),
                    "targets_to_import": .collection(type: .line),
                    "url": .line
                ])),
                "system_imports": .code(language: .swift),
                "system_includes": .code(language: .c),
                "swift_search_paths": .collection(type: .line),
                "c_header_search_paths": .collection(type: .line),
                "linker_search_paths": .collection(type: .line)
            ],
            attributes: [
                "packages": .collection(
                    complex: swiftMachine.packageDependencies.map {
                        [
                            "products": .collection(lines: $0.products),
                            "qualifiers": .collection(lines: $0.qualifiers),
                            "targets_to_import": .collection(lines: $0.targets),
                            "url": .line($0.url)
                        ]
                    },
                    layout: [
                        "products": .collection(type: .line),
                        "qualifiers": .collection(type: .line),
                        "targets_to_import": .collection(type: .line),
                        "url": .line
                    ]
                ),
                "system_imports": .code(swiftMachine.imports, language: .swift),
                "system_includes": .code(swiftMachine.includes ?? "", language: .c),
                "swift_search_paths": .collection(lines: swiftMachine.swiftIncludeSearchPaths),
                "c_header_search_paths": .collection(lines: swiftMachine.includeSearchPaths),
                "linker_search_paths": .collection(lines: swiftMachine.libSearchPaths)
            ]
        )
        attributes.append(moduleDependencies)
        let states = swiftMachine.states.map { (state) -> State in
            let settingsFields: [String: AttributeType]
            let settingsAttributes: [String: Attribute]
            if let externals = state.externalVariables {
                settingsFields = [
                    "access_external_variables": .bool,
                    "external_variables": .enumerableCollection(validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                    "imports": .text
                ]
                settingsAttributes = [
                    "access_external_variables": .bool(true),
                    "external_variables": .enumerableCollection(Set(externals.map { $0.label }), validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                    "imports": .text(state.imports)
                ]
            } else {
                settingsFields = [
                    "access_external_variables": .bool
                ]
                settingsAttributes = [
                    "access_external_variables": .bool(false)
                ]
            }
            return State(
                name: state.name,
                actions: Dictionary(uniqueKeysWithValues: state.actions.map { ($0.name, $0.implementation) }),
                variables: [
                    VariableList(
                        name: "state_variables",
                        enabled: true,
                        variables: state.vars.map {
                            Variable(
                                label: $0.label,
                                type: $0.type,
                                extraFields: [
                                    "access_type": .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                                    "initial_value": .expression($0.initialValue ?? "", language: .swift)
                                ]
                            )
                        },
                        extraFields: [
                            "access_type": .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                            "initial_value": .expression(language: .swift)
                        ]
                    )
                ],
                attributes: [
                    AttributeGroup(
                        name: "settings",
                        fields: settingsFields,
                        attributes: settingsAttributes
                    )
                ]
            )
        }
        let transitions = swiftMachine.states.flatMap { state in
            state.transitions.map {
                Transition(condition: $0.condition, source: state.name, target: $0.target)
            }
        }
        let variables = [
            VariableList(
                name: "external_variables",
                enabled: true,
                variables: swiftMachine.externalVariables.map {
                    Variable(
                        label: $0.label,
                        type: $0.type,
                        extraFields: [
                            "access_type": .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                            "value": .expression($0.initialValue ?? "", language: .swift)
                        ]
                    )
                },
                extraFields: [
                    "access_type": .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                    "value": .expression(language: .swift)
                ]
            ),
            VariableList(
                name: "parameters",
                enabled: swiftMachine.parameters != nil,
                variables: (swiftMachine.parameters ?? []).map {
                    Variable(
                        label: $0.label,
                        type: $0.type,
                        extraFields: [
                            "default_value": .expression($0.initialValue ?? "", language: .swift)
                        ]
                    )
                },
                extraFields: [
                    "default_value": .expression(language: .swift)
                ],
                attributes: [
                    "result_type": .expression(swiftMachine.returnType ?? "", language: .swift)
                ]
            ),
            VariableList(
                name: "fsm_variables",
                enabled: true,
                variables: swiftMachine.vars.map {
                    Variable(
                        label: $0.label,
                        type: $0.type,
                        extraFields: [
                            "access_type": .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                            "initial_value": .expression($0.initialValue ?? "", language: .swift)
                        ]
                    )
                },
                extraFields: [
                    "access_type": .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                    "initial_value": .expression(language: .swift)
                ]
            )
        ]
        self.init(
            semantics: .swiftfsm,
            name: swiftMachine.name,
            filePath: swiftMachine.filePath,
            initialState: swiftMachine.initialState.name,
            suspendState: swiftMachine.suspendState?.name ?? swiftMachine.initialState.name,
            states: states,
            transitions: transitions,
            variables: variables,
            attributes: attributes,
            metaData: []
        )
    }
    
    /// Convert the meta model machine to a `SwiftMachines.Machine`.
    public func swiftMachine() throws -> SwiftMachines.Machine {
        return try SwiftfsmConverter(validator: SwiftfsmMachineValidator()).swiftMachine(self)
    }
    
    public static func createSwiftMachine(_ name: String, atPath url: URL) -> Machine {
        let swiftMachine = SwiftMachines.Machine(
            name: name,
            filePath: url,
            externalVariables: [],
            packageDependencies: [],
            swiftIncludeSearchPaths: [],
            includeSearchPaths: [],
            libSearchPaths: [],
            imports: "",
            includes: nil,
            vars: [],
            model: nil,
            parameters: nil,
            returnType: nil,
            initialState: SwiftMachines.State(
                name: "Initial",
                imports: "",
                externalVariables: nil,
                vars: [],
                actions: [Action(name: "onEntry", implementation: ""), Action(name: "onExit", implementation: ""), Action(name: "main", implementation: "")],
                transitions: []
            ),
            suspendState: SwiftMachines.State(
                name: "Suspend",
                imports: "",
                externalVariables: nil,
                vars: [],
                actions: [Action(name: "onEntry", implementation: ""), Action(name: "onExit", implementation: ""), Action(name: "main", implementation: "")],
                transitions: []
            ),
            states: [
                SwiftMachines.State(
                    name: "Initial",
                    imports: "",
                    externalVariables: nil,
                    vars: [],
                    actions: [Action(name: "onEntry", implementation: ""), Action(name: "onExit", implementation: ""), Action(name: "main", implementation: "")],
                    transitions: []
                ),
                SwiftMachines.State(
                    name: "Suspend",
                    imports: "",
                    externalVariables: nil,
                    vars: [],
                    actions: [Action(name: "onEntry", implementation: ""), Action(name: "onExit", implementation: ""), Action(name: "main", implementation: "")],
                    transitions: []
                )
            ],
            submachines: [],
            callableMachines: [],
            invocableMachines: []
        )
        return Machine(from: swiftMachine)
    }
    
}
