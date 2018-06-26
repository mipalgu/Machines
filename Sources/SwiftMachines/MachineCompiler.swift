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

import Machines
import Foundation

@available(macOS 11, *)
public class MachineCompiler<A: Assembler> {

    private let assembler: A

    private let invoker: Invoker

    public init(assembler: A, invoker: Invoker = Invoker()) {
        self.assembler = assembler
        self.invoker = invoker
    }

    public func compile(
        _ machine: Machine,
        withCompilerFlags compilerFlags: [String] = [],
        andLinkerFlags linkerFlags: [String] = []
    ) -> String? {
        guard
            let (_, outputPath) = self.compileMachine(
                    machine,
                    withCompilerFlags: compilerFlags,
                    andLinkerFlags: linkerFlags
                )
        else {
            return nil
        }
        return outputPath.path
    }

    private func compileMachine(
        _ machine: Machine,
        withCompilerFlags compilerFlags: [String],
        andLinkerFlags linkerFlags: [String]
    ) -> (URL, URL)? {
        print("Compile: \(machine.name)")
        guard let (buildPath, _) = self.assembler.assemble(machine) else {
            return nil
        }
        print("Compiling \(machine.name) with Package at path: \(buildPath.path)")
        let fm = FileManager.default
        let cwd = fm.currentDirectoryPath
        guard true == fm.changeCurrentDirectoryPath(buildPath.path) else {
            return nil
        }
        print("Compiling at path: \(buildPath.path)")
        let args = self.makeCompilerFlags(
            forMachine: machine,
            withPassedInCompilerFlags: compilerFlags,
            andPassedInLinkerFlags: linkerFlags
        )
        print(args.reduce("env") { "\($0) \($1)" })
        guard true == self.invoker.run("/usr/bin/env", withArguments: args) else {
            let _ = fm.changeCurrentDirectoryPath(cwd)
            return nil
        }
        let _ = fm.changeCurrentDirectoryPath(cwd)
        #if os(OSX)
        let ext = "dylib"
        #else
        let ext = "so"
        #endif
        let compileDir = buildPath.appendingPathComponent(".build", isDirectory: true).appendingPathComponent("release", isDirectory: true)
        let outputPath = compileDir.appendingPathComponent("lib\(machine.name)Machine.\(ext)", isDirectory: false)
        return (compileDir, outputPath)
    }

    private func makeCompilerFlags(
        forMachine machine: Machine,
        withPassedInCompilerFlags passedInCompilerFlags: [String],
        andPassedInLinkerFlags passedInLinkerFlags: [String]
    ) -> [String] {
        let swiftIncludeSearchPaths = machine.swiftIncludeSearchPaths.map { "-I\(self.expand($0, withMachine: machine))" }
        let includeSearchPaths = machine.includeSearchPaths.map { "-I\(self.expand($0, withMachine: machine))" }
        let libSearchPaths = machine.libSearchPaths.map { "-L\(self.expand($0, withMachine: machine))" }
        let mandatoryFlags = ["swift", "build", "-c", "release", "-Xlinker", "-lFSM"]
        var args: [String] = []
        args.reserveCapacity(mandatoryFlags.count + swiftIncludeSearchPaths.count * 2 + includeSearchPaths.count * 2 + libSearchPaths.count * 2 + passedInCompilerFlags.count * 2 + passedInLinkerFlags.count * 2)
        args.append(contentsOf: mandatoryFlags)
        args.append(contentsOf: swiftIncludeSearchPaths.flatMap { ["-Xswiftc", $0] })
        args.append(contentsOf: includeSearchPaths.flatMap { ["-Xcc", $0] })
        args.append(contentsOf: libSearchPaths.flatMap { ["-Xlinker", $0] })
        args.append(contentsOf: passedInCompilerFlags.flatMap { ["-Xswiftc", $0] })
        args.append(contentsOf: passedInLinkerFlags.flatMap { ["-Xlinker", $0] })
        return args
    }

    private func expand(_ path: String, withMachine machine: Machine) -> String {
        guard let first = path.characters.first else {
            return path
        }
        if (first == "/") {
            return path
        }
        return URL(fileURLWithPath: path, relativeTo: machine.filePath).path
    }

}