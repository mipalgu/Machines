///*
// * MachineParserTests.swift 
// * MachinesTests 
// *
// * Created by Callum McColl on 19/02/2017.
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
@testable import SwiftMachines
import XCTest
import MetaLanguage
import Foundation
#if os(Linux)
import IO
#endif
//
public class MachineParserTests: XCTestCase {
//
//    public static var allTests: [(String, (MachineParserTests) -> () throws -> Void)] {
//        return [
//            ("testParsesPingPongMachine", testParsesPingPongMachine),
//            ("testParsesControllerMachine", testParsesControllerMachine),
//            ("testParsesSumMachine", testParsesSumMachine),
//            ("testFailsToParseRecursiveMachine", testFailsToParseRecursiveMachine),
//            ("testParsesMicrowaveTimerMachine", testParsesMicrowaveTimerMachine)
//        ]
//    }

   public static var allTests: [(String, (MachineParserTests) -> () throws -> Void)] {
       return [
           ("testWrapperNotNil", testWrapperNotNil),
           ("testCanParseFromWrapper", testCanParseFromWrapper)
       ]
   }
   
   private let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(separator: "/").dropFirst()

   private var parser: MachineParser!

   private var defaultWrapper: FileWrapper!

   private var defaultMachine: Machine!

   public override func setUp() {
       super.setUp()
       self.parser = MachineParser()
       let initial = emptyState(named: "Initial")
       let suspend = emptyState(named: "Suspend")
       defaultMachine = Machine(
            name: "TestMachine",
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
            initialState: initial,
            suspendState: suspend,
            states: [initial, suspend],
            submachines: [],
            callableMachines: [],
            invocableMachines: [],
            tests: TestSuite(
                name: "TestMachineTests",
                tests: [.languageTest(name: "test_trueTest", code: "XCTAssertTrue(true)", language: .swift)]
            )
        )
        let generator = MachineGenerator()
        defaultWrapper = generator.generate(defaultMachine)
  }

  func testWrapperNotNil() {
        XCTAssertNotNil(defaultWrapper)
    }

  func testCanParseFromWrapper() {
      guard let newMachine = parser.parseMachine(defaultWrapper) else {
          XCTAssertTrue(false)
          return
      }
      XCTAssertEqual(newMachine, defaultMachine)
  }

  private func emptyState(named: String) -> State {
      State(
          name: named,
          imports: "",
          externalVariables: [],
          vars: [],
          actions: [
              Action(name: "OnEntry", implementation: ""),
              Action(name: "OnExit", implementation: ""),
              Action(name: "Main", implementation: "")
          ],
          transitions: []
      )
  }

//
//   public func testParsesPingPongMachine() {
//       let path = "\(packageRootPath)/machines/PingPong.machine"
//       guard let machine = self.parser.parseMachine(atPath: path) else {
//           XCTFail("Unable to parse machine at path: \(path) - \(self.parser.errors)")
//           return
//       }
//       XCTAssertEqual(machine, super.pingPongMachine)
//   }
//
//    public func testParsesControllerMachine() {
//        let path = "\(packageRootPath)/machines/Controller.machine"
//        guard let machine = self.parser.parseMachine(atPath: path) else {
//            XCTFail("Unable to parse machine at path: \(path) - \(self.parser.errors)")
//            return
//        }
//        XCTAssertEqual(machine, super.controllerMachine)
//        if (false == self.parser.errors.isEmpty) {
//            print(self.parser.errors)
//        }
//    }
//    
//    public func testParsesSumMachine() {
//        let path = "\(packageRootPath)/machines/Sum.machine"
//        guard let machine = self.parser.parseMachine(atPath: path) else {
//            XCTFail("Unable to parse machine at path: \(path) - \(self.parser.errors)")
//            return
//        }
//        XCTAssertEqual(machine, super.sumMachine)
//        if (false == self.parser.errors.isEmpty) {
//            print(self.parser.errors)
//        }
//    }
//    
//    public func testParsesMicrowaveTimerMachine() {
//        let path = "\(packageRootPath)/machines/microwave/Timer.machine"
//        guard let machine = self.parser.parseMachine(atPath: path) else {
//            XCTFail("Unable to parse machine at path: \(path) - \(self.parser.errors)")
//            return
//        }
//        if (false == self.parser.errors.isEmpty) {
//            print(self.parser.errors)
//        }
//    }
//
//   public func testFailsToParseRecursiveMachine() {
//       let path = "\(packageRootPath)/machines/Recursive.machine"
//       let machine = self.parser.parseMachine(atPath: path)
//       XCTAssertNil(machine)
//       XCTAssertFalse(self.parser.errors.isEmpty)
//   }
//

}
