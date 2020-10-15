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
    
    private let assembler: MachineAssembler

    private let helpers: FileHelpers

    private let packageInitializer: PackageInitializer

    public var lastError: String? {
        return self.errors.last
    }

    public init(
        assembler: MachineAssembler = MachineAssembler(),
        helpers: FileHelpers = FileHelpers(),
        packageInitializer: PackageInitializer = PackageInitializer()
    ) {
        self.assembler = assembler
        self.helpers = helpers
        self.packageInitializer = packageInitializer
    }

    public func assemble(_ machines: [Machine], inDirectory buildDir: URL, name: String, machineBuildDir: String) -> (URL, [URL])? {
        let errorMsg = "Unable to assemble arrangement"
        var files: [URL] = []
        let flattenedMachines = self.flattenedMachines(machines)
        guard nil != flattenedMachines.failMap({
            self.assembler.assemble($0, inDirectory: $0.filePath.appendingPathComponent(machineBuildDir, isDirectory: true))
        }) else {
            self.errors.append(contentsOf: self.assembler.errors)
            return nil
        }
        if
            let data = try? Data(contentsOf: buildDir.appendingPathComponent("arrangement.json", isDirectory: false)),
            let token = try? JSONDecoder().decode(MachineToken<[Machine]>.self, from: data),
            token == MachineToken(data: flattenedMachines)
        {
            return (buildDir.appendingPathComponent("Arrangement", isDirectory: false), [])
        }
        guard
            let buildDir = self.helpers.overwriteDirectory(buildDir),
            let packageDir = self.packageInitializer.initialize(withName: "Arrangement", andType: .Executable, inDirectory: buildDir),
            let packageSwift = self.makePackage(forExecutable: name, forMachines: machines, inDirectory: packageDir, machineBuildDir: machineBuildDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        files.append(packageSwift)
        let sourceDir = packageDir.appendingPathComponent("Sources/Arrangement", isDirectory: true)
        guard
            let main = self.makeMain(forMachines: machines, inDirectory: sourceDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        if let data = try? JSONEncoder().encode(MachineToken(data: flattenedMachines)) {
            try? data.write(to: buildDir.appendingPathComponent("arrangement.json", isDirectory: false))
        }
        files.append(contentsOf: [main])
        return (packageDir, files)
    }
    
    private func makePackage(forExecutable executable: String, forMachines machines: [Machine], inDirectory path: URL, machineBuildDir: String, withAddedDependencies addedDependencies: [(URL)] = []) -> URL? {
        let packagePath = path.appendingPathComponent("Package.swift", isDirectory: false)
        let mandatoryDependencies: [String] = [
            ".package(url: \"ssh://git.mipal.net/git/swiftfsm.git\", .branch(\"binaries\"))"
        ]
        let machinePackages: [String] = self.machinePackageURLs(machines).map { (machine, url) in
            let url = String(url.appendingPathComponent(machineBuildDir + "/" + machine.name + "Machine").absoluteString.reversed().drop(while: { $0 == "/" }).reversed())
            return ".package(url: \"\(url)\", .branch(\"master\"))"
        }
        let machineProducts = self.machinePackageProducts(machines).map { $1 }
        let addedDependencyList: [String] = addedDependencies.map {
            let url = String($0.resolvingSymlinksInPath().absoluteString.reversed().drop(while: { $0 == "/" }).reversed())
            return ".package(url: \"\(url)\", .branch(\"master\"))"
        }
        let allConstructedDependencies = Set(addedDependencyList + mandatoryDependencies + machinePackages).sorted()
        let dependencies = allConstructedDependencies.isEmpty ? "" : "\n        " + allConstructedDependencies.combine("") { $0 + ",\n        " + $1 } + "\n    "
        let products = Set((machineProducts + ["swiftfsm_binaries"]).map { "\"" + $0 + "\"" }).sorted()
        let productList = products.combine("") { $0 + ", " + $1 }
        let str = """
            // swift-tools-version:5.1
            import PackageDescription

            let package = Package(
                name: "Arrangement",
                products: [
                    .executable(
                        name: "\(executable)",
                        targets: ["Arrangement"]
                    )
                ],
                dependencies: [\(dependencies)],
                targets: [
                    .target(name: "Arrangement", dependencies: [\(productList)])
                ]
            )

            """
        guard true == self.helpers.createFile(atPath: packagePath, withContents: str) else {
            self.errors.append("Unable to create Package.swift at \(packagePath.path)")
            return nil
        }
        return packagePath
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
        var dependencyList: [String: [String]] = Dictionary(uniqueKeysWithValues: uniqueNameMachines.map { ($0.name, $0.dependantMachines.map { $0.name }) })
        var callableList: [String: [String]] = Dictionary(uniqueKeysWithValues: uniqueNameMachines.map { ($0.name, $0.callableMachines.map { $0.name }) })
        var invocableList: [String: [String]] = Dictionary(uniqueKeysWithValues: uniqueNameMachines.map { ($0.name, $0.invocableMachines.map { $0.name }) })
        var processedMachines: Set<String> = uniqueNameSet
        func generateDependentMachines(_ machine: Machine, caller: String) -> Bool {
            for dependency in machine.dependantMachines {
                let name = caller + "." + dependency.name
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
                dependencyList[name] = dependency.dependantMachines.map { $0.name }
                if machine.callableMachines.contains(dependency) {
                    if nil == callableList[caller] {
                        callableList[caller] = [dependency.name]
                    } else {
                        callableList[caller]!.append(dependency.name)
                    }
                }
                if machine.invocableMachines.contains(dependency) {
                    if nil == invocableList[caller] {
                        invocableList[caller] = [dependency.name]
                    } else {
                        invocableList[caller]!.append(dependency.name)
                    }
                }
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
                self.errors.append("Cannot determine name of machine with key '\($0.key)'")
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
        let factoriesDict = "let factories = [\n" + keys.joined(separator: ",\n") + "\n]"
        func createDict(label: String, dict: [String: [String]]) -> String {
            let declaration = "let " + label + ": [String: [String]] = ["
            let body = dependencyList.map { "    \"" + $0.key + "\": [" + $0.value.map { "\"\($0)\"" }.joined(separator: ", ") + "]" }.joined(separator: ",\n")
            let end = "]"
            return declaration + "\n" + body + "\n" + end
        }
        let dependantMachines = createDict(label: "dependantMachines", dict: dependencyList)
        let callableMachines = createDict(label: "callableMachines", dict: callableList)
        let invocableMachines = createDict(label: "invocableMachines", dict: invocableList)
        let swiftfsm = "let swiftfsm = Swiftfsm()"
        let declarations = uniqueNameSet.sorted().map {
            return "let " + $0 + "Machine_instance = swiftfsm.makeMachine(name: \"" + $0 + "\", dependantMachines: dependantMachines, callableMachines: callableMachines, invocableMachines: invocableMachines, factories: factories)"
        }
        let machinesArr = "let machines = [" + uniqueNameSet.sorted().map { $0 + "Machine_instance" }.joined(separator: ", ") + "]"
        let runStatement = "swiftfsm.run(machines: machines)"
        let str = imports + "\n"
            + dependencyImports + "\n\n"
            + dependantMachines + "\n\n"
            + callableMachines + "\n\n"
            + invocableMachines + "\n\n"
            + factoriesDict + "\n\n"
            + swiftfsm + "\n\n"
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
    
    private func machinePackageURLs(_ machines: [Machine]) -> [(Machine, URL)] {
        return self.process(machines) {
            return $0.filePath.resolvingSymlinksInPath().absoluteURL
        }
    }
    
    private func machinePackageProducts(_ machines: [Machine]) -> [(Machine, String)] {
        return self.process(machines) { $0.name + "Machine" }
    }
    
    private func process<T>(_ machines: [Machine], _ transform: (Machine) -> T) -> [(Machine, T)] {
        var urls = Set<URL>()
        func _process(_ machines: [Machine]) -> [(Machine, T)] {
            return machines.flatMap { (machine) -> [(Machine, T)] in
                let machineUrl = machine.filePath.resolvingSymlinksInPath().absoluteURL
                if urls.contains(machineUrl) {
                    return []
                }
                urls.insert(machineUrl)
                return [(machine, transform(machine))] + _process(machine.dependantMachines)
            }
        }
        return _process(machines)
    }
    
    public func flattenedMachines(_ machines: [Machine]) -> [Machine] {
        var urls = Set<URL>()
        func _process(_ machines: [Machine]) -> [Machine] {
            return machines.flatMap { (machine) -> [Machine] in
                let machineUrl = machine.filePath.resolvingSymlinksInPath().absoluteURL
                if urls.contains(machineUrl) {
                    return []
                }
                urls.insert(machineUrl)
                return [machine] + _process(machine.dependantMachines)
            }
        }
        return _process(machines)
    }

}
