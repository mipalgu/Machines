/*
 * Machine.swift
 * Machines
 *
 * Created by Callum McColl on 18/9/18.
 * Copyright © 2018 Callum McColl. All rights reserved.
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

import SwiftMachines
import Foundation

/// A general meta model machine.
///
/// This type is responsible for representing all possible supported semantics
/// provided by an LLFSM scheduler (swiftfsm, clfsm for example). Because the
/// meta model needs to be able to represent a wide array of semantics, this
/// data structures --- as well as other general data structures this type
/// depends on --- take a minimalistic view of LLFSM semantics. The idea here
/// is to establish a semantics within the meta model which all schedulers
/// share. Any additional data that is required for custom semantics of a
/// particular scheduler is enabled through the use of `Attribute`s and
/// `AttributeGroup`s which provide a type agnostic interface for specifying
/// such data.
///
/// Importantly, the meta model needs to be convertible to the underlying data
/// structures for specific concrete implementations --- `SwiftMachines.Machine`
/// for swiftfsm machines for example.
///
/// - SeeAlso: `SwiftMachinesConvertible`.
public struct Machine: Hashable, Codable {
    
    public struct ConversionError: Error, Hashable, Codable {
        
        public var message: String
        
    }
    
    public enum Semantics: String, Hashable, Codable {
        case other
        case swiftfsm
        case clfsm
    }
    
    /// The underlying semantics which this meta machine follows.
    public private(set) var semantics: Semantics
    
    /// The name of the machine.
    public var name: String
    
    /// The path to the .machine directory on the file system.
    public var filePath: URL
    
    /// The name of the initial state.
    ///
    /// The name should represent the name of a state within the `states` array.
    public var initialState: StateName
    
    /// The name of the suspendState.
    ///
    /// The suspend state is the state that, when it is the current state,
    /// denotes that the machine is suspended. The name of the suspendState
    /// should represent the name of a state within the `states` array.
    public var suspendState: StateName
    
    /// The accepting states of the machine.
    ///
    /// An accepting state is a state without any transitions.
    ///
    /// - Complexity: O(n * m) where n is the length of the `states` array and
    /// m is the length of the `transitions` array.
    public var acceptingStates: [State] {
        return self.states.filter { state in
            nil != self.transitions.first { $0.source == state.name }
        }
    }
    
    /// All states within the machine.
    public var states: [State]
    
    /// All transitions within the machine --- attached or unattached to states.
    public var transitions: [Transition]
    
    /// A list of variables denotes by unique names.
    ///
    /// This list is used to represent different types of variables that are
    /// accessed at the machine level --- accessible from any state within the
    /// machine. This includes, for example, external variables, fsm variables
    /// and parameters.
    public var variables: [VariableList]
    
    /// A list of attributes specifying additional fields that can change.
    ///
    /// The attribute list usually details extra fields necessary for additional
    /// semantics not covered in the general meta machine model. The meta
    /// machine model takes a minimalistic point of view where the meta model
    /// represents the common semantics between different schedulers
    /// (swiftfsm, clfsm for example). Obviously each scheduler has a different
    /// feature set. The features which are not common between schedulers
    /// should be facilitated through this attributes field.
    public fileprivate(set) var attributes: [AttributeGroup]
    
    /// A list of attributes specifying additional fields that do not change.
    ///
    /// This metaData property is similar to the `attributes` property, however;
    /// the values within this field are under the control of the parsers and
    /// generators for the specific scheduler. This allows the parsers and
    /// generators to parse/generate machines which require data that the user
    /// doesn't necessarily need to know about. These fields are therefore
    /// hidden.
    ///
    /// - Attention: If you were to make a GUI using the meta model machines,
    /// then you should simply keep these values the same between modifications.
    public fileprivate(set) var metaData: [AttributeGroup]
    
    /// Create a new `Machine`.
    ///
    /// Creates a new meta machine model.
    ///
    /// - Parameter semantics: The semantics this meta machine model implements.
    ///
    /// - Parameter initialState: The name of the starting state of the machine
    /// within the `states` array.
    ///
    /// - Parameter suspendState: The name of the state which denots that the
    /// machine is suspended representing a state within the `states` array.
    ///
    /// - Parameter states: All states within the machine.
    ///
    /// - Parameter transitions: All transitions within the machine, even those
    /// that aren't attached to states.
    ///
    /// - Parameter variables: A list of variables denoted by a unique names.
    ///
    /// - Parameter attributes: All attributes of the meta machine that detail
    /// additional fields for custom semantics provided by a particular
    /// scheduler.
    ///
    /// - Parameter metaData: Attributes which should be hidden from the user,
    /// but detail additional field for custom semantics provided by a
    /// particular scheduler.
    public init(
        semantics: Semantics,
        name: String,
        filePath: URL,
        initialState: StateName,
        suspendState: StateName,
        states: [State] = [],
        transitions: [Transition] = [],
        variables: [VariableList],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = semantics
        self.name = name
        self.filePath = filePath
        self.initialState = initialState
        self.suspendState = suspendState
        self.states = states
        self.transitions = transitions
        self.variables = variables
        self.attributes = attributes
        self.metaData = metaData
    }
    
}

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
        let states = swiftMachine.states.map {
            State(
                name: $0.name,
                actions: Dictionary(uniqueKeysWithValues: $0.actions.map { ($0.name, $0.implementation) }),
                variables: [
                    VariableList(
                        name: "state_variables",
                        enabled: $0.externalVariables != nil,
                        variables: $0.vars.map {
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
                        fields: [
                            "external_variables": .enumerableCollection(validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                            "imports": .text
                        ],
                        attributes: [
                            "external_variables": .enumerableCollection(Set($0.externalVariables?.map { $0.label } ?? []), validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                            "imports": .text($0.imports)
                        ]
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
        let validator = SwiftfsmMachineValidator()
        let machine = try validator.validate(machine: self)
        guard let ringletGroup = machine.attributes.first(where: { $0.name == "ringlet" }) else {
            throw ConversionError(message: "Missing ringlet group in attributes")
        }
        let actions = Set(ringletGroup.attributes["actions"]?.collectionLines ?? ["onEntry", "onExit", "main"]).sorted().filter {
            $0.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
        throw ConversionError(message: "Not Yet Implemented")
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
