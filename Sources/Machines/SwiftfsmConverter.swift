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

struct SwiftfsmConverter {
    
    func metaMachine(_ swiftMachine: SwiftMachines.Machine) -> Machine {
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
        return Machine(
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
    
    func swiftMachine(_ machine: Machine) throws -> SwiftMachines.Machine {
        let machine = try SwiftfsmMachineValidator().validate(machine: machine)
        guard let ringletGroup = machine.attributes.first(where: { $0.name == "ringlet" }) else {
            throw ConversionError(message: "Missing ringlet group in attributes")
        }
        let actions = Set(ringletGroup.attributes["actions"]?.collectionLines ?? ["onEntry", "onExit", "main"]).sorted().filter {
            $0.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
        let model: SwiftMachines.Model?
        if (ringletGroup.attributes["use_custom_ringlet"]?.boolValue ?? false) {
            guard let imports = ringletGroup.attributes["imports"]?.codeValue else {
                throw ConversionError(message: "Missing required attribute ringlet.imports")
            }
            guard let execute = ringletGroup.attributes["executes"]?.codeValue else {
                throw ConversionError(message: "Missing required attribute ringlet.execute")
            }
            guard let variablesList = ringletGroup.variables else {
                throw ConversionError(message: "Missing required field ringlet.variables")
            }
            let vars = try variablesList.variables.enumerated().map { (index, variable) -> SwiftMachines.Variable in
                try self.parseNormalVariable(variable, attributePath: "ringlet.variables.variables[\(index)]")
            }
            model = SwiftMachines.Model(
                actions: actions,
                ringlet: SwiftMachines.Ringlet(imports: imports, vars: vars, execute: execute)
            )
        } else {
            model = nil
        }
        var resultType: String? = nil
        let machineVariables: [String: [SwiftMachines.Variable]] = try Dictionary(uniqueKeysWithValues: machine.variables.map { (list) -> (String, [SwiftMachines.Variable]) in
            switch list.name {
            case "parameters":
                if let type = list.attributes["result_type"]?.expressionValue.map({ String($0) })?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    resultType = type.isEmpty ? nil : type
                }
                return (list.name, try list.variables.enumerated().map { try self.parseParameters($1, attributePath: "variables.parameters.variables[\($0)]") })
            case "external_variables":
                return (list.name, try list.variables.enumerated().map { try self.parseExternals($1, attributePath: "variables.external_variables[\($0)]") })
            default:
                return (list.name, try list.variables.enumerated().map { try self.parseNormalVariable($1, attributePath: "variables.\(list.name)[\($0)]") })
            }
        })
        guard let externalVariables = machineVariables["external_variables"] else {
            throw ConversionError(message: "Missing required variable list external_variables")
        }
        let parameters = machineVariables["parameters"]
        guard let fsmVars = machineVariables["fsm_variables"] else {
            throw ConversionError(message: "Missing required variable list fsm_vars")
        }
        var transitions: [String: [SwiftMachines.Transition]] = [:]
        transitions.reserveCapacity(machine.transitions.count)
        machine.transitions.forEach {
            guard let source = $0.source, let target = $0.target else {
                return
            }
            if nil == transitions[source] {
                transitions[source] = []
            }
            transitions[source]?.append(SwiftMachines.Transition(target: target, condition: $0.condition.map { String($0) }))
        }
        let states = try machine.states.enumerated().map { (index, state) -> SwiftMachines.State in
            let actions = state.actions.map { SwiftMachines.Action(name: $0, implementation: String($1)) }
            guard let settings = state.attributes.first(where: { $0.name == "settings" }) else {
                throw ConversionError(message: "Missing required attributes states[\(index)].settings")
            }
            guard let stateVariablesList = state.variables.first(where: { $0.name == "state_variables" }) else {
                throw ConversionError(message: "Missing required variables states[\(index).state_variables]")
            }
            let vars = try stateVariablesList.variables.enumerated().map { (varIndex, variable) in
                try self.parseNormalVariable(variable, attributePath: "states[\(index)].state_variables.variables[\(varIndex)]")
            }
            let externalVariablesSet: Set<String>? = settings.attributes["external_variables"]?.enumerableCollectionValue?.0
            let externalVariables: [SwiftMachines.Variable]? = externalVariablesSet?.compactMap { label in machineVariables["external_variables"]?.first { $0.label == label } }
            return SwiftMachines.State(
                name: state.name,
                imports: settings.attributes["imports"]?.codeValue.map { String($0) } ?? "",
                externalVariables: externalVariables,
                vars: vars,
                actions: actions,
                transitions: transitions[state.name] ?? []
            )
        }
        guard let initialState = states.first(where: { $0.name == String(machine.initialState) }) else {
            throw ConversionError(message: "Initial state does not exist in the states array")
        }
        let suspendState = states.first(where: { $0.name == String(machine.suspendState) })
        guard let moduleDependencies = machine.attributes.first(where: { $0.name == "module_dependencies" }) else {
            throw ConversionError(message: "Missing required attributes module_dependencies")
        }
        let packageDependencies = try (moduleDependencies.attributes["packages"]?.collectionComplex?.0.enumerated().map {
            try self.parsePackageDependencies($1, attributePath: "module_dependencies.packages[\($0)]")
        }) ?? []
        return SwiftMachines.Machine(
            name: machine.name,
            filePath: machine.filePath,
            externalVariables: externalVariables,
            packageDependencies: packageDependencies,
            swiftIncludeSearchPaths: moduleDependencies.attributes["swift_search_paths"]?.collectionLines ?? [],
            includeSearchPaths: moduleDependencies.attributes["c_header_search_paths"]?.collectionLines ?? [],
            libSearchPaths: moduleDependencies.attributes["linker_search_paths"]?.collectionLines ?? [],
            imports: moduleDependencies.attributes["system_imports"]?.codeValue.map { String($0) } ?? "",
            includes: moduleDependencies.attributes["system_includes"]?.codeValue.map { String($0) },
            vars: fsmVars,
            model: model,
            parameters: parameters,
            returnType: resultType,
            initialState: initialState,
            suspendState: suspendState,
            states: states,
            submachines: [],
            callableMachines: [],
            invocableMachines: []
        )
    }
    
    private func parsePackageDependencies(_ attributes: [String: Attribute], attributePath: String) throws -> SwiftMachines.PackageDependency {
        let products = attributes["products"]?.collectionLines?.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let qualifiers = attributes["qualifiers"]?.collectionLines?.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let targets = attributes["targets_to_import"]?.collectionLines?.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
        let url = attributes["url"]?.lineValue?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if products.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath).products")
        }
        if qualifiers.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath).qualifiers")
        }
        if targets.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath).targets")
        }
        if url.isEmpty {
            throw ConversionError(message: "Missing required field \(attributePath).url")
        }
        return SwiftMachines.PackageDependency(products: products, targets: targets, url: url, qualifiers: qualifiers)
    }
    
    private func parseExternals(_ variable: Variable, attributePath: String) throws -> SwiftMachines.Variable {
        let variable = try self.parseVariable(variable, attributePath: attributePath)
        guard let (accessTypeStr, _) = variable.extraFields["access_type"]?.enumeratedValue else {
            throw ConversionError(message: "Missing required field \(attributePath).access_type")
        }
        guard let accessType = SwiftMachines.Variable.AccessType(rawValue: accessTypeStr) else {
            throw ConversionError(message: "Malformed value '\(accessTypeStr)', expected value in \(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })")
        }
        guard let initialValueStr = variable.extraFields["value"]?.expressionValue else {
            throw ConversionError(message: "Missing required field \(attributePath).value")
        }
        let initialValue = initialValueStr.trimmingCharacters(in: .whitespacesAndNewlines)
        return SwiftMachines.Variable(accessType: accessType, label: variable.label, type: variable.type, initialValue: initialValue.isEmpty ? nil : initialValue)
    }
    
    private func parseParameters(_ variable: Variable, attributePath: String) throws -> SwiftMachines.Variable {
        let variable = try self.parseVariable(variable, attributePath: attributePath)
        guard let initialValueStr = variable.extraFields["default_value"]?.expressionValue else {
            throw ConversionError(message: "Missing required field \(attributePath).default_value")
        }
        let initialValue = initialValueStr.trimmingCharacters(in: .whitespacesAndNewlines)
        return SwiftMachines.Variable(accessType: .readOnly, label: variable.label, type: variable.type, initialValue: initialValue.isEmpty ? nil : initialValue)
    }
    
    private func parseNormalVariable(_ variable: Variable, attributePath: String) throws -> SwiftMachines.Variable {
        let variable = try self.parseVariable(variable, attributePath: attributePath)
        guard let (accessTypeStr, _) = variable.extraFields["access_type"]?.enumeratedValue else {
            throw ConversionError(message: "Missing required field \(attributePath).access_type")
        }
        guard let accessType = SwiftMachines.Variable.AccessType(rawValue: accessTypeStr) else {
            throw ConversionError(message: "Malformed value '\(accessTypeStr)', expected value in \(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })")
        }
        guard let initialValueStr = variable.extraFields["initial_value"]?.expressionValue else {
            throw ConversionError(message: "Missing required field \(attributePath).initial_value")
        }
        let initialValue = initialValueStr.trimmingCharacters(in: .whitespacesAndNewlines)
        return SwiftMachines.Variable(accessType: accessType, label: variable.label, type: variable.type, initialValue: initialValue.isEmpty ? nil : initialValue)
    }
    
    private func parseVariable(_ variable: Variable, attributePath: String) throws -> Variable {
        let label = variable.label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = label.first else {
            throw ConversionError(message: "Missing required field \(attributePath).label")
        }
        if !first.isLetter {
            throw ConversionError(message: "The variable label must start with an alphabetic character \(attributePath).label")
        }
        if label.contains(where: { !$0.isNumber && !$0.isLetter && $0 != "_" }) {
            throw ConversionError(message: "The variable label must be alphanumeric with underscores \(attributePath).label")
        }
        let type = variable.type.trimmingCharacters(in: .whitespacesAndNewlines)
        if type.isEmpty {
            throw ConversionError(message: "The type of the variable must not be empty")
        }
        return Variable(label: label, type: type, extraFields: variable.extraFields)
    }
    
}
