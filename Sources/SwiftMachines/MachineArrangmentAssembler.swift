/*
 * MachineArrangmentAssembler.swift
 * SwiftMachines
 *
 * Created by Callum McColl on 14/10/20.
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

import IO
import Foundation
import swift_helpers

public final class MachineArrangmentAssembler: ErrorContainer {

    public private(set) var errors: [String] = []

    private let helpers: FileHelpers

    private let invoker: Invoker

    private let packageInitializer: PackageInitializer

    public var lastError: String? {
        return self.errors.last
    }

    private var takenVars: Set<String> = []

    private let varHelpers: VariableHelpers

    private let varParser: VarParser

    public init(
        helpers: FileHelpers = FileHelpers(),
        invoker: Invoker = Invoker(),
        packageInitializer: PackageInitializer = PackageInitializer(),
        varHelpers: VariableHelpers = VariableHelpers(),
        varParser: VarParser = VarParser()
    ) {
        self.helpers = helpers
        self.invoker = invoker
        self.packageInitializer = packageInitializer
        self.varHelpers = varHelpers
        self.varParser = varParser
    }

    public func packagePath(forMachine machine: Machine, builtInDirectory buildDir: URL) -> String {
        return buildDir
            .appendingPathComponent(machine.name + "Machine", isDirectory: true)
            .path
    }

    public func assemble(_ machines: [Machine], inDirectory buildDir: URL) -> (URL, [URL])? {
        let errorMsg = "Unable to assemble arrangement"
        var files: [URL] = []
        guard
            let buildDir = self.helpers.overwriteDirectory(buildDir),
            let packageDir = self.packageInitializer.initialize(withName: "Arrangement", andType: .Executable, inDirectory: buildDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        let sourceDir = packageDir.appendingPathComponent("Sources/Arrangment", isDirectory: true)
        guard
            let main = self.makeMain(forMachines: machines, inDirectory: sourceDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        files.append(contentsOf: [main])
        return (packageDir, files)
    }
    
    private func makeMain(forMachines machines: [Machine], inDirectory dir: URL) -> URL? {
        let filePath = dir.appendingPathComponent("main.swift", isDirectory: false)
        let imports = """
            import swiftfsm_binaries
            """
        var uniqueSet = Set<URL>()
        let uniqueURLMachines: [Machine] = machines.compactMap {
            let url = $0.filePath.resolvingSymlinksInPath().absoluteURL
            if uniqueSet.contains(url) {
                return nil
            }
            uniqueSet.insert(url)
            return $0
        }
        var uniqueNameSet = Set<String>()
        let uniqueNameMachines: [Machine] = machines.compactMap {
            if uniqueNameSet.contains($0.name) {
                return nil
            }
            uniqueNameSet.insert($0.name)
            return $0
        }
        var machineNames: Set<String> = Set(machines.map { $0.name })
        var urls: [URL: String] = Dictionary(uniqueKeysWithValues: uniqueURLMachines.map { ($0.filePath.resolvingSymlinksInPath().absoluteURL, $0.name) })
        var dependentMachines: [String: URL] = Dictionary(uniqueKeysWithValues: uniqueNameMachines.map { ($0.name, $0.filePath.resolvingSymlinksInPath().absoluteURL) })
        var processedMachines: Set<String> = uniqueNameSet
        func generateDependentMachines(_ machine: Machine, caller: String) -> Bool {
            for dependency in machine.dependantMachines {
                let name = caller + "_" + dependency.name
                if processedMachines.contains(name) {
                    continue
                }
                machineNames.insert(dependency.name)
                processedMachines.insert(name)
                let url = dependency.filePath.resolvingSymlinksInPath().absoluteURL
                if let previousName = urls[url], previousName != dependency.name {
                    self.errors.append("Found two machines with the same url '\(url)': \(previousName), \(dependency.name)")
                    return false
                }
                urls[url] = dependency.name
                if let previousURL = dependentMachines[name], previousURL != url {
                    self.errors.append("Machines must have unique names, found two machines with the same name '\(name)':\n    \(previousURL.path),\n    \(url.path)")
                    return false
                }
                dependentMachines[name] = url
                if false == generateDependentMachines(dependency, caller: name) {
                    return false
                }
            }
            return true
        }
        if nil == uniqueNameMachines.failMap({ generateDependentMachines($0, caller: $0.name) }) {
            return nil
        }
        guard let dependencies: [(label: String, name: String, url: URL)] = dependentMachines.sorted(by: { $0.key < $1.key }).failMap({
            guard let name = urls[$0.value] else {
                self.errors.append("Cannot determine name of machine with label '\($0.key)'")
                return nil
            }
            return (label: $0.key, name: name, url: $0.value)
        }) else {
            return nil
        }
        let dependencyImports = machineNames.sorted().map { "import " + $0 + "Machine" }.joined(separator: "\n")
        let keys: [String] = dependencies.map {
            return "    \"" + $0.label + "\": " + $0.name + "Machine.make_" + $0.name
        }
        let factoriesDict = "let factories = [\n" + keys.joined(separator: ", ") + "\n]"
        let declarations = uniqueNameSet.sorted().map {
            return "let " + $0 + "Machine = Swiftfsm.makeMachine(name: \"" + $0 + "\", factories: factories)"
        }
        let machinesArr = "[" + uniqueNameSet.sorted().map { $0 + "Machine" }.joined(separator: ", ") + "]"
        let runStatement = "Swiftfsm.run(machine: machines)"
        let str = imports + "\n"
            + dependencyImports + "\n\n"
            + factoriesDict + "\n\n"
            + declarations.joined(separator: "\n") + "\n"
            + machinesArr + "\n"
            + runStatement
        // Create the file.
        if (false == self.helpers.createFile(atPath: filePath, withContents: str)) {
            self.errors.append("Unable to create main.swift at \(filePath.path)")
            return nil
        }
        return filePath
    }

}
