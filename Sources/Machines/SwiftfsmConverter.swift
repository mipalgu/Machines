/*
 * SwiftfsmConverter.swift
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
import SwiftMachines
import Foundation


struct SwiftfsmConverter: Converter, MachineValidator {
    
    private let validator = SwiftfsmMachineValidator()
    
    func initialArrangement(filePath: URL) -> Arrangement {
        return Arrangement(
            semantics: .swiftfsm,
            filePath: filePath,
            dependencies: [],
            attributes: [],
            metaData: []
        )
    }
    
    func initial(filePath: URL) -> Machine {
        let swiftMachine = SwiftMachines.Machine(
            name: filePath.lastPathComponent.hasSuffix(".machine") ? filePath.lastPathComponent.components(separatedBy: ".").dropLast().joined(separator: ".") : filePath.lastPathComponent,
            filePath: filePath,
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
                actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                transitions: []
            ),
            suspendState: SwiftMachines.State(
                name: "Suspend",
                imports: "",
                externalVariables: nil,
                vars: [],
                actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                transitions: []
            ),
            states: [
                SwiftMachines.State(
                    name: "Initial",
                    imports: "",
                    externalVariables: nil,
                    vars: [],
                    actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                    transitions: []
                ),
                SwiftMachines.State(
                    name: "Suspend",
                    imports: "",
                    externalVariables: nil,
                    vars: [],
                    actions: [SwiftMachines.Action(name: "onEntry", implementation: ""), SwiftMachines.Action(name: "onExit", implementation: ""), SwiftMachines.Action(name: "main", implementation: "")],
                    transitions: []
                )
            ],
            submachines: [],
            callableMachines: [],
            invocableMachines: []
        )
        return metaMachine(of: swiftMachine)
    }
    
    func metaArrangement(of swiftArrangement: SwiftMachines.Arrangement) -> Arrangement {
        let rootFsms = swiftArrangement.dependencies.map { MachineDependency(name: $0.callName, filePath: $0.filePath) }
        let group: AttributeGroup
        if let table = swiftArrangement.dispatchTable {
            let (names, _) = swiftArrangement.namespacedDependencies
            let accurateTable = DispatchTable(groups: table.groups.compactMap {
                let items = $0.items.filter { names.contains($0.name) }
                return items.isEmpty ? nil : DispatchGroup(items: items)
            })
            let rows: [Attribute] = accurateTable.groups.map {
                .table(
                    $0.items.map {
                        [.integer(Int($0.startTime)), .integer(Int($0.duration)), .enumerated($0.name, validValues: names)]
                    },
                    columns: [("start_time", .integer), ("duration", .integer), ("FSM", .line)]
                )
            }
            group = AttributeGroup(
                name: "dispatch_table",
                fields: [
                    Field(name: "use_dispatch_table", type: .bool),
                    Field(name: "dispatch_table", type: .collection(type: .table(columns: [("start_time", .integer), ("duration", .integer), ("FSM", .enumerated(validValues: names))])))
                ],
                attributes: [
                    "use_dispatch_table": .bool(true),
                    "dispatch_table": .collection(
                        rows,
                        type: .table(columns: [("start_time", .integer), ("duration", .integer), ("FSM", .enumerated(validValues: names))])
                    )
                ],
                metaData: [:]
            )
        } else {
            group = AttributeGroup(
                name: "dispatch_table",
                fields: [
                    Field(name: "use_dispatch_table", type: .bool)
                ],
                attributes: [
                    "use_dispatch_table": .bool(false)
                ],
                metaData: [:]
            )
        }
        return Arrangement(semantics: .swiftfsm, filePath: swiftArrangement.filePath, dependencies: rootFsms, attributes: [group], metaData: [])
    }
    
    func metaMachine(of swiftMachine: SwiftMachines.Machine) -> Machine {
        var attributes: [AttributeGroup] = []
        let variables = AttributeGroup(
            name: "variables",
            fields: [
                "external_variables": .table(columns: [
                    ("access_type", .enumerated(validValues: ["sensor", "actuator", "external"])),
                    ("label", .line),
                    ("type", .expression(language: .swift)),
                    ("value", .expression(language: .swift))
                ]),
                "machine_variables": .table(columns: [
                    ("access_type", .enumerated(validValues: ["let", "var"])),
                    ("label", .line),
                    ("type", .expression(language: .swift)),
                    ("initial_value", .expression(language: .swift))
                ]),
                "parameters": .complex(layout: swiftMachine.parameters == nil ? ["enable_parameters": .bool] : [
                    "enable_parameters": .bool,
                    "parameters": .table(columns: [
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("default_value", .expression(language: .swift))
                    ]),
                    "result_type": .expression(language: .swift)
                ])
            ],
            attributes: [
                "external_variables": .table(
                    swiftMachine.externalVariables.map {
                        [
                            .enumerated(self.externalLabel(forAccessType: $0.accessType), validValues: ["sensor", "actuator", "external"]),
                            .line($0.label),
                            .expression(Expression($0.type), language: .swift),
                            .expression(Expression($0.initialValue ?? ""), language: .swift)
                        ]
                    },
                    columns: [
                        ("access_type", .enumerated(validValues: ["sensor", "actuator", "external"])),
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("value", .expression(language: .swift))
                    ]
                ),
                "machine_variables": .table(
                    swiftMachine.vars.map {
                        [
                            .enumerated($0.accessType.rawValue, validValues: ["let", "var"]),
                            .line($0.label),
                            .expression(Expression($0.type), language: .swift),
                            .expression(Expression($0.initialValue ?? ""), language: .swift)
                        ]
                    },
                    columns: [
                        ("access_type", .enumerated(validValues: ["let", "var"])),
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("initial_value", .expression(language: .swift))
                    ]
                ),
                "parameters": .complex(swiftMachine.parameters == nil ? ["enable_parameters": .bool(false)] : [
                    "enable_parameters": .bool(true),
                    "parameters": .table(
                        (swiftMachine.parameters ?? []).map {
                            [
                                .line($0.label),
                                .expression(Expression($0.type), language: .swift),
                                .expression(Expression($0.initialValue ?? ""), language: .swift)
                            ]
                        },
                        columns: [
                            ("label", .line),
                            ("type", .expression(language: .swift)),
                            ("default_value", .expression(language: .swift))
                        ]
                    ),
                    "result_type": .expression(Expression(swiftMachine.returnType ?? ""), language: .swift)
                ], layout: swiftMachine.parameters == nil ? ["enable_parameters": .bool] : [
                    "enable_parameters": .bool,
                    "parameters": .table(columns: [
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("default_value", .expression(language: .swift))
                    ]),
                    "result_type": .expression(language: .swift)
                ])
            ]
        )
        attributes.append(variables)
        if let model = swiftMachine.model {
            let group = AttributeGroup(
                name: "ringlet",
                fields: [
                    "use_custom_ringlet": .bool,
                    "actions": .collection(type: .line),
                    "ringlet_variables": .table(columns: [
                        ("access_type", .enumerated(validValues: ["let", "var"])),
                        ("label", .line),
                        ("type", .expression(language: .swift)),
                        ("initial_value", .expression(language: .swift))
                    ]),
                    "imports": .code(language: .swift),
                    "execute": .code(language: .swift)
                ],
                attributes: [
                    "use_custom_ringlet": .bool(true),
                    "actions": .collection(lines: model.actions),
                    "ringlet_variables": .table(
                        model.ringlet.vars.map {
                            [
                                .enumerated($0.accessType.rawValue, validValues: ["let", "var"]),
                                .line($0.label),
                                .expression(Expression($0.type), language: .swift),
                                .expression(Expression($0.initialValue ?? ""), language: .swift)
                            ]
                        },
                        columns: [
                            ("access_type", .enumerated(validValues: ["let", "var"])),
                            ("label", .line),
                            ("type", .expression(language: .swift)),
                            ("initial_value", .expression(language: .swift))
                        ]
                    ),
                    "imports": .code(model.ringlet.imports, language: .swift),
                    "execute": .code(model.ringlet.execute, language: .swift)
                ]
            )
            attributes.append(group)
        } else {
            let group = AttributeGroup(
                name: "ringlet",
                fields: [
                    "use_custom_ringlet": .bool
                ],
                attributes: [
                    "use_custom_ringlet": .bool(false)
                ]
            )
            attributes.append(group)
        }
        let settings = AttributeGroup(
            name: "settings",
            fields: [
                "suspend_state": .enumerated(validValues: Set(swiftMachine.states.map(\.name) + [""])),
                "module_dependencies": .complex(layout: [
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
                ])
            ],
            attributes: [
                "suspend_state": Attribute.enumerated(swiftMachine.suspendState?.name ?? "", validValues: Set(swiftMachine.states.map(\.name) + [""])),
                "module_dependencies": .complex([
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
                ], layout: [
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
                ])
            ],
            metaData: [:]
        )
        attributes.append(settings)
        let states = swiftMachine.states.map { (state) -> State in
            let settingsFields: [Field]
            let settingsAttributes: [String: Attribute]
            if let externals = state.externalVariables {
                settingsFields = [
                    "access_external_variables": .bool,
                    "external_variables": .enumerableCollection(validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                    "imports": .code(language: .swift)
                ]
                settingsAttributes = [
                    "access_external_variables": .bool(true),
                    "external_variables": .enumerableCollection(Set(externals.map { $0.label }), validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                    "imports": .code(Code(state.imports), language: .swift)
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
                actions: state.actions.map { Action(name: $0.name, implementation: Code($0.implementation), language: .swift) },
                transitions: state.transitions.map { Transition(condition: $0.condition.map { Expression($0) }, target: StateName($0.target)) },
                attributes: [
                    AttributeGroup(
                        name: "variables",
                        fields: [
                            "state_variables": .table(columns: [
                                ("access_type", .enumerated(validValues: ["let", "var"])),
                                ("label", .line),
                                ("type", .expression(language: .swift)),
                                ("initial_value", .expression(language: .swift))
                            ])
                        ],
                        attributes: [
                            "state_variables": .table(
                                state.vars.map {
                                    [
                                        .enumerated($0.accessType.rawValue, validValues: ["let", "var"]),
                                        .line($0.label),
                                        .expression(Expression($0.type), language: .swift),
                                        .expression(Expression($0.initialValue ?? ""), language: .swift)
                                    ]
                                },
                                columns: [
                                    ("access_type", .enumerated(validValues: ["let", "var"])),
                                    ("label", .line),
                                    ("type", .expression(language: .swift)),
                                    ("initial_value", .expression(language: .swift))
                                ]
                            )
                        ]
                    ),
                    AttributeGroup(
                        name: "settings",
                        fields: settingsFields,
                        attributes: settingsAttributes
                    )
                ]
            )
        }
        let submachines = swiftMachine.subs.map {
            MachineDependency(
                name: $0.name ?? $0.machineName,
                filePath: $0.filePath,
                fields: dependencyLayout,
                attributes: ["relationship": .enumerated("submachine", validValues: ["submachine", "asynchronous_parameterised_machine", "synchronous_parameterised_machine"])],
                metaData: [:]
            )
        }
        let synchronous = swiftMachine.callables.map {
            MachineDependency(
                name: $0.name ?? $0.machineName,
                filePath: $0.filePath,
                fields: dependencyLayout,
                attributes: ["relationship": .enumerated("synchronous_parameterised_machine", validValues: ["submachine", "asynchronous_parameterised_machine", "synchronous_parameterised_machine"])],
                metaData: [:]
            )
        }
        let asynchronous = swiftMachine.invocables.map {
            MachineDependency(
                name: $0.name ?? $0.machineName,
                filePath: $0.filePath,
                fields: dependencyLayout,
                attributes: ["relationship": .enumerated("submachine", validValues: ["submachine", "asynchronous_parameterised_machine", "asynchronous_parameterised_machine"])],
                metaData: [:]
            )
        }
        return Machine(
            semantics: .swiftfsm,
            filePath: swiftMachine.filePath,
            initialState: swiftMachine.initialState.name,
            states: states,
            dependencies: (submachines + synchronous + asynchronous).sorted { $0.name < $1.name },
            attributes: attributes,
            metaData: []
        )
    }
    
    func convert(_ arrangement: Arrangement) throws -> SwiftMachines.Arrangement {
        let dependencies = try arrangement.dependencies.map { (dep: MachineDependency) -> SwiftMachines.Machine.Dependency in
            guard let dependency = SwiftMachines.Machine.Dependency(name: dep.name, filePath: dep.filePath) else {
                throw ConversionError(message: "Unable to create dependency", path: Machine.path)
            }
            return dependency
        }
        return SwiftMachines.Arrangement(name: arrangement.name, filePath: arrangement.filePath, dependencies: dependencies)
    }
    
    func convert(_ machine: Machine) throws -> SwiftMachines.Machine {
        try self.validator.validate(machine: machine)
        let ringletGroup = machine.attributes[1]
        let actions = Set(ringletGroup.attributes["actions"]?.collectionLines ?? ["onEntry", "onExit", "main"]).sorted().filter {
            $0.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
        let model: SwiftMachines.Model?
        if (ringletGroup.attributes["use_custom_ringlet"]?.boolValue ?? false) {
            guard let imports = ringletGroup.attributes["imports"]?.codeValue else {
                throw ConversionError(message: "Missing required attribute ringlet.imports", path: Machine.path.attributes[1].attributes["imports"].wrappedValue)
            }
            guard let execute = ringletGroup.attributes["executes"]?.codeValue else {
                throw ConversionError(message: "Missing required attribute ringlet.execute", path: Machine.path.attributes[1].attributes["executes"].wrappedValue)
            }
            guard let vars = try ringletGroup.attributes["ringlet_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.attributes[1].attributes["ringlet_variables"].wrappedValue.tableValue[$0]) }) else {
                throw ConversionError(message: "Missing required variable list ringlet_variables", path: Machine.path.attributes[1].attributes["ringlet_variables"].wrappedValue)
            }
            model = SwiftMachines.Model(
                actions: actions,
                ringlet: SwiftMachines.Ringlet(imports: imports, vars: vars, execute: execute)
            )
        } else {
            model = nil
        }
        let resultType: String? = machine.attributes[1].attributes["result_type"]?.expressionValue
        guard let externalVariables = try machine.attributes[0].attributes["external_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.attributes[0].attributes["external_variables"].wrappedValue.tableValue[$0]) }) else {
            throw ConversionError(message: "Missing required variable list external_variables", path: Machine.path.attributes[0].attributes["external_variables"].wrappedValue)
        }
        let parameters: [SwiftMachines.Variable]? = (machine.attributes[0].attributes["parameters"]?.complexValue["enable_parameters"]?.boolValue ?? false)
            ? try machine.attributes[0].attributes["parameters"]?.complexValue["parameters"]?.tableValue.enumerated().map({ try self.parseParameters($1, path: Machine.path.attributes[0].attributes["parameters"].wrappedValue.complexValue["parameters"].wrappedValue.tableValue[$0]) })
            : nil
        guard let fsmVars = try machine.attributes[0].attributes["machine_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.attributes[0].attributes["machine_variables"].wrappedValue.tableValue[$0]) }) else {
            throw ConversionError(message: "Missing required variable list machine_variables", path: Machine.path.attributes[0].attributes["machine_variables"].wrappedValue)
        }
        let states = try machine.states.enumerated().map { (index, state) -> SwiftMachines.State in
            let actions = state.actions.map { SwiftMachines.Action(name: $0.name, implementation: String($0.implementation)) }
            let settings = state.attributes[1]
            guard let vars = try state.attributes[0].attributes["state_variables"]?.tableValue.enumerated().map({ try self.parseVariable($1, path: Machine.path.states[index].attributes[0].attributes["state_variables"].wrappedValue.tableValue[$0]) }) else {
                throw ConversionError(message: "Missing required variable list state_variables", path: Machine.path.states[index].attributes[0].attributes["state_variables"].wrappedValue)
            }
            let externalVariablesSet: Set<String>? = settings.attributes["external_variables"]?.enumerableCollectionValue
            let externalVariables: [SwiftMachines.Variable]? = externalVariablesSet?.compactMap { label in externalVariables.first { $0.label == label } }
            let transitions = state.transitions.map {
                SwiftMachines.Transition(target: String($0.target), condition: $0.condition.map { String($0) })
            }
            return SwiftMachines.State(
                name: state.name,
                imports: settings.attributes["imports"]?.codeValue ?? "",
                externalVariables: externalVariables,
                vars: vars,
                actions: actions,
                transitions: transitions
            )
        }
        guard let initialState = states.first(where: { $0.name == String(machine.initialState) }) else {
            throw ConversionError(message: "Initial state does not exist in the states array", path: Machine.path.initialState)
        }
        let suspendState = (machine.attributes[2].attributes["suspend_state"]?.enumeratedValue).map { stateName in
            return states.first(where: { stateName == $0.name })
        } ?? nil
        let moduleDependencies = machine.attributes[2].attributes["module_dependencies"]!.complexValue
        let packageDependencies = try (moduleDependencies["packages"]?.collectionComplex.enumerated().map {
            try self.parsePackageDependencies($1, attributePath: Machine.path.attributes[2].attributes["module_dependencies"].wrappedValue.complexValue)
        }) ?? []
        let submachines = machine.dependencies.filter {
            $0.attributes["relationship"]?.enumeratedValue == "submachine"
        }
        let synchronous = machine.dependencies.filter {
            $0.attributes["relationship"]?.enumeratedValue == "synchronous_parameterised_machine"
        }
        let asynchronous = machine.dependencies.filter {
            $0.attributes["relationship"]?.enumeratedValue == "asynchronous_parameterised_machine"
        }
        return SwiftMachines.Machine(
            name: machine.name,
            filePath: machine.filePath,
            externalVariables: externalVariables,
            packageDependencies: packageDependencies,
            swiftIncludeSearchPaths: moduleDependencies["swift_search_paths"]?.collectionLines ?? [],
            includeSearchPaths: moduleDependencies["c_header_search_paths"]?.collectionLines ?? [],
            libSearchPaths: moduleDependencies["linker_search_paths"]?.collectionLines ?? [],
            imports: moduleDependencies["system_imports"]?.codeValue ?? "",
            includes: moduleDependencies["system_includes"]?.codeValue,
            vars: fsmVars,
            model: model,
            parameters: parameters,
            returnType: resultType,
            initialState: initialState,
            suspendState: suspendState,
            states: states,
            submachines: submachines.compactMap { SwiftMachines.Machine.Dependency(name: $0.name, filePath: $0.filePath) },
            callableMachines: synchronous.compactMap { SwiftMachines.Machine.Dependency(name: $0.name, filePath: $0.filePath) },
            invocableMachines: asynchronous.compactMap { SwiftMachines.Machine.Dependency(name: $0.name, filePath: $0.filePath) }
        )
    }
    
    private func externalLabel(forAccessType accessType: SwiftMachines.Variable.AccessType) -> Attributes.Label {
        switch accessType {
        case .readOnly:
            return "sensor"
        case .writeOnly:
            return "actuator"
        case .readAndWrite:
            return "external"
        }
    }
    
    private func parsePackageDependencies<Path: ReadOnlyPathProtocol>(_ attributes: [String: Attribute], attributePath: Path) throws -> SwiftMachines.PackageDependency where Path.Root == Machine, Path.Value == [String: Attribute] {
        let products = attributes["products"]?.collectionLines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let qualifiers = attributes["qualifiers"]?.collectionLines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let targets = attributes["targets_to_import"]?.collectionLines.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let url = attributes["url"]?.lineValue.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if products.isEmpty {
            throw ConversionError(message: "Missing required field", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["products"]), ancestors: attributePath.fullPath))
        }
        if qualifiers.isEmpty {
            throw ConversionError(message: "Missing required field", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["qualifiers"]), ancestors: attributePath.fullPath))
        }
        if targets.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath)", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["targets"]), ancestors: attributePath.fullPath))
        }
        if url.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath)", path: ReadOnlyPath(keyPath: attributePath.keyPath.appending(path: \.["url"]), ancestors: attributePath.fullPath))
        }
        return SwiftMachines.PackageDependency(products: products, targets: targets, url: url, qualifiers: qualifiers)
    }
    
    private func parseParameters<Path: ReadOnlyPathProtocol>(_ variable: [LineAttribute], path: Path) throws -> SwiftMachines.Variable where Path.Root == Machine, Path.Value == [LineAttribute] {
        return try self.parseVariable(
            [
                LineAttribute.enumerated(
                    SwiftMachines.Variable.AccessType.readOnly.rawValue,
                    validValues: Set(SwiftMachines.Variable.AccessType.allCases.map(\.rawValue))
                )
            ] + variable,
            path: path
        )
    }
    
    private func parseVariable<Path: ReadOnlyPathProtocol>(_ variable: [LineAttribute], path: Path) throws -> SwiftMachines.Variable where Path.Root == Machine, Path.Value == [LineAttribute] {
        guard variable.count == 4 else {
            throw ConversionError(message: "Missing required fields", path: path)
        }
        guard let accessType = SwiftMachines.Variable.AccessType(rawValue: variable[0].enumeratedValue) ?? self.parseExternalAccessType(variable[0].enumeratedValue) else {
            throw ConversionError(message: "Invalid value", path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.[0]), ancestors: path.fullPath))
        }
        let label = String(variable[1].lineValue)
        let type = String(variable[2].expressionValue)
        let value = String(variable[3].expressionValue).trimmingCharacters(in: .whitespaces)
        return SwiftMachines.Variable(accessType: accessType, label: label, type: type, initialValue: value.isEmpty ? nil : value)
    }
    
    private func parseExternalAccessType(_ value: String) -> SwiftMachines.Variable.AccessType? {
        switch value {
        case "actuator":
            return .writeOnly
        case "sensor":
            return .readOnly
        case "external":
            return .readAndWrite
        default:
            return nil
        }
    }
    
}

extension SwiftfsmConverter: ArrangementMutator {
    
    func addItem<Path, T>(_ item: T, to attribute: Path, in arrangement: inout Arrangement) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Arrangement, Path.Value == [T] {
        arrangement[keyPath: attribute.path].append(item)
        return .success(false)
    }
    
    func moveItems<Path, T>(attribute: Path, in arrangement: inout Arrangement, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Arrangement, Path.Value == [T] {
        arrangement[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
        return.success(false)
    }
    
    func deleteItem<Path, T>(attribute: Path, atIndex index: Int, in arrangement: inout Arrangement) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Arrangement, Path.Value == [T] {
        arrangement[keyPath: attribute.path].remove(at: index)
        return .success(false)
    }
    
    func modify<Path>(attribute: Path, value: Path.Value, in arrangement: inout Arrangement) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Arrangement {
        switch attribute.path {
        case \Arrangement.attributes[0].attributes["use_dispatch_table"],
             \Arrangement.attributes[0].attributes["use_dispatch_table"].wrappedValue,
             \Arrangement.attributes[0].attributes["use_dispatch_table"].wrappedValue.lineAttribute,
             \Arrangement.attributes[0].attributes["use_dispatch_table"].wrappedValue.lineAttribute.boolValue:
            guard let boolValue = (value as? Attribute)?.boolValue ?? (value as? LineAttribute)?.boolValue ?? (value as? Bool) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            self.toggleUseDispatchTable(boolValue: boolValue, arrangement: &arrangement)
            arrangement[keyPath: attribute.path] = value
            return .success(true)
        default:
            arrangement[keyPath: attribute.path] = value
            return .success(false)
        }
    }
    
    func validate(arrangement: Arrangement) throws {
        return
    }
    
    private func toggleUseDispatchTable(boolValue: Bool, arrangement: inout Arrangement) {
        if boolValue {
            arrangement.attributes[0].fields = [
                Field(name: "use_dispatch_table", type: .bool),
                Field(name: "dispatch_table", type: .collection(type: .table(columns: [("start_time", .integer), ("duration", .integer), ("FSM", .enumerated(validValues: arrangement.allMachineNames))])))
            ]
        } else {
            arrangement.attributes[0].fields = [
                Field(name: "use_dispatch_table", type: .bool)
            ]
        }
    }
    
}

extension SwiftfsmConverter: MachineMutator {
    
    var dependencyLayout: [Field] {
        return [
            Field(
                name: "relationship",
                type: .enumerated(validValues: ["submachine", "asynchronous_parameterised_machine", "synchronous_parameterised_machine"])
            )
        ]
    }

    func addItem<Path, T>(_ item: T, to attribute: Path, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        switch attribute.path {
        case Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue.path,
             Machine.path.attributes[1].attributes["actions"].wrappedValue.blockAttribute.collectionValue.path:
            guard let action = (item as? Attribute)?.lineValue ?? (item as? LineAttribute)?.lineValue ?? (item as? String) else {
                return .failure(ValidationError(message: "Invalid value \(item)", path: attribute))
            }
            do {
                try self.addNewAction(action: action, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to create new action.", path: attribute))
            }
            return .success(true)
        default:
            machine[keyPath: attribute.path].append(item)
            return .success(false)
        }
    }
    
    func moveItems<Path: PathProtocol, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T] {
        switch attribute.path {
        case Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue.path,
             Machine.path.attributes[1].attributes["actions"].wrappedValue.blockAttribute.collectionValue.path:
            do {
                try self.moveActions(from: source, to: destination, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to reorder actions.", path: attribute))
            }
            return .success(true)
        default:
            machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
            return .success(false)
        }
    }
    
    func newDependency(_ dependency: MachineDependency, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        if machine.dependencies.contains(where: { $0.name == dependency.name }) {
            return .failure(AttributeError<Machine>(message: "The dependency '\(dependency.name)' already exists.", path: machine.path.dependencies[machine.dependencies.count]))
        }
        machine.dependencies.append(dependency)
        return .success(false)
    }
    
    func newState(machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        let name = "State"
        if nil == machine.states.first(where: { $0.name == name }) {
            do {
                try machine.states.append(self.createState(named: name, forMachine: machine))
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to create new state.", path: Machine.path.states))
            }
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
            return .failure(AttributeError(message: "Unable to create new state.", path: Machine.path.states))
        }
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }
    
    func newTransition(source: StateName, target: StateName, condition: Expression? = nil, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard
            let index = machine.states.indices.first(where: { machine.states[$0].name == source }),
            nil != machine.states.first(where: { $0.name == target })
        else {
            return .failure(ValidationError(message: "You must attach a transition to a source and target state", path: Machine.path))
        }
        machine.states[index].transitions.append(Transition(condition: condition, target: target))
        return .success(false)
    }
    
    func deleteItem<Path, T>(attribute: Path, atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        if machine[keyPath: attribute.path].count <= index || index < 0 {
            return .failure(ValidationError(message: "Invalid index '\(index)'", path: attribute))
        }
        switch attribute.path {
        case Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue.path,
             Machine.path.attributes[1].attributes["actions"].wrappedValue.blockAttribute.collectionValue.path:
            let item = machine[keyPath: attribute.keyPath][index]
            guard let action = (item as? Attribute)?.lineValue ?? (item as? LineAttribute)?.lineValue ?? (item as? String) else {
                return .failure(ValidationError(message: "Invalid value \(item)", path: attribute))
            }
            do {
                try self.deleteAction(action: action, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to delete action.", path: attribute))
            }
            return .success(true)
        default:
            machine[keyPath: attribute.path].remove(at: index)
            return .success(false)
        }
    }
    
    func delete(dependencies: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        machine.dependencies = machine.dependencies.enumerated().filter { !dependencies.contains($0.0) }.map(\.element)
        return .success(false)
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
        if index < 0 || index >= machine.dependencies.count {
            return .failure(AttributeError<Machine>(message: "Invalid index \(index) for deleting a dependency.", path: machine.path.dependencies))
        }
        machine.dependencies.remove(at: index)
        return .success(false)
    }
    
    func deleteState(atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        if index >= machine.states.count  {
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
    
    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine {
        if let index = machine.attributes[1].attributes["actions"]?.collectionValue.indices.first(where: { (index: Int) -> Bool in
            Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue[index].path == attribute.path
                || Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue[index].lineValue.path == attribute.path
                || Machine.path.attributes[1].attributes["actions"].wrappedValue.blockAttribute.collectionValue[index].lineValue.path == attribute.path
                || Machine.path.attributes[1].attributes["actions"].wrappedValue.blockAttribute.collectionValue[index].lineAttribute.lineValue.path == attribute.path
                || Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue[index].lineAttribute.path == attribute.path
                || Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue[index].lineAttribute.lineValue.path == attribute.path
        }) {
            guard let actionName = (value as? Attribute)?.lineValue ?? (value as? LineAttribute)?.lineValue ?? (value as? String) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            do {
                try self.changeName(ofAction: index, to: actionName, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to change name of action.", path: attribute))
            }
        }
        if let index = machine.states.indices.first(where: { Machine.path.states[$0].name.path == attribute.path }) {
            guard let stateName = value as? StateName else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            do {
                try self.changeName(ofState: index, to: stateName, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to change name of state.", path: attribute))
            }
        }
        if let index = machine.states.indices.first(where: {
            machine.path.states[$0].attributes[1].attributes["access_external_variables"].wrappedValue.boolValue.path == attribute.path
                || machine.path.states[$0].attributes[1].attributes["access_external_variables"].wrappedValue.lineAttribute.boolValue.path == attribute.path
        }) {
            guard let boolValue = (value as? Attribute)?.boolValue ?? (value as? LineAttribute)?.boolValue ?? (value as? Bool) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            self.toggleAccessExternalVariables(boolValue: boolValue, forState: index, machine: &machine)
        }
        if let index = machine.attributes[0].attributes["external_variables"].wrappedValue.tableValue.indices.first(where: { (index) -> Bool in
            let externalsPath = Machine.path.attributes[0].attributes["external_variables"].wrappedValue
            return externalsPath.tableValue[index][1].path == attribute.path
                || externalsPath.tableValue[index][1].lineValue.path == attribute.path
                || externalsPath.blockAttribute.tableValue[index][1].path == attribute.path
                || externalsPath.blockAttribute.tableValue[index][1].lineValue.path == attribute.path
        }) {
            guard let name = (value as? Attribute)?.lineValue ?? (value as? LineAttribute)?.lineValue ?? (value as? String) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            do {
                try self.changeName(ofExternal: index, to: name, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to change name of external variable.", path: attribute))
            }
        }
        switch attribute.path {
        case machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue.path,
             machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue.boolValue.keyPath,
             machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue.lineAttribute.boolValue.keyPath:
            guard let boolValue = (value as? Attribute)?.boolValue ?? (value as? LineAttribute)?.boolValue ?? (value as? Bool) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            self.toggleUseCustomRinglet(boolValue: boolValue, machine: &machine)
            return .success(true)
        case machine.path.attributes[0].attributes["parameters"].wrappedValue.complexValue["enable_parameters"].wrappedValue.path,
             machine.path.attributes[0].attributes["parameters"].wrappedValue.complexValue["enable_parameters"].wrappedValue.boolValue.keyPath,
             machine.path.attributes[0].attributes["parameters"].wrappedValue.complexValue["enable_parameters"].wrappedValue.lineAttribute.boolValue.keyPath,
             machine.path.attributes[0].attributes["parameters"].wrappedValue.blockAttribute.complexValue["enable_parameters"].wrappedValue.path,
             machine.path.attributes[0].attributes["parameters"].wrappedValue.blockAttribute.complexValue["enable_parameters"].wrappedValue.boolValue.keyPath,
             machine.path.attributes[0].attributes["parameters"].wrappedValue.blockAttribute.complexValue["enable_parameters"].wrappedValue.lineAttribute.boolValue.keyPath:
            guard let boolValue = (value as? Attribute)?.boolValue ?? (value as? LineAttribute)?.boolValue ?? (value as? Bool) else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            do {
                try self.toggleEnableParameters(boolValue: boolValue, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to toggle enabling parameters.", path: attribute))
            }
            return .success(true)
        default:
            if nil == self.whitelist(forMachine: machine).first(where: { $0.isParent(of: attribute) || $0.isSame(as: attribute) }) {
                return .failure(ValidationError(message: "Attempting to modify a value which is not allowed to be modified", path: attribute))
            }
            machine[keyPath: attribute.path] = value
            return .success(false)
        }
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
    
    private func addNewAction(action: String, machine: inout Machine) throws {
        guard let useCustomRinglet = machine.attributes[1].attributes["use_custom_ringlet"]?.boolValue, useCustomRinglet == true else {
            throw ValidationError(message: "You can only add actions when custom ringlets have been enabled", path: Machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue)
        }
        let actions = machine.attributes[1].attributes["actions"]?.collectionValue.map(\.lineValue) ?? ["onEntry", "onExit", "main"]
        if Set(actions).contains(action) {
            throw ValidationError(message: "Cannot add new action '\(action)' since an action with that name already exists", path: Machine.path.attributes[1].attributes["actions"].wrappedValue)
        }
        machine.attributes[1].attributes["actions"] = .collection(lines: actions + [action])
        machine.states.indices.forEach {
            machine.states[$0].actions.append(Action(name: action, implementation: Code(""), language: .swift))
        }
    }
    
    private func deleteAction(action: String, machine: inout Machine) throws {
        guard let useCustomRinglet = machine.attributes[1].attributes["use_custom_ringlet"]?.boolValue, useCustomRinglet == true else {
            throw ValidationError(message: "You can only delete actions when custom ringlets have been enabled", path: Machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue)
        }
        var actions = machine.attributes[1].attributes["actions"]?.collectionValue.map(\.lineValue) ?? ["onEntry", "onExit", "main"]
        guard let index = actions.firstIndex(of: action) else {
            throw ValidationError(message: "Cannot delete action '\(action)' since it is not in the actions list", path: Machine.path.attributes[1].attributes["actions"].wrappedValue)
        }
        actions.remove(at: index)
        machine.attributes[1].attributes["actions"] = .collection(lines: actions)
        machine.states.indices.forEach {
            machine.states[$0].actions.removeAll(where: { $0.name == action })
        }
    }
    
    private func moveActions(from source: IndexSet, to destination: Int, machine: inout Machine) throws {
        guard let useCustomRinglet = machine.attributes[1].attributes["use_custom_ringlet"]?.boolValue, useCustomRinglet == true else {
            throw ValidationError(message: "You can only re-order actions when custom ringlets have been enabled", path: Machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue)
        }
        var actions = machine.attributes[1].attributes["actions"]?.collectionValue.map(\.lineValue) ?? ["onEntry", "onExit", "main"]
        if destination > actions.count {
            throw ValidationError(message: "Invalid index for actions", path: Machine.path.attributes[1].attributes["actions"].wrappedValue)
        }
        actions.move(fromOffsets: source, toOffset: destination)
        machine.attributes[1].attributes["actions"] = .collection(lines: actions)
        machine.states.indices.forEach {
            machine.states[$0].actions.move(fromOffsets: source, toOffset: destination)
        }
    }
    
    private func changeName(ofAction index: Int, to actionName: StateName, machine: inout Machine) throws {
        guard let useCustomRinglet = machine.attributes[1].attributes["use_custom_ringlet"]?.boolValue, useCustomRinglet == true else {
            throw ValidationError(message: "You can only change the name of actions when custom ringlets have been enabled", path: Machine.path.attributes[1].attributes["use_custom_ringlet"].wrappedValue)
        }
        var actions = machine.attributes[1].attributes["actions"]?.collectionValue.map(\.lineValue) ?? ["onEntry", "onExit", "main"]
        if index >= actions.count {
            throw ValidationError(message: "Invalid index for action", path: Machine.path.attributes[1].attributes["actions"].wrappedValue)
        }
        if Set(actions).contains(actionName) {
            throw ValidationError(message: "Cannot change the action to '\(actionName)' since an action with that name already exists", path: Machine.path.attributes[1].attributes["actions"].wrappedValue.collectionValue[index])
        }
        actions[index] = actionName
        machine.attributes[1].attributes["actions"] = .collection(lines: actions)
        machine.states.indices.forEach {
            machine.states[$0].actions[index].name = actionName
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
        if machine.attributes[2].attributes["suspend_state"]!.enumeratedValue == currentName {
            machine.attributes[2].attributes["suspend_state"]!.enumeratedValue = stateName
        }
        self.syncSuspendState(machine: &machine)
    }
    
    private func changeName(ofExternal index: Int, to externalName: String, machine: inout Machine) throws {
        let currentName = machine.attributes[0].attributes["external_variables"]!.tableValue[index][1].lineValue
        if currentName == externalName {
            return
        }
        if Set(machine.attributes[0].attributes["external_variables"]!.tableValue.map(\.[1].lineValue)).contains(externalName) {
            throw ValidationError(message: "Cannot rename external variable to '\(externalName)' since an external variable with that name already exists", path: machine.path.attributes[0].attributes["external_variables"].wrappedValue.tableValue[index][1])
        }
        machine[keyPath: machine.path.attributes[0].attributes["external_variables"].wrappedValue.tableValue[index][1].path].lineValue = externalName
        machine.states = machine.states.map { state in
            guard var attribute = state.attributes[1].attributes["external_variables"] else {
                return state
            }
            var state = state
            if attribute.enumerableCollectionValue.contains(currentName) {
                attribute.enumerableCollectionValue.remove(currentName)
                attribute.enumerableCollectionValue.insert(externalName)
            }
            attribute.enumerableCollectionValidValues.remove(currentName)
            attribute.enumerableCollectionValidValues.insert(externalName)
            state.attributes[1].attributes["external_variables"] = attribute
            guard let fieldIndex = state.attributes[1].fields.firstIndex(where: { $0.name == "external_variables" }) else {
                return state
            }
            state.attributes[1].fields[fieldIndex].type = .enumerableCollection(validValues: attribute.enumerableCollectionValidValues)
            return state
        }
    }
    
    private func syncSuspendState(machine: inout Machine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[2].attributes["suspend_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[2].fields[0].type = .enumerated(validValues: validValues)
        machine.attributes[2].attributes["suspend_state"] = .enumerated(newValue, validValues: validValues)
    }
    
    private func toggleAccessExternalVariables(boolValue: Bool, forState stateIndex: Int, machine: inout Machine) {
        if !boolValue {
            machine.states[stateIndex].attributes[1].fields = machine.states[stateIndex].attributes[1].fields.filter { $0.name == "access_external_variables" }
            machine.states[stateIndex].attributes[1].attributes["access_external_variables"] = .bool(true)
            return
        }
        machine.states[stateIndex].attributes[1].fields = [
            "access_external_variables": .bool,
            "external_variables": .enumerableCollection(validValues: Set(machine.attributes[0].attributes["external_variables"]?.tableValue.map { $0[1].lineValue } ?? [])),
            "imports": .code(language: .swift)
        ]
        machine.states[stateIndex].attributes[1].attributes["access_external_variables"] = .bool(true)
        machine.states[stateIndex].attributes[1].attributes["external_variables"] = machine.states[stateIndex].attributes[1].attributes["external_variables"] ?? .enumerableCollection(Set(), validValues: Set(machine.attributes[0].attributes["external_variables"]?.tableValue.map { $0[1].lineValue } ?? []))
        machine.states[stateIndex].attributes[1].attributes["imports"] = machine.states[stateIndex].attributes[1].attributes["imports"] ?? .code("", language: .swift)
    }
    
    private func toggleUseCustomRinglet(boolValue: Bool, machine: inout Machine) {
        machine.attributes[1].attributes["use_custom_ringlet"] = .bool(boolValue)
        if !boolValue {
            machine.attributes[1].fields = machine.attributes[1].fields.filter { $0.name == "use_custom_ringlet" }
            return
        }
        if nil != machine.attributes[1].fields.first(where: { $0.name == "actions" }) {
            return
        }
        machine.attributes[1].fields = [
            "use_custom_ringlet": .bool,
            "actions": .collection(type: .line),
            "ringlet_variables": .table(columns: [
                ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                ("label", .line),
                ("type", .expression(language: .swift)),
                ("initial_value", .expression(language: .swift))
            ]),
            "imports": .code(language: .swift),
            "execute": .code(language: .swift)
        ]
        var attributes = machine.attributes[1].attributes
        attributes["actions"] = attributes["actions"] ?? .collection(lines: ["onEntry", "onExit", "main"])
        attributes["ringlet_variables"] = attributes["ringlet_variables"] ?? .table([], columns: [
            ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
            ("label", .line),
            ("type", .expression(language: .swift)),
            ("initial_value", .expression(language: .swift))
        ])
        attributes["imports"] = attributes["imports"] ?? .code(Code(), language: .swift)
        attributes["execute"] = attributes["execute"] ?? .code(Code(), language: .swift)
        machine.attributes[1].attributes = attributes
    }
    
    private func toggleEnableParameters(boolValue: Bool, machine: inout Machine) throws {
        machine.attributes[0].attributes["parameters"].wrappedValue.complexValue["enable_parameters"] = .bool(boolValue)
        guard let fields = machine.attributes[0].attributes["parameters"]?.complexFields else {
            throw ValidationError(message: "Unable to fetch fields of parameters", path: machine.path.attributes[0].attributes["parameters"].wrappedValue.complexFields)
        }
        if !boolValue {
            machine.attributes[0].attributes["parameters"]!.complexFields = fields.filter { $0.name == "enable_parameters" }
            return
        }
        machine.attributes[0].attributes["parameters"]!.complexFields = [
            "enable_parameters": .bool,
            "parameters": .table(columns: [
                ("label", .line),
                ("type", .expression(language: .swift)),
                ("default_value", .expression(language: .swift))
            ]),
            "result_type": .expression(language: .swift)
        ]
        guard var attributes = machine.attributes[0].attributes["parameters"]?.complexValue else {
            throw ValidationError(message: "Unable to fetch attributes of parameters", path: Machine.path.attributes[0].attributes["parameters"].wrappedValue.complexValue)
        }
        attributes["parameters"] = attributes["parameters"] ?? .table([], columns: [
            ("label", .line),
            ("type", .expression(language: .swift)),
            ("default_value", .expression(language: .swift))
        ])
        attributes["result_type"] = attributes["result_type"] ?? .expression("Void", language: .swift)
        machine.attributes[0].attributes["parameters"]!.complexValue = attributes
    }
    
    private func perform(on machine: inout Machine, _ f: (inout Machine) throws -> Void) throws {
        let backup = machine
        do {
            try f(&machine)
            try self.validate(machine: machine)
        } catch let e {
            machine = backup
            throw e
        }
    }
    
    private func createState(named name: String, forMachine machine: Machine) throws -> State {
        guard machine.attributes.count >= 3 else {
            throw ValidationError(message: "Missing attributes in machine", path: Machine.path.attributes)
        }
        let actions = machine.attributes[2].attributes["actions"]?.collectionValue.failMap { $0.lineValue } ?? ["onEntry", "onExit", "main"]
        return State(
            name: name,
            actions: actions.map { Action(name: $0, implementation: Code(""), language: .swift) },
            transitions: [],
            attributes: [
                AttributeGroup(
                    name: "variables",
                    fields: [
                        "state_variables": .table(columns: [
                            ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                            ("label", .line),
                            ("type", .expression(language: .swift)),
                            ("initial_value", .expression(language: .swift))
                        ])
                    ],
                    attributes: [
                        "state_variables": .table(
                            [],
                            columns: [
                                ("access_type", .enumerated(validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue }))),
                                ("label", .line),
                                ("type", .expression(language: .swift)),
                                ("initial_value", .expression(language: .swift))
                            ]
                        )
                    ]
                ),
                AttributeGroup(
                    name: "settings",
                    fields: [
                        "access_external_variables": .bool
                    ],
                    attributes: [
                        "access_external_variables": .bool(false)
                    ]
                )
            ]
        )
    }
    
    func validate(machine: Machine) throws {
        try self.validator.validate(machine: machine)
    }
    
}
