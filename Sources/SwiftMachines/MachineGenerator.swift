/*
 * MachineGenerator.swift 
 * Sources 
 *
 * Created by Callum McColl on 05/04/2017.
 * Copyright © 2017 Callum McColl. All rights reserved.
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

/* Takes an object of class Machine and produces the files for a machine
 editor, for example
 */

import Foundation
import IO

public final class MachineGenerator {

    private let helpers: FileHelpers

    private let varHelpers: VariableHelpers

    public init(helpers: FileHelpers = FileHelpers(), varHelpers: VariableHelpers = VariableHelpers()) {
        self.helpers = helpers
        self.varHelpers = varHelpers
    }
    
    public func generate(_ machine: Machine, at directory: URL) -> (URL, FileWrapper)? {
        guard
            let machineDir = self.helpers.overwriteDirectory(directory, ignoringSubFiles: [directory.appendingPathComponent("dependencies", isDirectory: true)])
        else {
            return nil
        }
        guard let wrapper = self.generate(machine) else {
            return nil
        }
        do {
            try wrapper.write(to: machineDir, options: .atomic, originalContentsURL: nil)
        } catch {
            return nil
        }
        return (machineDir, wrapper)
    }

    public func generate(_ machine: Machine) -> FileWrapper? {
        let wrapper = FileWrapper(directoryWithFileWrappers: [:])
        guard
            let packageDependenciesPath = self.makePackageDependencies(forMachine: machine),
            let swiftIncludePath = create("SwiftIncludePath", contents: reduceList(machine.swiftIncludeSearchPaths)),
            let includePath = create("IncludePath", contents: reduceList(machine.includeSearchPaths)),
            let libPath = create("LibPath", contents: reduceList(machine.libSearchPaths)),
            let imports = create("Imports.swift", contents: machine.imports),
            let vars = create(
                "Vars.swift",
                contents: machine.vars.map({
                    self.varHelpers.makeDeclarationWithAvailableAssignment(forVariable: $0)
                }).joined(separator: "\n")
            ),
            let stateFiles = self.makeStates(forMachine: machine),
            let stateList = self.makeStateList(forMachine: machine),
            let externalVariables = self.makeExternalVariables(forMachine: machine),
            let callables = self.makeDependenciesFile(named: "SyncMachines", forMachine: machine, dependencies: machine.callables),
            let invocables = self.makeDependenciesFile(named: "ASyncMachines", forMachine: machine, dependencies: machine.invocables),
            let subs = self.makeDependenciesFile(named: "SubMachines", forMachine: machine, dependencies: machine.subs)
        else {
            return nil
        }
        wrapper.addFileWrapper(packageDependenciesPath)
        wrapper.addFileWrapper(swiftIncludePath)
        wrapper.addFileWrapper(includePath)
        wrapper.addFileWrapper(libPath)
        wrapper.addFileWrapper(imports)
        wrapper.addFileWrapper(vars)
        stateFiles.forEach {
            wrapper.addFileWrapper($0)
        }
        wrapper.addFileWrapper(stateList)
        wrapper.addFileWrapper(externalVariables)
        wrapper.addFileWrapper(callables)
        wrapper.addFileWrapper(invocables)
        wrapper.addFileWrapper(subs)
        if let includes = machine.includes {
            guard let bridgingHeader = create("Bridging-Header.h", contents: includes) else {
                return nil
            }
            wrapper.addFileWrapper(bridgingHeader)
        }
        if let model = machine.model {
            guard
                let ringletImports = create("Ringlet_Imports.swift", contents: model.ringlet.imports),
                let ringletVars = create(
                    "Ringlet_Vars.swift",
                    contents: model.ringlet.vars.map {
                        self.varHelpers.makeDeclarationWithAvailableAssignment(forVariable: $0)
                    }.joined(separator: "\n")
                ),
                let ringletExecute = create("Ringlet_Execute.swift", contents: model.ringlet.execute),
                let modelFile = self.makeModelFile(forMachine: machine, withModel: model)
            else {
                return nil
            }
            wrapper.addFileWrapper(modelFile)
            wrapper.addFileWrapper(ringletImports)
            wrapper.addFileWrapper(ringletVars)
            wrapper.addFileWrapper(ringletExecute)
        }
        if nil != machine.parameters {
            guard let parametersFile = self.makeParametersFile(forMachine: machine) else {
                return nil
            }
            wrapper.addFileWrapper(parametersFile)
        }
        if let tests = machine.tests {
            guard let testsCode = tests.wrapper else {
                return nil
            }
            let newWrapper = FileWrapper(directoryWithFileWrappers: ["\(machine.name)Tests": testsCode])
            newWrapper.preferredFilename = "tests"
            wrapper.addFileWrapper(newWrapper)
        }
        return wrapper
    }
    
    private func create(_ name: String, contents: String) -> FileWrapper? {
        guard let data = contents.data(using: .utf8) else {
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = name
        return wrapper
    }

    func reduceList(_ list: [String], withSeparater separator: String = "\n") -> String {
        guard let first = list.first else {
            return ""
        }
        return list.dropFirst().reduce(first) { "\($0)" + separator + $1 }
    }
    
    func makePackageDependencies(forMachine machine: Machine) -> FileWrapper? {
        let encoder = JSONEncoder()
        #if os(macOS)
        if #available(macOS 10.15, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        } else if #available(macOS 10.13, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        } else {
            encoder.outputFormatting = [.prettyPrinted]
        }
        #else
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        #endif
        let data: Data
        do {
            data = try encoder.encode(machine.packageDependencies)
        } catch {
            return nil
        }
        let wrapper = FileWrapper(regularFileWithContents: data)
        wrapper.preferredFilename = "packageDependencies.json"
        return wrapper
    }

    func makeStates(forMachine machine: Machine) -> [FileWrapper]? {
        guard let files = machine.states.failMap({ self.makeState($0, forMachine: machine) }) else {
            return nil
        }
        return files.flatMap { $0 }
    }

    func makeState(_ state: State, forMachine machine: Machine) -> [FileWrapper]? {
        guard
            let actions = state.actions.failMap({
                self.makeAction($0, forState: state, inMachine: machine)
            }),
            let transitions = state.transitions.enumerated().failMap({
                self.makeTransition($1, withId: $0, inState: state, inMachine: machine)
            }),
            let transitionList = self.makeTransitionList(forState: state, inMachine: machine),
            let stateImports = create("State_" + state.name + "_Imports.swift", contents: state.imports),
            let stateVars = create(
                "State_" + state.name + "_Vars.swift",
                contents: state.vars.lazy.map {
                    self.varHelpers.makeDeclarationWithAvailableAssignment(forVariable: $0)
                }.joined(separator: "\n")
            )
        else {
            return nil
        }
        var result: [FileWrapper] = [transitionList, stateImports, stateVars]
        guard
            let stateExternalVariables = create(
                "State_" + state.name + "_ExternalVariables.swift",
                contents: state.externalVariables.sorted { $0.label < $1.label }.lazy.map { $0.label }.joined(separator: "\n")
            )
        else {
            return nil
        }
        result.append(stateExternalVariables)
        result.reserveCapacity(result.count + actions.count + transitions.count)
        result.append(contentsOf: actions)
        result.append(contentsOf: transitions)
        return result
    }

    func makeAction(_ action: Action, forState state: State, inMachine machine: Machine) -> FileWrapper? {
        create("State_" + state.name + "_" + action.name + ".swift", contents: action.implementation)
    }

    func makeTransition(_ transition: Transition, withId id: Int, inState state: State, inMachine machine: Machine) -> FileWrapper? {
        create("State_" + state.name + "_Transition_" + String(id) + ".expr", contents: transition.condition ?? "")
    }

    func makeTransitionList(forState state: State, inMachine machine: Machine) -> FileWrapper? {
        let str: String
        if let first = state.transitions.first {
            str = state.transitions.dropFirst().reduce(first.target) { "\($0)\n" + $1.target }
        } else {
            str = ""
        }
        return create("State_" + state.name + "_Transitions", contents: str)
    }

    func makeStateList(forMachine machine: Machine) -> FileWrapper? {
        let str: String
        if let first = machine.states.first {
            str = machine.states.dropFirst().reduce(first.name) { "\($0)\n" + $1.name }
        } else {
            str = ""
        }
        return create("States", contents: str)
    }

    func makeExternalVariables(forMachine machine: Machine) -> FileWrapper? {
        create(
            "ExternalVariables.swift",
            contents: machine.externalVariables.lazy.map {
                self.varHelpers.makeDeclarationWithAvailableAssignment(forVariable: $0)
            }.joined(separator: "\n")
        )
    }

    func makeModelFile(forMachine machine: Machine, withModel model: Model) -> FileWrapper? {
        let dict: [String: Any] = [
            "actions": model.actions
        ]
        guard
            let json = self.encode(json: dict),
            let str = String(data: json, encoding: .utf8)
        else {
            return nil
        }
        return create("model.json", contents: str)
    }

    func makeDependenciesFile(named name: String, forMachine machine: Machine, dependencies: [Machine.Dependency]) -> FileWrapper? {
        let str: String = dependencies.map {
            ($0.name.map { $0 + " -> " } ?? "") + $0.pathComponent
        }.joined(separator: "\n")
        return create(name, contents: str)
    }

    func makeParametersFile(forMachine machine: Machine) -> FileWrapper? {
        guard
            let parameters = machine.parameters,
            let parametersPath = create(
                "Parameters.swift",
                contents: parameters.lazy.map {
                    self.varHelpers.makeDeclarationWithAvailableAssignment(forVariable: $0)
                }.joined(separator: "\n")
            )
        else {
            return nil
        }
        return parametersPath
    }

    fileprivate func encode(json: [String: Any]) -> Data? {
        #if os(macOS)
            if #available(macOS 10.13, *) {
                return try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
            } else {
                return try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            }
        #else
            return try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
        #endif
    }

}
