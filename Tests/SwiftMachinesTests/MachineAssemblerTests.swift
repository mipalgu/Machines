///*
// * MachineAssemblerTests.swift 
// * MachinesTests 
// *
// * Created by Callum McColl on 20/02/2017.
// * Copyright © 2017 Callum McColl. All rights reserved.
// *
// * Redistribution and use in source and binary forms, with or without
// * modification, are permitted provided that the following conditions
// * are met:
// *
// * 1. Redistributions of source code must retain the above copyright
// *    notice, this list of conditions and the following disclaimer.
// *
// * 2. Redistributions in binary form must reproduce the above
// *    copyright notice, this list of conditions and the following
// *    disclaimer in the documentation and/or other materials
// *    provided with the distribution.
// *
// * 3. All advertising materials mentioning features or use of this
// *    software must display the following acknowledgement:
// *
// *        This product includes software developed by Callum McColl.
// *
// * 4. Neither the name of the author nor the names of contributors
// *    may be used to endorse or promote products derived from this
// *    software without specific prior written permission.
// *
// * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// *
// * -----------------------------------------------------------------------
// * This program is free software; you can redistribute it and/or
// * modify it under the above terms or under the terms of the GNU
// * General Public License as published by the Free Software Foundation;
// * either version 2 of the License, or (at your option) any later version.
// *
// * This program is distributed in the hope that it will be useful,
// * but WITHOUT ANY WARRANTY; without even the implied warranty of
// * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// * GNU General Public License for more details.
// *
// * You should have received a copy of the GNU General Public License
// * along with this program; if not, see http://www.gnu.org/licenses/
// * or write to the Free Software Foundation, Inc., 51 Franklin Street,
// * Fifth Floor, Boston, MA  02110-1301, USA.
// *
// */
//
import Foundation
@testable import SwiftMachines
import XCTest
import MetaLanguage

public final class MachineAssemblerTests: XCTestCase {

    public static var allTests: [(String, (MachineAssemblerTests) -> () throws -> Void)] {
        return [
            ("test_canAssemblePingPong", test_canAssemblePingPong)
        ]
    }
    
    private var assembler: MachineAssembler!
    
    public override func setUp() {
        super.setUp()
        self.assembler = MachineAssembler()
    }
    
    public func test_canAssemblePingPong() {
        let pingState = State(
            name: "Ping",
            imports: "",
            externalVariables: [],
            vars: [],
            actions: [
                Action(name: "onEntry", implementation: "print(\"Ping\")"),
                Action(name: "onExit", implementation: ""),
                Action(name: "main", implementation: "")
            ],
            transitions: [
                Transition(target: "Pong", condition: nil)
            ]
        )
        let pingPong = Machine(
            name: "PingPong",
            externalVariables: [],
            packageDependencies: [],
            swiftIncludeSearchPaths: [],
            includeSearchPaths: [],
            libSearchPaths: [],
            imports: "",
            includes: nil,
            vars: [],
            model: nil,
            parameters: nil,
            returnType: nil,
            initialState: pingState,
            suspendState: nil,
            states: [
                pingState,
                State(
                    name: "Pong",
                    imports: "",
                    externalVariables: [],
                    vars: [],
                    actions: [
                        Action(name: "onEntry", implementation: "print(\"Pong\")"),
                        Action(name: "onExit", implementation: ""),
                        Action(name: "main", implementation: "")
                    ],
                    transitions: [
                        Transition(target: "Ping", condition: nil)
                    ]
                )
            ],
            submachines: [],
            callableMachines: [],
            invocableMachines: [],
            tests: TestSuite(
                name: "PingPongTests",
                tests: [Test(rawValue: "@swift test testTrue {\n    XCTAssertTrue(true)\n}")!],
                variables: nil,
                setup: nil,
                tearDown: nil
            )
        )
        guard let wrapper = assembler.assemble(
            pingPong,
            atDirectory: URL(fileURLWithPath: "/tmp/PingPong.machine", isDirectory: true),
            inDirectory: URL(fileURLWithPath: "/tmp/PingPong.machine/.build", isDirectory: true)
        ) else {
            for error in assembler.errors {
                XCTFail(error)
            }
            XCTFail("Unable to assemble ping pong.")
            return
        }
        XCTAssertNotNil(wrapper)
    }
    
}

//
//public class MachineAssemblerTests: MachinesTestCase {
//
//    public static var allTests: [(String, (MachineAssemblerTests) -> () throws -> Void)] {
//        return [
//            ("testBuildsPingPong", testBuildsPingPong),
//            ("testBuildsController", testBuildsController)
//        ]
//    }
//
//    private var assembler: MachineAssembler!
//
//    lazy var machineTestsDir: URL = {
//        let fm = FileManager.default
//        let cwd = URL(fileURLWithPath: fm.currentDirectoryPath)
//        let testsPath = cwd.appendingPathComponent("machines", isDirectory: true)
//        return testsPath
//    }()
//
//    public override func setUp() {
//        super.setUp()
//        self.assembler = MachineAssembler()
//    }
//
//    public func testBuildsPingPong() {
//        let buildDir = super.pingPongMachine.filePath.appendingPathComponent(".build", isDirectory: true)
//        guard let (_, paths) = self.assembler.assemble(super.pingPongMachine, inDirectory: buildDir) else {
//            XCTFail("Cannot assemble PingPong.machine: \(self.assembler.lastError ?? "")")
//            return
//        }
//        self.compareFiles(atPaths: paths, withFilesAtPaths: super.pingPongFiles)
//    }
//
//    public func testBuildsController() {
//        let buildDir = super.controllerMachine.filePath.appendingPathComponent(".build", isDirectory: true)
//        guard let (_, paths) = self.assembler.assemble(super.controllerMachine, inDirectory: buildDir) else {
//            XCTFail("Cannot assemble Controller.machine: \(self.assembler.lastError ?? "")")
//            return
//        }
//        self.compareFiles(atPaths: paths, withFilesAtPaths: super.controllerFiles)
//    }
//
//    private func compareFiles(atPaths paths: [URL], withFilesAtPaths paths2: [URL]) {
//        let pathsNames = paths.map { $0.lastPathComponent }.sorted()
//        let paths2Names = paths2.map { $0.lastPathComponent }.sorted()
//        XCTAssertEqual(pathsNames, paths2Names)
//        if (pathsNames != paths2Names) {
//            return
//        }
//        let sortedPaths = paths.sorted() {
//            $0.lastPathComponent < $1.lastPathComponent
//        }
//        let sortedPaths2 = paths2.sorted() {
//            $0.lastPathComponent < $1.lastPathComponent
//        }
//        let fm = FileManager.default
//        for i in 0..<sortedPaths.count {
//            let p1 = sortedPaths[i].path
//            let p2 = sortedPaths2[i].path
//            let d1 = fm.contents(atPath: p1)
//            let d2 = fm.contents(atPath: p2)
//            if d1 == nil && d2 == nil {
//                continue
//            }
//            guard let c1 = d1, let c2 = d2 else {
//                if d1 == nil {
//                    XCTFail("\(p1) does not exist")
//                    continue
//                }
//                XCTFail("\(p2) does not exist")
//                continue
//            }
//            guard
//                let s1 = String(data: c1, encoding: .utf8).map({ $0.trimmingCharacters(in: .whitespaces) }),
//                let s2 = String(data: c2, encoding: .utf8).map({ $0.trimmingCharacters(in: .whitespaces) })
//            else {
//                XCTFail("Unable to encode files")
//                continue
//            }
//            let replacedS1 = s1.replacingOccurrences(of: "%machines_tests%/", with: self.machineTestsDir.absoluteString).replacingOccurrences(of: "file://", with: "")
//            let replacedS2 = s2.replacingOccurrences(of: "%machines_tests%/", with: self.machineTestsDir.absoluteString).replacingOccurrences(of: "file://", with: "")
//            if (replacedS1 != replacedS2) {
//                print(replacedS1)
//                print(replacedS2)
//                XCTFail("\(p1) != \(p2)")
//            }
//        }
//    }
//
//}
