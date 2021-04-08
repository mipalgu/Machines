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
    
    private var compiledMachines: [String: String] = [:]

    public init(assembler: A, invoker: Invoker = Invoker()) {
        self.assembler = assembler
        self.invoker = invoker
    }

    public func shouldCompile(_ machine: Machine, inDirectory buildDir: String, libExtension: String) -> Bool {
        return true
    }

    public func compile(
        _ machine: Machine,
        withBuildDir buildDir: String,
        libExtension: String,
        swiftBuildConfig: SwiftBuildConfig = .debug,
        withCCompilerFlags cCompilerFlags: [String] = [],
        andCXXCompilerFlags cxxCompilerFlags: [String] = [],
        andLinkerFlags linkerFlags: [String] = [],
        andSwiftCompilerFlags swiftCompilerFlags: [String] = [],
        andSwiftBuildFlags swiftBuildFlags: [String] = []
    ) -> Bool {
        self.errors = []
        return self.compileMachine(
            machine,
            withBuildDir: buildDir,
            libExtension: libExtension,
            swiftBuildConfig: swiftBuildConfig,
            withCCompilerFlags: cCompilerFlags,
            andCXXCompilerFlags: cxxCompilerFlags,
            andLinkerFlags: linkerFlags,
            andSwiftCompilerFlags: swiftCompilerFlags,
            andSwiftBuildFlags: swiftBuildFlags
        )
    }

    private func compileMachine(
        _ machine: Machine,
        withBuildDir buildDir: String,
        libExtension: String,
        swiftBuildConfig: SwiftBuildConfig = .debug,
        withCCompilerFlags cCompilerFlags: [String],
        andCXXCompilerFlags cxxCompilerFlags: [String],
        andLinkerFlags linkerFlags: [String],
        andSwiftCompilerFlags swiftCompilerFlags: [String],
        andSwiftBuildFlags swiftBuildFlags: [String]
    ) -> Bool {
        print("Compile: \(machine.name)")
        let buildDirPath = machine.filePath.appendingPathComponent(buildDir, isDirectory: true)
        guard let (buildPath, _) = self.assembler.assemble(machine, inDirectory: buildDirPath) else {
            self.errors = self.assembler.errors
            return false
        }
        print("Compiling \(machine.name) with Package at path: \(buildPath.path)")
        let fm = FileManager.default
        let cwd = fm.currentDirectoryPath
        guard true == fm.changeCurrentDirectoryPath(buildPath.path) else {
            self.errors.append("Unable to change into directory \(buildPath.path)")
            return false
        }
        print("Compiling at path: \(buildPath.path)")
        let args = self.makeCompilerFlags(
            forMachine: machine,
            swiftBuildConfig: swiftBuildConfig,
            withCCompilerFlags: cCompilerFlags,
            andCXXCompilerFlags: cxxCompilerFlags,
            andLinkerFlags: linkerFlags,
            andSwiftCompilerFlags: swiftCompilerFlags,
            andSwiftBuildFlags: swiftBuildFlags
        )
        print(args.reduce("env") { "\($0) \($1)" })
        defer { _ = fm.changeCurrentDirectoryPath(cwd) }
        guard true == self.invoker.run("/usr/bin/env", withArguments: args) else {
            return false
        }
        return true
    }

    private func makeCompilerFlags(
        forMachine machine: Machine,
        swiftBuildConfig: SwiftBuildConfig,
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
        args.append(contentsOf: ["-c", swiftBuildConfig.rawValue])
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

}
