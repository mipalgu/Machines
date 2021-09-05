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

    public func assemble(_ arrangement: Arrangement, atDirectory arrangementDir: URL, machineBuildDir: String) -> (URL, [URL])? {
        self.errors = []
        let errorMsg = "Unable to assemble arrangement"
        var files: [URL] = []
        let flattenedMachines = arrangement.flattenedMachines(relativeTo: arrangementDir)
        guard nil != flattenedMachines.failMap({
            return self.assembler.assemble($1, atDirectory: $0, inDirectory: $0.appendingPathComponent(machineBuildDir, isDirectory: true))
        }) else {
            self.errors.append(contentsOf: self.assembler.errors)
            return nil
        }
        let fm = FileManager.default
        let buildDir = arrangementDir.appendingPathComponent(".build", isDirectory: true)
        if !fm.fileExists(atPath: buildDir.path) {
            guard nil != self.helpers.overwriteDirectory(buildDir) else {
                self.errors.append("Unable to create .build directory")
                return nil
            }
        }
        let arrangementToken = MachineToken(data: Set(flattenedMachines.map { $0.0.resolvingSymlinksInPath().absoluteString }).sorted())
        if
            let data = try? Data(contentsOf: buildDir.appendingPathComponent("arrangement.json", isDirectory: false)),
            let token = try? JSONDecoder().decode(MachineToken<[String]>.self, from: data),
            token == arrangementToken
        {
            let buildDir = arrangementDir
                .appendingPathComponent(".build", isDirectory: true)
                .appendingPathComponent("Arrangement", isDirectory: true)
            return (buildDir, [])
        }
        guard
            let packageDir = self.packageInitializer.initialize(withName: "Arrangement", andType: .Library, inDirectory: buildDir),
            let packageSwift = self.makePackage(forExecutable: arrangement.name, forMachines: arrangement.machines(relativeTo: arrangementDir), inDirectory: packageDir, machineBuildDir: machineBuildDir)
        else {
            self.errors.append(errorMsg)
            return nil
        }
        files.append(packageSwift)
        let sourceDir = packageDir.appendingPathComponent("Sources/Arrangement", isDirectory: true)
        guard
            let factory = self.makeFactory(arrangementName: arrangement.name, forDependencies: arrangement.dependencies, machineDir: arrangementDir, inDirectory: sourceDir)
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
    
    private func makePackage(forExecutable executable: String, forMachines machines: [(URL, Machine)], inDirectory path: URL, machineBuildDir: String, withAddedDependencies addedDependencies: [(URL)] = []) -> URL? {
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
                        type: .dynamic,
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
    
    private func makeFactory(arrangementName: String, forDependencies dependencies: [Machine.Dependency], machineDir: URL, inDirectory dir: URL) -> URL? {
        let filePath = dir.appendingPathComponent("Arrangement.swift", isDirectory: false)
        let imports = (["import swiftfsm"] + Set(dependencies.flatMap { self.importStrings(forDependencies: $0, machineDir: machineDir) }).sorted()).joined(separator: "\n")
        var processedMachines: Set<String> = []
        func makeDependency(type: String, prefix: String, ancestors: [URL: String], filePath: URL, dependency: Machine.Dependency) -> String {
            if let prefixedName = ancestors[filePath] {
                return "." + type + "(prefixedName: \"" + prefixedName + "\", name: \"" + dependency.callName + "\")"
            }
            return "." + type + "(prefixedName: \"" + prefix + dependency.callName + "\", name: \"" + dependency.callName + "\")"
        }
        func process(_ dependency: Machine.Dependency, machineDir: URL, prefixedName: String, ancestors: [URL: String]) -> [String] {
            if processedMachines.contains(prefixedName) {
                return []
            }
            processedMachines.insert(prefixedName)
            var ancestors = ancestors
            ancestors[dependency.filePath(relativeTo: machineDir)] = prefixedName
            let depPrefix = prefixedName + "."
            let depMachine = dependency.machine(relativeTo: machineDir)
            let callables = depMachine.syncMachines(relativeTo: machineDir).map {
                makeDependency(type: "callable", prefix: depPrefix, ancestors: ancestors, filePath: $0, dependency: $1)
            }
            let invocables = depMachine.asyncMachines(relativeTo: machineDir).map {
                makeDependency(type: "invocables", prefix: depPrefix, ancestors: ancestors, filePath: $0, dependency: $1)
            }
            let subs = depMachine.subMachines(relativeTo: machineDir).map {
                makeDependency(type: "controllables", prefix: depPrefix, ancestors: ancestors, filePath: $0, dependency: $1)
            }
            let depURL = dependency.filePath(relativeTo: machineDir)
            let dependencies = "[" + (callables + invocables + subs).joined(separator: ", ") + "]"
            let entry = "\"" + prefixedName + "\": FlattenedMetaFSM(name: \"" + prefixedName + "\", factory: " + dependency.machineName + "Machine.make_" + dependency.machineName + ", dependencies: " + dependencies + ")"
            return [entry] + depMachine.dependencies.flatMap {
                process($0, machineDir: depURL, prefixedName: ancestors[$0.filePath(relativeTo: depURL)] ?? (depPrefix + $0.callName), ancestors: ancestors)
            }
        }
        let entries = dependencies.flatMap { (dependency: Machine.Dependency) -> [String] in
            process(dependency, machineDir: machineDir, prefixedName: dependency.callName, ancestors: [:])
        }
        let name = "\"" + arrangementName + "\""
        let fsms = "[" + entries.joined(separator: ",\n               ") + "]"
        let rootFsms = "[" + dependencies.map { "\"" + $0.callName + "\"" }.joined(separator: ", ") + "]"
        let arrangement = """
            FlattenedMetaArrangement(
                    name: \(name),
                    fsms: \(fsms),
                    rootFSMs: \(rootFsms)
                )
            """
        let factory = """
            public func make_\(arrangementName)(_ callback: (FlattenedMetaArrangement) -> Void) {
                callback(\(arrangement))
            }
            """
        let cFactory = """
            @_cdecl("make_Arrangement")
            public func make_Arrangement(_ pointer: UnsafeRawPointer) {
                let callback = pointer.assumingMemoryBound(to: ((FlattenedMetaArrangement) -> Void).self).pointee
                make_\(arrangementName)(callback)
            }
            """
        let str = imports + "\n\n" + cFactory + "\n\n" + factory
        // Create the file.
        if (false == self.helpers.createFile(atPath: filePath, withContents: str)) {
            self.errors.append("Unable to create Arrangement.swift at \(filePath.path)")
            return nil
        }
        return filePath
    }
    
    private func importStrings(forDependencies dependency: Machine.Dependency, machineDir: URL) -> [String] {
        var imports: Set<String> = []
        func _process(_ dependency: Machine.Dependency, parent: URL) {
            imports.insert("import " + dependency.machineName + "Machine")
            dependency.machine(relativeTo: parent).dependencies.forEach {
                _process($0, parent: $0.filePath(relativeTo: parent))
            }
        }
        _process(dependency, parent: machineDir)
        return Array(imports)
    }
    
    private func machinePackageURLs(_ machines: [(URL, Machine)]) -> [(Machine, URL)] {
        return self.process(machines) {
            return $0.0.resolvingSymlinksInPath().absoluteURL
        }
    }
    
    private func machinePackageProducts(_ machines: [(URL, Machine)]) -> [(Machine, String)] {
        return self.process(machines) { $1.name + "Machine" }
    }
    
    private func process<T>(_ machines: [(URL, Machine)], _ transform: ((URL, Machine)) -> T) -> [(Machine, T)] {
        var urls = Set<URL>()
        func _process(_ machines: [(URL, Machine)]) -> [(Machine, T)] {
            return machines.flatMap { (url, machine) -> [(Machine, T)] in
                let machineUrl = url.resolvingSymlinksInPath().absoluteURL
                if urls.contains(machineUrl) {
                    return []
                }
                urls.insert(machineUrl)
                return [(machine, transform((url, machine)))] + _process(machine.dependencies.map {
                    ($0.filePath(relativeTo: url), $0.machine(relativeTo: url))
                })
            }
        }
        return _process(machines)
    }

}
