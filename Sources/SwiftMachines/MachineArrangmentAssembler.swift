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

    public func assemble(_ arrangement: Arrangement, machineBuildDir: String) -> (URL, [URL])? {
        self.errors = []
        let errorMsg = "Unable to assemble arrangement"
        var files: [URL] = []
        let flattenedMachines = arrangement.flattenedMachines
        guard nil != flattenedMachines.failMap({
            self.assembler.assemble($0, inDirectory: $0.filePath.appendingPathComponent(machineBuildDir, isDirectory: true))
        }) else {
            self.errors.append(contentsOf: self.assembler.errors)
            return nil
        }
        let fm = FileManager.default
        let buildDir = arrangement.filePath.appendingPathComponent(".build", isDirectory: true)
        if !fm.fileExists(atPath: buildDir.path) {
            guard nil != self.helpers.overwriteDirectory(buildDir) else {
                self.errors.append("Unable to create .build directory")
                return nil
            }
        }
        let arrangementToken = MachineToken(data: Set(flattenedMachines.map { $0.filePath.resolvingSymlinksInPath().absoluteString }).sorted())
        if
            let data = try? Data(contentsOf: buildDir.appendingPathComponent("arrangement.json", isDirectory: false)),
            let token = try? JSONDecoder().decode(MachineToken<[String]>.self, from: data),
            token == arrangementToken
        {
            let buildDir = arrangement.filePath
                .appendingPathComponent(".build", isDirectory: true)
                .appendingPathComponent("Arrangement", isDirectory: true)
            return (buildDir, [])
        }
        guard
            let packageDir = self.packageInitializer.initialize(withName: "Arrangement", andType: .Library, inDirectory: buildDir),
            let packageSwift = self.makePackage(forExecutable: arrangement.name, forMachines: arrangement.machines, inDirectory: packageDir, machineBuildDir: machineBuildDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        files.append(packageSwift)
        let sourceDir = packageDir.appendingPathComponent("Sources/Arrangement", isDirectory: true)
        guard
            let factory = self.makeFactory(arrangementName: arrangement.name, forMachines: arrangement.machines, inDirectory: sourceDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        if let data = try? JSONEncoder().encode(arrangementToken) {
            try? data.write(to: buildDir.appendingPathComponent("arrangement.json", isDirectory: false))
        }
        files.append(contentsOf: [factory])
        return (packageDir, files)
    }
    
    private func makePackage(forExecutable executable: String, forMachines machines: [Machine], inDirectory path: URL, machineBuildDir: String, withAddedDependencies addedDependencies: [(URL)] = []) -> URL? {
        let packagePath = path.appendingPathComponent("Package.swift", isDirectory: false)
        let mandatoryDependencies: [String] = []
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
        let products = Set((machineProducts).map { "\"" + $0 + "\"" }).sorted()
        let productList = products.combine("") { $0 + ", " + $1 }
        let str = """
            // swift-tools-version:5.1
            import PackageDescription

            let package = Package(
                name: "Arrangement",
                products: [
                    .library(
                        name: "\(executable)",
                        targets: ["Arrangement"]
                    )
                ],
                dependencies: [\(dependencies)],
                targets: [
                    .target(name: "Arrangement", dependencies: [\(productList)], linkerSettings: [.linkedLibrary("FSM")])
                ]
            )

            """
        guard true == self.helpers.createFile(atPath: packagePath, withContents: str) else {
            self.errors.append("Unable to create Package.swift at \(packagePath.path)")
            return nil
        }
        return packagePath
    }
    
    private func makeFactory(arrangementName: String, forMachines machines: [Machine], inDirectory dir: URL) -> URL? {
        let filePath = dir.appendingPathComponent("Arrangement.swift", isDirectory: false)
        let imports = (["import swiftfsm"] + machines.map { $0.name}.sorted().map { "import " + $0 + "Machine" }).joined(separator: "\n")
        var processedMachines: Set<String> = []
        func makeDependency(type: String, prefix: String, ancestors: [URL: String]) -> (Machine.Dependency) -> String {
            return {
                if let prefixedName = ancestors[$0.machine.filePath] {
                    return type + "(prefixedName: " + prefixedName + ", name: " + $0.callName + ")"
                }
                return type + "(prefixedName: " + prefix + $0.callName + ", name: " + $0.callName + ")"
            }
        }
        func process(_ machine: Machine, prefix: String, ancestors: inout [URL: String]) -> [String] {
            let prefixedName = prefix + machine.name
            if processedMachines.contains(prefixedName) {
                return []
            }
            processedMachines.insert(prefixedName)
            ancestors[machine.filePath] = prefixedName
            let depPrefix = prefixedName + "."
            let callables = machine.callables.map(makeDependency(type: "callable", prefix: depPrefix, ancestors: ancestors))
            let invocables = machine.invocables.map(makeDependency(type: "invocable", prefix: depPrefix, ancestors: ancestors))
            let subs = machine.subs.map(makeDependency(type: "controllable", prefix: depPrefix, ancestors: ancestors))
            let dependencies = "[" + (callables + invocables + subs).joined(separator: ", ") + "]"
            let entry = "\"" + prefixedName + "\": FlattenedMetaFSM(name: \"" + prefixedName + "\", factory: " + machine.name + "Machine.make_" + machine.name + ", dependencies: " + dependencies + ")"
            return [entry] + machine.dependencies.flatMap { process($0.machine, prefix: depPrefix, ancestors: &ancestors) }
        }
        let entries = machines.flatMap { (machine: Machine) -> [String] in
            var dict: [URL: String] = [:]
            return process(machine, prefix: "", ancestors: &dict)
        }
        let name = "\"" + arrangementName + "\""
        let fsms = "[" + entries.joined(separator: ",\n    ") + "]"
        let rootFsms = "[" + machines.map { "\"" + $0.name + "\"" }.joined(separator: ", ") + "]"
        let arrangement = """
            FlattenedMetaArrangement(
                    name: \(name),
                    fsms: \(fsms),
                    rootFSMs: \(rootFsms)
                )
            """
        let factory = """
            public func make_Arrangement() -> FlattenedMetaArrangement {
                return \(arrangement)
            }
            """
        let str = imports + "\n\n" + factory
        // Create the file.
        if (false == self.helpers.createFile(atPath: filePath, withContents: str)) {
            self.errors.append("Unable to create Arrangement.swift at \(filePath.path)")
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
                return [(machine, transform(machine))] + _process(machine.dependencies.map { $0.machine })
            }
        }
        return _process(machines)
    }

}
