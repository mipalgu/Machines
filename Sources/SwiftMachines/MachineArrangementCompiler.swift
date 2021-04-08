/*
 * MachineArrangementCompiler.swift
 * SwiftMachines
 *
 * Created by Callum McColl on 16/10/20.
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

import Foundation

import IO

@available(macOS 10.11, *)
public final class MachineArrangementCompiler {
    
    public private(set) var errors: [String] = []
    
    private let assembler: MachineArrangmentAssembler
    
    private let helpers: FileHelpers
    
    private let invoker: Invoker
    
    public init(assembler: MachineArrangmentAssembler = MachineArrangmentAssembler(), helpers: FileHelpers = FileHelpers(), invoker: Invoker = Invoker()) {
        self.assembler = assembler
        self.helpers = helpers
        self.invoker = invoker
    }
    
    public func outputPath(forArrangement arrangementDir: URL, executableName: String, swiftBuildConfig: SwiftBuildConfig, libExtension: String) -> String {
        return self.outputURL(forArrangement: arrangementDir, executableName: executableName, swiftBuildConfig: swiftBuildConfig, libExtension: libExtension).path
    }
    
    public func outputURL(forArrangement arrangementDir: URL, executableName: String, swiftBuildConfig: SwiftBuildConfig, libExtension: String) -> URL {
        let buildDirPath = arrangementDir
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent("Arrangement", isDirectory: true)
        return buildDirPath
            .appendingPathComponent(".build", isDirectory: true)
            .appendingPathComponent(swiftBuildConfig.rawValue, isDirectory: true)
            .appendingPathComponent("lib" + executableName + "." + libExtension, isDirectory: false)
    }
    
    public func compileArrangement(
        _ arrangement: Arrangement,
        machineBuildDir: String,
        libExtension: String,
        swiftBuildConfig: SwiftBuildConfig = .debug,
        withCCompilerFlags cCompilerFlags: [String] = [],
        andCXXCompilerFlags cxxCompilerFlags: [String] = [],
        andLinkerFlags linkerFlags: [String] = [],
        andSwiftCompilerFlags swiftCompilerFlags: [String] = [],
        andSwiftBuildFlags swiftBuildFlags: [String] = []
    ) -> URL? {
        self.errors = []
        guard let (buildPath, _) = self.assembler.assemble(arrangement, machineBuildDir: machineBuildDir) else {
            self.errors = self.assembler.errors
            return nil
        }
        print("Compiling arrangement.")
        let fm = FileManager.default
        let cwd = fm.currentDirectoryPath
        guard true == fm.changeCurrentDirectoryPath(buildPath.path) else {
            self.errors.append("Unable to change into directory \(buildPath.path)")
            return nil
        }
        print("Compiling at path: \(buildPath.path)")
        let arrangementArgs = self.makeCompilerFlags(
            forConfig: swiftBuildConfig,
            withCCompilerFlags: cCompilerFlags,
            andCXXCompilerFlags: cxxCompilerFlags,
            andLinkerFlags: linkerFlags,
            andSwiftCompilerFlags: swiftCompilerFlags,
            andSwiftBuildFlags: swiftBuildFlags
        )
        let machineArgs = arrangement.flattenedMachines.flatMap {
            self.makeCompilerFlags(forMachine: $0)
        }
        let args = arrangementArgs + machineArgs
        print(args.reduce("swift build") { "\($0) \($1)" })
        guard true == self.invoker.run("/usr/bin/swift", withArguments: ["build"] + args) else {
            let _ = fm.changeCurrentDirectoryPath(cwd)
            return nil
        }
        let _ = fm.changeCurrentDirectoryPath(cwd)
        let buildDir = arrangement.filePath.appendingPathComponent(".build", isDirectory: true)
        let compileDir = buildDir.appendingPathComponent(swiftBuildConfig.rawValue, isDirectory: true)
        if nil == self.helpers.overwriteDirectory(compileDir) {
            self.errors.append("Unable to create build directory: \(compileDir.path)")
            return nil
        }
        let outputURL = self.outputURL(forArrangement: arrangement.filePath, executableName: arrangement.name, swiftBuildConfig: swiftBuildConfig, libExtension: libExtension)
        print(outputURL.path)
        do {
            _ = try self.copyOutPath(outputURL, toFolder: compileDir, executableName: arrangement.name)
        } catch let e {
            self.errors.append("\(e)")
            print(e)
            return nil
        }
        return outputURL
    }
    
    private func makeCompilerFlags(forMachine machine: Machine) -> [String] {
        let swiftIncludeSearchPaths = machine.swiftIncludeSearchPaths.map { "-I\(self.expand($0, withMachine: machine))" }
        let includeSearchPaths = machine.includeSearchPaths.map { "-I\(self.expand($0, withMachine: machine))" }
        let libSearchPaths = machine.libSearchPaths.map { "-L\(self.expand($0, withMachine: machine))" }
        var args: [String] = []
        args.append(contentsOf: swiftIncludeSearchPaths.flatMap { ["-Xswiftc", $0] })
        args.append(contentsOf: includeSearchPaths.flatMap { ["-Xcc", $0] })
        args.append(contentsOf: includeSearchPaths.flatMap { ["-Xcxx", $0] })
        args.append(contentsOf: libSearchPaths.flatMap { ["-Xlinker", $0] })
        return args
    }
    
    private func makeCompilerFlags(
        forConfig swiftBuildConfig: SwiftBuildConfig,
        withCCompilerFlags cCompilerFlags: [String],
        andCXXCompilerFlags cxxCompilerFlags: [String],
        andLinkerFlags linkerFlags: [String],
        andSwiftCompilerFlags swiftCompilerFlags: [String],
        andSwiftBuildFlags swiftBuildFlags: [String]
    ) -> [String] {
        var args: [String] = []
        args.append(contentsOf: ["-c", swiftBuildConfig.rawValue])
        args.append(contentsOf: swiftBuildFlags)
        args.append(contentsOf: swiftCompilerFlags.flatMap { ["-Xswiftc", $0] })
        args.append(contentsOf: cCompilerFlags.flatMap { ["-Xcc", $0] })
        args.append(contentsOf: cxxCompilerFlags.flatMap { ["-Xcxx", $0] })
        args.append(contentsOf: linkerFlags.flatMap { ["-Xlinker", $0] })
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
    
    fileprivate func copyOutPath(_ outPath: URL, toFolder dir: URL, executableName name: String) throws -> Bool {
        let fm = FileManager.default
        try fm.copyItem(at: outPath, to: dir.appendingPathComponent(name, isDirectory: false))
        return true
    }
    
}
