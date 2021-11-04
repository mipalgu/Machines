/*
 * MachineParser.swift 
 * Machines 
 *
 * Created by Callum McColl on 19/02/2017.
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

/* This reads files that should be a LLFSM and return an object of class Machine
 */
import Foundation
#if os(Linux)
import IO
#endif
import MetaLanguage

public final class MachineParser: ErrorContainer {

    public private(set) var errors: [String] = []

    public var lastError: String? {
        return self.errors.last
    }

    private var cache: [URL: Machine] = [:]

    private var processing: Set<URL> = []

    private let varParser: VarParser

    public init(varParser: VarParser = VarParser()) {
        self.varParser = varParser
    }

    public func attempt<T>(_ error: String, _ f: () -> T?) -> T? {
        guard let result = f() else {
            self.errors.append(error)
            return nil
        }
        return result
    }
    
    public func parseMachine(_ wrapper: FileWrapper) -> Machine? {
        guard
            let model = self.parseModelFromMachine(wrapper),
            let actions = model?.actions ?? .some(["onEntry", "onExit", "main"]),
            let name = self.fetchMachineName(from: wrapper.filename),
            let externalVariables = self.parseExternalVariablesFromMachine(wrapper, withName: name),
            let packageDependencies = self.parsePackageDependenciesFromMachine(wrapper),
            let swiftIncludeSearchPaths = self.parseSwiftIncludeSearchPathsFromMachine(wrapper),
            let includeSearchPaths = self.parseIncludeSearchPathsFromMachine(wrapper),
            let libSearchPaths = self.parseLibSearchPathsFromMachine(wrapper),
            let imports = self.parseMachineImportsFromMachine(wrapper, withName: name),
            let vars = self.parseMachineVarsFromMachine(wrapper, withName: name),
            let parameters = self.parseMachineParametersFromMachine(wrapper, withName: name),
            let returnType = self.parseMachineReturnTypeFromMachine(wrapper, withName: name),
            let (callableMachines, invocableMachines, submachines) = self.parseAllDependenciesFromMachine(wrapper),
            let states = self.parseStatesFromMachine(wrapper, withActions: actions, externalVariables: externalVariables),
            !states.isEmpty,
            let includes = self.parseMachineBridgingHeaderFromMachine(wrapper, withName: name)
        else {
            return nil
        }
        let initialState = states[0]
        let suspendState = states.lazy.filter { "Suspend" == $0.name }.first
        let tests = self.parseTestsFromMachine(wrapper, withName: name)
        let machine = Machine(
            name: name,
            externalVariables: externalVariables,
            packageDependencies: packageDependencies,
            swiftIncludeSearchPaths: swiftIncludeSearchPaths,
            includeSearchPaths: includeSearchPaths,
            libSearchPaths: libSearchPaths,
            imports: imports,
            includes: includes,
            vars: vars,
            model: model,
            parameters: parameters,
            returnType: returnType,
            initialState: initialState,
            suspendState: suspendState,
            states: states,
            submachines: submachines,
            callableMachines: callableMachines,
            invocableMachines: invocableMachines,
            tests: tests
        )
        return machine
    }
    
    public func parseMachine(at directory: URL) -> Machine? {
        parseMachine(atPath: directory.path)
    }

    public func parseMachine(atPath path: String) -> Machine? {
        let realPath = NSString(string: path).standardizingPath
        let machineDir = URL(fileURLWithPath: realPath, isDirectory: true).resolvingSymlinksInPath()
        if let machine = self.cache[machineDir] {
            return machine
        }
        let wrapper: FileWrapper
        do {
            wrapper = try FileWrapper(url: machineDir, options: .immediate)
        } catch let e {
            self.errors.append(e.localizedDescription)
            return nil
        }
        guard let machine = parseMachine(wrapper) else {
            return nil
        }
        self.cache[machineDir] = machine
        return machine
    }
    
    private func wrapper(named name: String, in wrapper: FileWrapper) -> FileWrapper? {
        guard let file = wrapper.fileWrappers?[name] else {
            self.errors.append("Unable to read contents of \(name)")
            return nil
        }
        return file
    }
    
    private func data(ofFile file: String, in wrapper: FileWrapper) -> Data? {
        self.wrapper(named: file, in: wrapper).flatMap {
            $0.regularFileContents
        }
    }
    
    private func read(file name: String, in wrapper: FileWrapper) -> String? {
        return self.wrapper(named: name, in: wrapper).flatMap {
            self.read($0)
        }
    }

    private func fetchMachineName(from fileName: String?) -> String? {
        guard let fileName = fileName else {
            return nil
        }
        if (true == fileName.isEmpty) {
            return nil
        }
        return fileName.components(separatedBy: ".machine").first
    }

    private func parseExternalVariablesFromMachine(_ wrapper: FileWrapper, withName name: String) -> [Variable]? {
        guard let str = read(file: "ExternalVariables.swift", in: wrapper) else {
            return nil
        }
        guard let vars = self.varParser.parse(fromString: str) else {
            return nil
        }
        return vars
    }

    private func parseTestsFromMachine(_ wrapper: FileWrapper, withName name: String) -> TestSuite? {
        guard let file = wrapper.fileWrappers?["tests"]?.fileWrappers?["\(name)Tests"] else {
            return nil
        }
        return TestSuite(wrapper: file)
    }
    
    private func parsePackageDependenciesFromMachine(_ wrapper: FileWrapper) -> [PackageDependency]? {
        guard let data = data(ofFile: "packageDependencies.json", in: wrapper) else {
            return nil
        }
        let packageDependencies: [PackageDependency]
        do {
            packageDependencies = try JSONDecoder().decode([PackageDependency].self, from: data)
        } catch let e {
            self.errors.append("\(e)")
            return nil
        }
        return packageDependencies
    }

    private func parseSwiftIncludeSearchPathsFromMachine(_ wrapper: FileWrapper) -> [String]? {
        guard let paths = read(file: "SwiftIncludePath", in: wrapper) else {
            return nil
        }
        let lines = paths.components(separatedBy: CharacterSet.newlines)
        return Array(lines.lazy.filter( { false == $0.isEmpty }))
    }

    private func parseIncludeSearchPathsFromMachine(_ wrapper: FileWrapper) -> [String]? {
        guard let paths = read(file: "IncludePath", in: wrapper) else {
            return nil
        }
        let lines = paths.components(separatedBy: CharacterSet.newlines)
        return Array(lines.lazy.filter( { false == $0.isEmpty }))
    }

    private func parseLibSearchPathsFromMachine(_ wrapper: FileWrapper) -> [String]? {
        guard let paths = read(file: "LibPath", in: wrapper) else {
            return nil
        }
        let lines = paths.components(separatedBy: CharacterSet.newlines)
        return Array(lines.lazy.filter( { false == $0.isEmpty }))
    }

    private func parseMachineImportsFromMachine(_ wrapper: FileWrapper, withName name: String) -> String? {
        read(file: "Imports.swift", in: wrapper)
    }

    private func parseMachineBridgingHeaderFromMachine(_ wrapper: FileWrapper, withName name: String) -> String?? {
        .some(read(file: "Bridging-Header.h", in: wrapper))
    }

    private func parseMachineVarsFromMachine(_ wrapper: FileWrapper, withName name: String) -> [Variable]? {
        let fileName = "Vars.swift"
        guard let str = read(file: "Vars.swift", in: wrapper) else {
            return nil
        }
        guard let vars = self.varParser.parse(fromString: str) else {
            self.errors.append("Unable to parse \(fileName).")
            return nil
        }
        return vars 
    }

    private func parseMachineParametersFromMachine(_ wrapper: FileWrapper, withName name: String) -> [Variable]?? {
        let fileName = "Parameters.swift"
        guard let str = self.read(file: fileName, in: wrapper) else {
            return .some(.none)
        }
        guard let vars = self.varParser.parse(fromString: str) else {
            self.errors.append("Unable to parse \(fileName)")
            return .none
        }
        return .some(.some(vars))
    }

    private func parseMachineReturnTypeFromMachine(_ wrapper: FileWrapper, withName name: String) -> String?? {
        guard let str = self.read(file: "ReturnType.swift", in: wrapper) else {
            return .some(.none)
        }
        return .some(.some(str))
    }

    private func parseModelFromMachine(_ wrapper: FileWrapper) -> Model?? {
        let modelFile = "model.json"
        guard 
            let modelData = data(ofFile: modelFile, in: wrapper)
        else {
            return .some(.none)
        }
        let executeFile = "Ringlet_Execute.swift"
        guard
            let imports = self.attempt("Unable to read Ringlet_Imports.swift", { self.read(file: "Ringlet_Imports.swift", in: wrapper) }),
            let varsRaw = self.attempt("Unable to read Ringlet_Vars.swift", { self.read(file: "Ringlet_Vars.swift", in: wrapper) }),
            let vars = self.attempt("Unable to parse vars from Ringlet_Vars.swift", { self.varParser.parse(fromString: varsRaw) }),
            let execute = self.attempt("Unable to read Ringlet_Execute.swift", { self.read(file: "Ringlet_Execute.swift", in: wrapper) })
        else {
            return .none
        }
        if true == execute.isEmpty {
            self.errors.append("\(executeFile) must not be empty")
            return .none
        }
        guard
            let modelJson = try? JSONSerialization.jsonObject(with: modelData),
            let model = modelJson as? [String: Any],
            let actions = model["actions"] as? [String]
        else {
            self.errors.append("Unable to parse \(modelFile)")
            return .none
        }
        if (true == actions.isEmpty) {
            self.errors.append("There must be at least one action in \(modelFile)")
            return .none
        }
        return .some(Model(
            actions: actions,
            ringlet: Ringlet(
                imports: imports,
                vars: vars,
                execute: execute
            )
        ))
    }

    private func parseAllDependenciesFromMachine(_ wrapper: FileWrapper) -> ([Machine.Dependency], [Machine.Dependency], [Machine.Dependency])? {
        guard
            let syncMachines = read(file: "SyncMachines", in: wrapper),
            let asyncMachines = read(file: "ASyncMachines", in: wrapper),
            let subMachines = read(file: "SubMachines", in: wrapper)
        else {
            return nil
        }
        guard
            let callables = self.parseDependencies(syncMachines),
            let invocables = self.parseDependencies(asyncMachines),
            let submachines = self.parseDependencies(subMachines)
        else {
            self.errors.append("Unable to parse dependencies.")
            return nil
        }
        return (callables, invocables, submachines)
    }
    
    private func parseDependencies(_ str: String) -> [Machine.Dependency]? {
        let lines = str.components(separatedBy: .newlines).lazy.map { $0.trimmingCharacters(in: .whitespaces)}.filter { $0 != "" }
        guard let dependencies: [Machine.Dependency] = lines.failMap({
            let components = $0.components(separatedBy: "->")
            guard let first = components.first else {
                return nil
            }
            let name: String?
            let filePath: String
            if components.count == 1 {
                name = nil
                filePath = $0
            } else {
                name = first
                filePath = components.dropFirst().joined(separator: "->")
            }
            guard let dependency = Machine.Dependency(
                    name: name?.trimmingCharacters(in: .whitespaces),
                    pathComponent: filePath.trimmingCharacters(in: .whitespaces)
                )
            else {
                self.errors.append("Unable to parse dependency \($0)")
                return nil
            }
            return dependency
        }) else {
            return nil
        }
        return dependencies
    }

    private func parseStatesFromMachine(_ wrapper: FileWrapper, withActions actions: [String], externalVariables: [Variable]) -> [State]? {
        let externalVariables: [String: Variable] = Dictionary(uniqueKeysWithValues: externalVariables.lazy.map { ($0.label, $0) })
        guard
            let statesContents = self.read(file: "States", in: wrapper)
        else {
            self.errors.append("Unable to read States")
            return nil
        }
        let statesLines = statesContents.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            ).components(separatedBy: "\n").lazy.map {
                $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }.filter { false == $0.isEmpty }
        if (statesLines.count < 1) {
            self.errors.append("States is empty")
            return nil
        }
        guard let states = statesLines.failMap({
            self.parseStateFromMachine(wrapper, withName: $0, andActions: actions, externalVariables: externalVariables)
        })
        else {
            return nil
        }
        return Array(states)
    }

    private func parseStateFromMachine(_ wrapper: FileWrapper, withName name: String, andActions actionNames: [String], externalVariables: [String: Variable]) -> State? {
        let base = "State_\(name)"
        let importsName = base + "_Imports.swift"
        let varsName = base + "_Vars.swift"
        guard
            let imports = self.attempt("Unable to read \(importsName)", { self.read(file: importsName, in: wrapper) }),
            let varsRaw = self.attempt("Unable to read \(varsName)", { self.read(file: varsName, in: wrapper) }),
            let vars = self.attempt("Unable to parse vars in \(varsName)", { self.varParser.parse(fromString: varsRaw) })
        else {
            return nil
        }
        
        let extVars: [Variable]
        if let externalVariablesRaw = self.read(file: base + "_ExternalVariables.swift", in: wrapper) {
            guard let externalVariables = externalVariablesRaw.components(separatedBy: .newlines).map({$0.trimmingCharacters(in: .whitespaces)}).filter({ $0 != "" }).failMap({ external in
                return self.attempt("Unable to location external variable \(external)", { externalVariables[external] })
            })
            else {
                return nil
            }
            extVars = externalVariables
        } else {
            extVars = []
        }
        guard let actions = actionNames.failMap({
            self.parseActionFromMachine(wrapper, forState: name, withName: $0)
        })
        else {
            return nil
        }
        guard
            let transitions = self.parseTransitionsFromMachine(wrapper, forState: name)
        else {
            return nil
        }
        return State(
            name: name,
            imports: imports,
            externalVariables: extVars,
            vars: vars,
            actions: actions,
            transitions: transitions
        )
    }

    private func parseActionFromMachine(_ wrapper: FileWrapper, forState state: String, withName name: String) -> Action? {
        let actionName = "State_" + state + "_" + name + ".swift"
        guard let implementation = self.read(file: actionName, in: wrapper) else {
            self.errors.append("Unable to read \(actionName)")
            return nil
        }
        return Action(name: name, implementation: implementation)
    }

    private func parseTransitionsFromMachine(_ wrapper: FileWrapper, forState state: String) -> [Transition]? {
        let transitionName = "State_\(state)_Transitions"
        guard let transitionsContents = self.read(file: transitionName, in: wrapper) else {
            self.errors.append("Unable to read \(transitionName)")
            return nil
        }
        let transitionsLines = Array(transitionsContents.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            ).components(separatedBy: "\n").lazy.map {
                $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            }.filter { false == $0.isEmpty })
        var transitions: [Transition] = []
        transitions.reserveCapacity(transitionsLines.count)
        for i in 0..<transitionsLines.count {
            guard 
                let transition = self.parseTransitionFromMachine(
                    wrapper,
                    forState: state,
                    andTransition: i,
                    targeting: transitionsLines[i]
                )
            else {
                return nil
            }
            transitions.append(transition)
        }
        return transitions
    }

    private func parseTransitionFromMachine(_ wrapper: FileWrapper, forState state: String, andTransition id: Int, targeting target: String) -> Transition? {
        let file = "State_\(state)_Transition_\(id).expr"
        guard let condition = self.read(file: file, in: wrapper) else {
            self.errors.append("Unable to read \(file)")
            return nil
        }
        return Transition(target: target, condition: true == condition.isEmpty ? nil : condition)
    }

    private func read(_ wrapper: FileWrapper) -> String? {
        guard
            let data = wrapper.regularFileContents,
            let str = String(data: data, encoding: .utf8)
        else {
            self.errors.append("Unable to read contents of file \(wrapper.filename ?? "")")
            return nil
        }
        return str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}
