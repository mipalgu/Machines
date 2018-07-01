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

import Machines
import Foundation
import IO

public final class MachineGenerator {

    private let helpers: FileHelpers

    private let varHelpers: VariableHelpers

    public init(helpers: FileHelpers = FileHelpers(), varHelpers: VariableHelpers = VariableHelpers()) {
        self.helpers = helpers
        self.varHelpers = varHelpers
    }

    public func generate(_ machine: Machine) -> (URL, [URL])? {
        guard
            let machineDir = self.helpers.overwriteDirectory(machine.filePath, ignoringSubFiles: [machine.filePath.appendingPathComponent("submachines", isDirectory: true)]),
            let swiftIncludePath = self.helpers.createFile(
                "SwiftIncludePath",
                inDirectory: machine.filePath,
                withContents: self.reduceList(machine.swiftIncludeSearchPaths)
            ),
            let includePath = self.helpers.createFile(
                "IncludePath",
                inDirectory: machine.filePath,
                withContents: self.reduceList(machine.includeSearchPaths)
            ),
            let libPath = self.helpers.createFile(
                "LibPath",
                inDirectory: machine.filePath,
                withContents: self.reduceList(machine.libSearchPaths)
            ),
            let imports = self.helpers.createFile(
                "\(machine.name)_Imports.swift",
                inDirectory: machine.filePath,
                withContents: machine.imports
            ),
            let vars = self.helpers.createFile(
                "\(machine.name)_Vars.swift",
                inDirectory: machine.filePath,
                withContents: machine.vars.reduce("") {
                    $0 + "\n" + self.varHelpers.makeDeclarationAndAssignment(forVariable: $1)
                }
            ),
            let stateFiles = self.makeStates(forMachine: machine),
            let stateList = self.makeStateList(forMachine: machine),
            let externalVariables = self.makeExternalVariables(forMachine: machine),
            let submachines = self.makeSubmachinesFile(forMachine: machine)
        else {
            return nil
        }
        var files = [swiftIncludePath, includePath, libPath, imports, vars, stateList, externalVariables, submachines]
        files.append(contentsOf: stateFiles)
        if let includes = machine.includes {
            guard let bridgingHeader = self.helpers.createFile(
                "\(machine.name)-Bridging-Header.h",
                inDirectory: machine.filePath,
                withContents: includes
            ) else {
                return nil
            }
            files.append(bridgingHeader)
        }
        if let model = machine.model {
            guard
                let ringletImports = self.helpers.createFile(
                    "Ringlet_Imports.swift",
                    inDirectory: machine.filePath,
                    withContents: model.ringlet.imports
                ),
                let ringletVars = self.helpers.createFile(
                    "Ringlet_Vars.swift",
                    inDirectory: machine.filePath,
                    withContents: model.ringlet.vars.reduce("") {
                        $0 + "\n" + self.varHelpers.makeDeclarationAndAssignment(forVariable: $1)
                    }
                ),
                let ringletExecute = self.helpers.createFile(
                    "Ringlet_Execute.swift",
                    inDirectory: machine.filePath,
                    withContents: model.ringlet.execute
                ),
                let modelFile = self.makeModelFile(forMachine: machine)
            else {
                return nil
            }
            files.append(contentsOf: [ringletImports, ringletVars, ringletExecute, modelFile])
        }
        return (machineDir, files)
    }

    func reduceList(_ list: [String], withSeparater separator: String = "\n") -> String {
        guard let first = list.first else {
            return ""
        }
        return list.dropFirst().reduce(first) { "\($0)" + separator + $1 }
    }

    func makeStates(forMachine machine: Machine) -> [URL]? {
        guard let files = machine.states.failMap({ self.makeState($0, forMachine: machine) }) else {
            return nil
        }
        return files.flatMap { $0 }
    }

    func makeState(_ state: State, forMachine machine: Machine) -> [URL]? {
        guard
            let actions = state.actions.failMap({
                self.makeAction($0, forState: state, inMachine: machine)
            }),
            let transitions = state.transitions.enumerated().failMap({
                self.makeTransition($1, withId: $0, inState: state, inMachine: machine)
            }),
            let transitionList = self.makeTransitionList(forState: state, inMachine: machine),
            let stateImports = self.helpers.createFile("State_\(state.name)_Imports.swift", inDirectory: machine.filePath, withContents: state.imports),
            let stateVars = self.helpers.createFile(
                "State_\(state.name)_Vars.swift",
                inDirectory: machine.filePath,
                withContents: state.vars.reduce("", {
                    $0 + "\n" + self.varHelpers.makeDeclarationAndAssignment(forVariable: $1)
                })
            )
        else {
            return nil
        }
        var result: [URL] = [transitionList, stateImports, stateVars]
        result.reserveCapacity(result.count + actions.count + transitions.count)
        result.append(contentsOf: actions)
        result.append(contentsOf: transitions)
        return result
    }

    func makeAction(_ action: Action, forState state: State, inMachine machine: Machine) -> URL? {
        let path = machine.filePath.appendingPathComponent("State_\(state.name)_\(action.name).swift", isDirectory: false)
        guard true == self.helpers.createFile(atPath: path, withContents: action.implementation) else {
            return nil
        }
        return path
    }

    func makeTransition(_ transition: Transition, withId id: Int, inState state: State, inMachine machine: Machine) -> URL? {
        let path = machine.filePath.appendingPathComponent("State_\(state.name)_Transition_\(id).expr", isDirectory: false)
        guard true == self.helpers.createFile(atPath: path, withContents: transition.condition ?? "") else {
            return nil
        }
        return path
    }

    func makeTransitionList(forState state: State, inMachine machine: Machine) -> URL? {
        let path = machine.filePath.appendingPathComponent("State_\(state.name)_Transitions", isDirectory: false)
        let str: String
        if let first = state.transitions.first {
            str = state.transitions.dropFirst().reduce(first.target) { "\($0)\n" + $1.target }
        } else {
            str = ""
        }
        guard true == self.helpers.createFile(atPath: path, withContents: str) else {
            return nil
        }
        return path
    }

    func makeStateList(forMachine machine: Machine) -> URL? {
        let path = machine.filePath.appendingPathComponent("States", isDirectory: false)
        let str: String
        if let first = machine.states.first {
            str = machine.states.dropFirst().reduce(first.name) { "\($0)\n" + $1.name }
        } else {
            str = ""
        }
        guard true == self.helpers.createFile(atPath: path, withContents: str) else {
            return nil
        }
        return path
    }

    func makeExternalVariables(forMachine machine: Machine) -> URL? {
        let path = machine.filePath.appendingPathComponent("externalVariables.json", isDirectory: false)
        var dict: [String: [String: Any]] = [:]
        machine.externalVariables.forEach {
            dict[$0.label] = [
                "wbName": $0.wbName,
                "atomic": $0.atomic,
                "shouldNotifySubscribers": $0.shouldNotifySubscribers,
                "type": $0.messageType,
                "class": $0.messageClass
            ]
        }
        let data = ["externalVariables": dict]
        guard
            let json = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys]),
            let str = String(data: json, encoding: .utf8),
            true == self.helpers.createFile(atPath: path, withContents: str)
        else {
            return nil
        }
        return path
    }

    func makeModelFile(forMachine machine: Machine) -> URL? {
        guard let model = machine.model else {
            return nil
        }
        let path = machine.filePath.appendingPathComponent("model.json", isDirectory: false)
        let dict: [String: Any] = [
            "actions": model.actions,
            "stateType": model.stateType
        ]
        guard
            let json = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
            let str = String(data: json, encoding: .utf8),
            true == self.helpers.createFile(atPath: path, withContents: str)
        else {
            return nil
        }
        return path
    }

    func makeSubmachinesFile(forMachine machine: Machine) -> URL? {
        let path = machine.filePath.appendingPathComponent("submachines.json", isDirectory: false)
        let submachinesJson: [[String: Any]] = Array(machine.states.lazy.filter { false == $0.submachines.isEmpty }.map {
            [
                "state": $0.name,
                "machines": $0.submachines.map { $0.name }
            ]
        })
        let dict: [String: Any] = [
            "controllers": submachinesJson
        ]
        guard
            let json = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys]),
            let str = String(data: json, encoding: .utf8),
            true == self.helpers.createFile(atPath: path, withContents: str)
        else {
            return nil
        }
        return path
    }

}
