/*
 * MachineCompiler.swift 
 * Machines 
 *
 * Created by Callum McColl on 22/02/2017.
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

/* This takes a packaged machine and compiles it
 */

import Foundation

@available(macOS 10.11, *)
public class MachineCompiler<A: Assembler>: ErrorContainer where A: ErrorContainer {

    public fileprivate(set) var errors: [String] = []
    
    public var lastError: String? {
        return self.errors.last
    }
    
    private let assembler: A

    private let invoker: Invoker
    
    fileprivate var processedMachines: Set<String> = []

    public init(assembler: A, invoker: Invoker = Invoker()) {
        self.assembler = assembler
        self.invoker = invoker
    }

    public func outputPath(forMachine machine: Machine, builtInDirectory buildDir: String) -> String {
        return self.outputURL(forMachine: machine, builtInDirectory: buildDir).path
    }
    
    public func outputURL(forMachine machine: Machine, builtInDirectory buildDir: String) -> URL {
        #if os(macOS)
        let ext = ".dylib"
        #else
        let ext = ".so"
        #endif
        let buildDirPath = machine.filePath.appendingPathComponent(buildDir, isDirectory: true)
        return URL(fileURLWithPath: self.assembler.packagePath(forMachine: machine, builtInDirectory: buildDirPath), isDirectory: true)
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("release", isDirectory: true)
            .appendingPathComponent("lib" + machine.name + "Machine" + ext, isDirectory: false)
    }

    public func shouldCompile(_ machine: Machine, inDirectory buildDir: String) -> Bool {
        let fm = FileManager.default
        return false == fm.fileExists(atPath: self.outputPath(forMachine: machine, builtInDirectory: buildDir))
    }

    public func compile(
        _ machine: Machine,
        withBuildDir buildDir: String,
        withCCompilerFlags cCompilerFlags: [String] = [],
        andCXXCompilerFlags cxxCompilerFlags: [String] = [],
        andLinkerFlags linkerFlags: [String] = [],
        andSwiftCompilerFlags swiftCompilerFlags: [String] = [],
        andSwiftBuildFlags swiftBuildFlags: [String] = []
    ) -> String? {
        self.errors = []
        guard
            let (_, outputPath) = self.compileMachine(
                    machine,
                    withBuildDir: buildDir,
                    withCCompilerFlags: cCompilerFlags,
                    andCXXCompilerFlags: cxxCompilerFlags,
                    andLinkerFlags: linkerFlags,
                    andSwiftCompilerFlags: swiftCompilerFlags,
                    andSwiftBuildFlags: swiftBuildFlags
                )
        else {
            return nil
        }
        return outputPath.path
    }
    
    public func compileTree(
        _ machine: Machine,
        withBuildDir buildDir: String,
        withCCompilerFlags cCompilerFlags: [String] = [],
        andCXXCompilerFlags cxxCompilerFlags: [String] = [],
        andLinkerFlags linkerFlags: [String] = [],
        andSwiftCompilerFlags swiftCompilerFlags: [String] = [],
        andSwiftBuildFlags swiftBuildFlags: [String] = []
    ) -> [String]? {
        self.errors = []
        self.processedMachines = []
        return self.compileTreeReal(
            machine,
            withBuildDir: buildDir,
            withCCompilerFlags: cCompilerFlags,
            andCXXCompilerFlags: cxxCompilerFlags,
            andLinkerFlags: linkerFlags,
            andSwiftCompilerFlags: swiftCompilerFlags,
            andSwiftBuildFlags: swiftBuildFlags
        )
    }
    
    fileprivate func compileTreeReal(
        _ machine: Machine,
        withBuildDir buildDir: String,
        withCCompilerFlags cCompilerFlags: [String] = [],
        andCXXCompilerFlags cxxCompilerFlags: [String] = [],
        andLinkerFlags linkerFlags: [String] = [],
        andSwiftCompilerFlags swiftCompilerFlags: [String] = [],
        andSwiftBuildFlags swiftBuildFlags: [String] = [],
        subdirs: [String] = []
    ) -> [String]? {
        guard
            let dependentMachines = machine.dependantMachines.failMap({
                self.compileTreeReal(
                    $0,
                    withBuildDir: buildDir,
                    withCCompilerFlags: cCompilerFlags,
                    andCXXCompilerFlags: cxxCompilerFlags,
                    andLinkerFlags: linkerFlags,
                    andSwiftCompilerFlags: swiftCompilerFlags,
                    andSwiftBuildFlags: swiftBuildFlags,
                    subdirs: subdirs + [$0.name]
                )
            })?.flatMap({ $0 }),
            let (_, outputPath) = self.compileMachine(
                machine,
                withBuildDir: buildDir,
                withCCompilerFlags: cCompilerFlags,
                andCXXCompilerFlags: cxxCompilerFlags,
                andLinkerFlags: linkerFlags,
                andSwiftCompilerFlags: swiftCompilerFlags,
                andSwiftBuildFlags: swiftBuildFlags
            ),
            true == self.copyCompiledDependentMachines(machine, buildDir: buildDir, subdirs: subdirs, dependencies: dependentMachines)
        else {
            return nil
        }
        return [outputPath.path]
    }

    private func compileMachine(
        _ machine: Machine,
        withBuildDir buildDir: String,
        withCCompilerFlags cCompilerFlags: [String],
        andCXXCompilerFlags cxxCompilerFlags: [String],
        andLinkerFlags linkerFlags: [String],
        andSwiftCompilerFlags swiftCompilerFlags: [String],
        andSwiftBuildFlags swiftBuildFlags: [String]
    ) -> (URL, URL)? {
        print("Compile: \(machine.name)")
        let buildDirPath = machine.filePath.appendingPathComponent(buildDir, isDirectory: true)
        guard let (buildPath, _) = self.assembler.assemble(machine, inDirectory: buildDirPath) else {
            self.errors = self.assembler.errors
            return nil
        }
        print("Compiling \(machine.name) with Package at path: \(buildPath.path)")
        let fm = FileManager.default
        let cwd = fm.currentDirectoryPath
        guard true == fm.changeCurrentDirectoryPath(buildPath.path) else {
            self.errors.append("Unable to change into directory \(buildPath.path)")
            return nil
        }
        print("Compiling at path: \(buildPath.path)")
        let args = self.makeCompilerFlags(
            forMachine: machine,
            withCCompilerFlags: cCompilerFlags,
            andCXXCompilerFlags: cxxCompilerFlags,
            andLinkerFlags: linkerFlags,
            andSwiftCompilerFlags: swiftCompilerFlags,
            andSwiftBuildFlags: swiftBuildFlags
        )
        print(args.reduce("env") { "\($0) \($1)" })
        guard true == self.invoker.run("/usr/bin/env", withArguments: args) else {
            let _ = fm.changeCurrentDirectoryPath(cwd)
            return nil
        }
        let _ = fm.changeCurrentDirectoryPath(cwd)
        let compileDir = buildPath.appendingPathComponent(".build", isDirectory: true).appendingPathComponent("release", isDirectory: true)
        return (compileDir, self.outputURL(forMachine: machine, builtInDirectory: buildDir))
    }

    private func makeCompilerFlags(
        forMachine machine: Machine,
        withCCompilerFlags cCompilerFlags: [String],
        andCXXCompilerFlags cxxCompilerFlags: [String],
        andLinkerFlags linkerFlags: [String],
        andSwiftCompilerFlags swiftCompilerFlags: [String],
        andSwiftBuildFlags swiftBuildFlags: [String]
    ) -> [String] {
        let swiftIncludeSearchPaths = machine.swiftIncludeSearchPaths.map { "-I\(self.expand($0, withMachine: machine))" }
        let includeSearchPaths = machine.includeSearchPaths.map { "-I\(self.expand($0, withMachine: machine))" }
        let libSearchPaths = machine.libSearchPaths.map { "-L\(self.expand($0, withMachine: machine))" }
        let mandatoryFlags = ["-Xlinker", "-lFSM"]
        var args: [String] = ["swift", "build"]
        args.append(contentsOf: swiftBuildFlags)
        args.append(contentsOf: swiftCompilerFlags.flatMap { ["-Xswiftc", $0] })
        args.append(contentsOf: swiftIncludeSearchPaths.flatMap { ["-Xswiftc", $0] })
        args.append(contentsOf: cCompilerFlags.flatMap { ["-Xcc", $0] })
        args.append(contentsOf: includeSearchPaths.flatMap { ["-Xcc", $0] })
        args.append(contentsOf: cxxCompilerFlags.flatMap { ["-Xcxx", $0] })
        args.append(contentsOf: includeSearchPaths.flatMap { ["-Xcxx", $0] })
        args.append(contentsOf: linkerFlags.flatMap { ["-Xlinker", $0] })
        args.append(contentsOf: libSearchPaths.flatMap { ["-Xlinker", $0] })
        args.append(contentsOf: mandatoryFlags)
        return args
    }

    private func expand(_ path: String, withMachine machine: Machine) -> String {
        guard let first = path.first else {
            return path
        }
        if (first == "/") {
            return path
        }
        return URL(fileURLWithPath: path, relativeTo: machine.filePath).path
    }
    
    fileprivate func copyCompiledDependentMachines(_ machine: Machine, buildDir: String, subdirs: [String], dependencies: [String]) -> Bool {
        let outPaths = dependencies.filter { false == self.processedMachines.contains($0) }
        if true == outPaths.isEmpty {
            return true
        }
        let dir = machine.filePath
            .appendingPathComponent(buildDir, isDirectory: true)
            .appendingPathComponent(machine.name + "Dependencies", isDirectory: true)
        let dependenciesDirectory = subdirs.reduce(dir) {
            $0.appendingPathComponent($1, isDirectory: true)
                .appendingPathComponent($1 + "Dependencies", isDirectory: true)
        }
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: dependenciesDirectory, withIntermediateDirectories: true)
        } catch let e {
            self.errors.append("\(e)")
            return false
        }
        return outPaths.reduce(true) {
            let src = URL(fileURLWithPath: $1, isDirectory: false)
            var components = String(src.lastPathComponent.dropFirst(3)).components(separatedBy: ".")
            if components.count >= 2 && components[components.count - 2].hasSuffix("Machine") {
                components[components.count - 2] = String(components[components.count - 2].dropLast(7))
            }
            let name = components.combine("") { $0 + "." + $1 } + "Dependencies"
            do {
                try fm.copyItem(at: src, to: dependenciesDirectory.appendingPathComponent(name, isDirectory: false))
            } catch let e {
                self.errors.append("\(e)")
                return $0 && false
            }
            self.processedMachines.insert($1)
            return $0 && true
        }
    }

}
