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

import Foundation

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

    public func parseMachine(atPath path: String) -> Machine? {
        let realPath = NSString(string: path).standardizingPath
        let machineDir = URL(fileURLWithPath: realPath, isDirectory: true).resolvingSymlinksInPath()
        if let machine = self.cache[machineDir] {
            return machine
        }
        if (self.processing.contains(machineDir)) {
            self.errors.append("Recursive Machine detected when attempting to load: \(path).  Make sure you do not have cycles in your submachines!")
            return nil
        }
        self.processing.insert(machineDir)
        guard
            let model = self.parseModelFromMachine(atPath: machineDir),
            let actions = model?.actions ?? .some(["onEntry", "onExit", "main"]),
            let name = self.fetchMachineName(fromPath: machineDir),
            let externalVariables = self.parseExternalVariablesFromMachine(atPath: machineDir),
            let swiftIncludeSearchPaths = self.parseSwiftIncludeSearchPathsFromMachine(atPath: machineDir),
            let includeSearchPaths = self.parseIncludeSearchPathsFromMachine(atPath: machineDir),
            let libSearchPaths = self.parseLibSearchPathsFromMachine(atPath: machineDir),
            let imports = self.parseMachineImportsFromMachine(atPath: machineDir, withName: name),
            let vars = self.parseMachineVarsFromMachine(atPath: machineDir, withName: name),
            let parameters = self.parseMachineParametersFromMachine(atPath: machineDir, withName: name),
            let returnType = self.parseMachineReturnTypeFromMachine(atPath: machineDir, withName: name),
            let (parameterisedMachines, submachines) = self.parseDependencies(forMachineNamed: name, atPath: machineDir),
            let states = self.parseStatesFromMachine(atPath: machineDir, withActions: actions),
            let initialState = states.first,
            let includes = self.parseMachineBridgingHeaderFromMachine(atPath: machineDir, withName: name)
        else {
            self.processing.remove(machineDir)
            return nil
        }
        let suspendState = states.lazy.filter { "Suspend" == $0.name }.first
        let machine = Machine(
            name: name,
            filePath: machineDir,
            externalVariables: externalVariables,
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
            parameterisedMachines: parameterisedMachines
        )
        self.cache[machineDir] = machine
        self.processing.remove(machineDir)
        return machine
    }

    private func fetchMachineName(fromPath path: URL) -> String? {
        let lastComponent = path.lastPathComponent
        if (true == lastComponent.isEmpty) {
            return nil
        }
        return lastComponent.components(separatedBy: ".machine").first
    }

    private func parseExternalVariablesFromMachine(atPath path: URL) -> [ExternalVariables]? {
        let externalVariablesPath = path.appendingPathComponent("externalVariables.json", isDirectory: false)
        guard
            let data = try? Data(contentsOf: externalVariablesPath),
            let json = try? JSONSerialization.jsonObject(with: data),
            let content = json as? [String: Any],
            let arr = content["externalVariables"] as? [String: [String: Any]]
        else {
            self.errors.append("Unable to read \(externalVariablesPath.path)")
            return nil
        }
        var previous: Set<String> = []
        let externalVariables: [ExternalVariables] = arr.flatMap({
            let label = $0
            if (previous.contains(label)) {
                self.errors.append("\(label) is definined more than once in \(externalVariablesPath.path)")
                return nil
            }
            previous.insert(label)
            let wbName = $1["wbName"] as? String
            let atomic = $1["atomic"] as? Bool
            let shouldNotifySubscribers = $1["shouldNotifySubscribers"] as? Bool
            guard
                let messageType = $1["type"] as? String,
                let messageClass = $1["class"] as? String
            else {
                return nil
            }
            return ExternalVariables(
                label: label,
                wbName: wbName,
                messageType: messageType,
                messageClass: messageClass,
                atomic: atomic ?? true,
                shouldNotifySubscribers: shouldNotifySubscribers ?? true 
            )
        })
        if (externalVariables.count != arr.count) {
            self.errors.append("Could not read all external variables within \(externalVariablesPath.path)")
            return nil
        }
        return externalVariables
    }

    private func parseSwiftIncludeSearchPathsFromMachine(atPath path: URL) -> [String]? {
        let includesPath = path.appendingPathComponent("SwiftIncludePath", isDirectory: false)
        guard let paths = self.read(includesPath) else {
            self.errors.append("Unable to read \(includesPath.path)")
            return nil
        }
        let lines = paths.components(separatedBy: CharacterSet.newlines)
        return Array(lines.lazy.filter( { false == $0.isEmpty }))
    }

    private func parseIncludeSearchPathsFromMachine(atPath path: URL) -> [String]? {
        let includesPath = path.appendingPathComponent("IncludePath", isDirectory: false)
        guard let paths = self.read(includesPath) else {
            self.errors.append("Unable to read \(includesPath.path)")
            return nil
        }
        let lines = paths.components(separatedBy: CharacterSet.newlines)
        return Array(lines.lazy.filter( { false == $0.isEmpty }))
    }

    private func parseLibSearchPathsFromMachine(atPath path: URL) -> [String]? {
        let libPath = path.appendingPathComponent("LibPath", isDirectory: false)
        guard let paths = self.read(libPath) else {
            self.errors.append("Unable to read \(libPath.path)")
            return nil
        }
        let lines = paths.components(separatedBy: CharacterSet.newlines)
        return Array(lines.lazy.filter( { false == $0.isEmpty }))
    }

    private func parseMachineImportsFromMachine(atPath path: URL, withName name: String) -> String? {
        let importsPath = path.appendingPathComponent("\(name)_Imports.swift", isDirectory: false)
        guard
            let imports = self.read(importsPath)
        else {
            self.errors.append("Unable to read \(importsPath.path)")
            return nil
        }
        return imports
    }

    private func parseMachineBridgingHeaderFromMachine(atPath path: URL, withName name: String) -> String?? {
        let headerPath = path.appendingPathComponent("\(name)-Bridging-Header.h", isDirectory: false)
        return .some(self.read(headerPath))
    }

    private func parseMachineVarsFromMachine(atPath path: URL, withName name: String) -> [Variable]? {
        let varsPath = path.appendingPathComponent("\(name)_Vars.swift")
        guard
            let str = self.read(varsPath),
            let vars = self.varParser.parse(fromString: str)
        else {
            self.errors.append("Unable to read \(varsPath.path)")
            return nil
        }
        return vars 
    }

    private func parseMachineParametersFromMachine(atPath path: URL, withName name: String) -> [Variable]?? {
        let parametersPath = path.appendingPathComponent("\(name)_Parameters.swift")
        guard let str = self.read(parametersPath) else {
            return .some(.none)
        }
        guard let vars = self.varParser.parse(fromString: str) else {
            self.errors.append("Unable to parse \(parametersPath.path)")
            return .none
        }
        return .some(.some(vars))
    }

    private func parseMachineReturnTypeFromMachine(atPath path: URL, withName name: String) -> String?? {
        let returnTypePath = path.appendingPathComponent("\(name)_ReturnType.swift")
        guard let str = self.read(returnTypePath) else {
            return .some(.none)
        }
        return .some(.some(str))
    }

    private func parseModelFromMachine(atPath path: URL) -> Model?? {
        let modelPath = path.appendingPathComponent("model.json", isDirectory: false)
        let importsPath = path.appendingPathComponent("Ringlet_Imports.swift", isDirectory: false)
        let varsPath = path.appendingPathComponent("Ringlet_Vars.swift", isDirectory: false)
        let executePath = path.appendingPathComponent("Ringlet_Execute.swift", isDirectory: false)
        guard 
            let modelData = try? Data(contentsOf: modelPath)
        else {
            return .some(.none)
        }
        guard
            let imports = self.attempt("Unable to read Ringlet_Imports.swift", { self.read(importsPath) }),
            let varsRaw = self.attempt("Unable to read Ringlet_Vars.swift", { self.read(varsPath) }),
            let vars = self.attempt("Unable to parse vars from Ringlet_Vars.swift", { self.varParser.parse(fromString: varsRaw) }),
            let execute = self.attempt("Unable to read Ringlet_Execute.swift", { self.read(executePath) })
        else {
            return .none
        }
        if true == execute.isEmpty {
            self.errors.append("\(executePath.path) must not be empty")
            return .none
        }
        guard
            let modelJson = try? JSONSerialization.jsonObject(with: modelData),
            let model = modelJson as? [String: Any],
            let actions = model["actions"] as? [String]
        else {
            self.errors.append("Unable to parse \(modelPath.path)")
            return .none
        }
        if (true == actions.isEmpty) {
            self.errors.append("There must be at least one action in \(modelPath.path)")
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

    private func parseDependencies(forMachineNamed name: String, atPath path: URL) -> ([Machine], [Machine])? {
        let dependenciesPath = path.appendingPathComponent("dependencies.json", isDirectory: false)
        guard
            let data = try? Data(contentsOf: dependenciesPath)
        else {
            return ([], [])
        }
        guard
            let temp = try? JSONSerialization.jsonObject(with: data),
            let json = temp as? [String: Any],
            let parameterised = json["parameterised"] as? [String],
            let submachines = json["submachines"] as? [String]
        else {
            self.errors.append("Unable to read \(dependenciesPath.path)")
            return nil
        }
        let dependenciesDir = path.appendingPathComponent("dependencies/", isDirectory: true)
        func loadDependency(machineName: String) -> Machine? {
            let machinePath = dependenciesDir.appendingPathComponent("\(machineName).machine", isDirectory: true)
            guard let machine = self.parseMachine(atPath: machinePath.path) else {
                self.errors.append("Unable to load machine at: \(machinePath.path)")
                return nil
            }
            guard machine.name != name else {
                self.errors.append("You cannot have a dependent machine \(machine.filePath.path) having the same name as the parent machine.")
                return nil
            }
            return machine
        }
        guard
            let parameterisedMachines = parameterised.failMap(loadDependency),
            let submachinesMachines = submachines.failMap(loadDependency)
        else {
            return nil
        }
        return (parameterisedMachines, submachinesMachines)
    }

    private func parseStatesFromMachine(atPath path: URL, withActions actions: [String]) -> [State]? {
        let statesPath = path.appendingPathComponent("States", isDirectory: false)
        guard
            let statesContents = self.read(statesPath)
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
        let states = statesLines.flatMap {
            self.parseStateFromMachine(atPath: path, withName: $0, andActions: actions)
        }
        if (states.count != statesLines.count) {
            return nil
        }
        return Array(states)
    }

    private func parseStateFromMachine(atPath path: URL, withName name: String, andActions actionNames: [String]) -> State? {
        let base = "State_\(name)"
        let importsPath = path.appendingPathComponent("\(base)_Imports.swift", isDirectory: false)
        let varsPath = path.appendingPathComponent("\(base)_Vars.swift", isDirectory: false)
        guard
            let imports = self.attempt("Unable to read \(importsPath)", { self.read(importsPath) }),
            let varsRaw = self.attempt("Unable to read \(varsPath)", { self.read(varsPath) }),
            let vars = self.attempt("Unable to parse vars in \(varsPath)", { self.varParser.parse(fromString: varsRaw) })
        else {
            return nil
        }
        let actions = actionNames.flatMap {
            self.parseActionFromMachine(atPath: path, forState: name, withName: $0)
        }
        if (actions.count != actionNames.count) {
            return nil
        }
        guard
            let transitions = self.parseTransitionsFromMachine(atPath: path, forState: name)
        else {
            return nil
        }
        return State(
            name: name,
            imports: imports,
            vars: vars,
            actions: actions,
            transitions: transitions
        )
    }

    private func parseActionFromMachine(atPath path: URL, forState state: String, withName name: String) -> Action? {
        let actionPath = path.appendingPathComponent("State_\(state)_\(name).swift", isDirectory: false)
        guard
            let implementation = self.read(actionPath)
        else {
            self.errors.append("Unable to read \(actionPath.path)")
            return nil
        }
        return Action(name: name, implementation: implementation)
    }

    private func parseTransitionsFromMachine(atPath path: URL, forState state: String) -> [Transition]? {
        let transitionsPath = path.appendingPathComponent("State_\(state)_Transitions", isDirectory: false)
        guard
            let transitionsContents = self.read(transitionsPath)
        else {
            self.errors.append("Unable to read \(transitionsPath.path)")
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
                    atPath: path,
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

    private func parseTransitionFromMachine(atPath path: URL, forState state: String, andTransition id: Int, targeting target: String) -> Transition? {
        let transitionPath = path.appendingPathComponent("State_\(state)_Transition_\(id).expr", isDirectory: false)
        guard
            let condition = self.read(transitionPath)
        else {
            self.errors.append("Unable to read \(transitionPath.path)")
            return nil
        }
        return Transition(target: target, condition: true == condition.isEmpty ? nil : condition)
    }

    private func read(_ path: URL) -> String? {
        return try? String(
            contentsOf: path,
            encoding: String.Encoding.utf8
        ).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

}
