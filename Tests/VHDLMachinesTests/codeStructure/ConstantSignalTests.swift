// ConstantSignalTests.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

@testable import VHDLMachines
import XCTest

/// Test class for ``ConstantSignal``.
final class ConstantSignalTests: XCTestCase {

    /// The signal under test.
    var signal = ConstantSignal(
        name: VariableName(text: "x"),
        type: .stdLogic,
        value: .literal(value: .logic(value: .high)),
        comment: Comment(text: "signal x.")
    )

    /// Initialise the signal under test before every test case.
    override func setUp() {
        self.signal = ConstantSignal(
            name: VariableName(text: "x"),
            type: .stdLogic,
            value: .literal(value: .logic(value: .high)),
            comment: Comment(text: "signal x.")
        )
    }

    /// Test init sets properties correctly.
    func testInit() {
        guard
            let xComment = Comment(rawValue: "-- signal x."), let yComment = Comment(rawValue: "-- signal y.")
        else {
            XCTFail("Could not create comments.")
            return
        }
        XCTAssertEqual(signal?.name, VariableName(text: "x"))
        XCTAssertEqual(signal?.type, .stdLogic)
        XCTAssertEqual(signal?.value, .literal(value: .logic(value: .high)))
        XCTAssertEqual(signal?.comment, xComment)
        let newSignal = ConstantSignal(
            name: VariableName(text: "y"),
            type: .stdLogic,
            value: .literal(value: .integer(value: 5)),
            comment: yComment
        )
        XCTAssertNil(newSignal)
    }

    /// Test the rawValue is created correctly.
    func testRawValue() {
        XCTAssertEqual(signal?.rawValue, "constant x: std_logic := '1'; -- signal x.")
        signal = ConstantSignal(
            name: VariableName(text: "x"),
            type: .stdLogic,
            value: .literal(value: .logic(value: .high)),
            comment: nil
        )
        XCTAssertEqual(signal?.rawValue, "constant x: std_logic := '1';")
    }

    // swiftlint:disable function_body_length

    /// Test that the action bit representations are correct.
    func testActionConstants() {
        let actions: [ActionName: String] = [
            "OnEntry": "",
            "OnExit": "",
            "Internal": "",
            "OnResume": "",
            "OnSuspend": ""
        ]
        let constants = [
            ConstantSignal(
                name: VariableName(text: "CheckTransition"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .low, .low, .low])))
            ),
            ConstantSignal(
                name: VariableName(text: "Internal"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .low, .low, .high])))
            ),
            ConstantSignal(
                name: VariableName(text: "NoOnEntry"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .low, .high, .low])))
            ),
            ConstantSignal(
                name: VariableName(text: "OnEntry"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .low, .high, .high])))
            ),
            ConstantSignal(
                name: VariableName(text: "OnExit"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .high, .low, .low])))
            ),
            ConstantSignal(
                name: VariableName(text: "OnResume"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .high, .low, .high])))
            ),
            ConstantSignal(
                name: VariableName(text: "OnSuspend"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .high, .high, .low])))
            ),
            ConstantSignal(
                name: VariableName(text: "ReadSnapshot"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.low, .high, .high, .high])))
            ),
            ConstantSignal(
                name: VariableName(text: "WriteSnapshot"),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(value: [.high, .low, .low, .low])))
            )
        ].compactMap { $0 }
        guard constants.count == 9 else {
            XCTFail("Incorrect number of constants")
            return
        }
        XCTAssertEqual(ConstantSignal.constants(for: actions), constants)
    }

    // swiftlint:enable function_body_length

    /// Test raw value init creates signal correctly.
    func testRawValueInit() {
        guard let comment = Comment(rawValue: "-- signal x.") else {
            XCTFail("Failed to create comment")
            return
        }
        let result = ConstantSignal(rawValue: "constant x: std_logic := '1'; -- signal x.")
        let expected = ConstantSignal(
            name: VariableName(text: "x"),
            type: .stdLogic,
            value: .literal(value: .logic(value: .high)),
            comment: comment
        )
        XCTAssertNotNil(expected)
        XCTAssertEqual(result, expected)
        let result1 = ConstantSignal(rawValue: "constant x : std_logic := '1'; -- signal x.")
        let expected1 = ConstantSignal(
            name: VariableName(text: "x"),
            type: .stdLogic,
            value: .literal(value: .logic(value: .high)),
            comment: comment
        )
        XCTAssertNotNil(expected1)
        XCTAssertEqual(result1, expected1)
        let result2 = ConstantSignal(
            rawValue: "constant x : std_logic_vector(3 downto 0) := \"0101\"; -- signal x."
        )
        let expected2 = ConstantSignal(
            name: VariableName(text: "x"),
            type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
            value: .literal(value: .vector(value: .bits(value: [.low, .high, .low, .high]))),
            comment: comment
        )
        XCTAssertNotNil(expected2)
        XCTAssertEqual(result2, expected2)
        let result3 = ConstantSignal(
            rawValue: "constant x : std_logic_vector(3 downto 0) := \"0101\";"
        )
        let expected3 = ConstantSignal(
            name: VariableName(text: "x"),
            type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
            value: .literal(value: .vector(value: .bits(value: [.low, .high, .low, .high]))),
            comment: nil
        )
        XCTAssertNotNil(expected3)
        XCTAssertEqual(result3, expected3)
    }

}
