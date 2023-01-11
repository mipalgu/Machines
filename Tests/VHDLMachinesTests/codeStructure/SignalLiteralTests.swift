// SignalLiteralTests.swift
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

/// Test class for ``SignalLiteral``.
final class SignalLiteralTests: XCTestCase {

    /// Test raw values are correct.
    func testRawValue() {
        let bit = SignalLiteral.bit(value: .high)
        XCTAssertEqual(bit.rawValue, "'1'")
        let boolean = SignalLiteral.boolean(value: true)
        XCTAssertEqual(boolean.rawValue, "true")
        let boolean2 = SignalLiteral.boolean(value: false)
        XCTAssertEqual(boolean2.rawValue, "false")
        let int = SignalLiteral.integer(value: 12)
        XCTAssertEqual(int.rawValue, "12")
        let logic = SignalLiteral.logic(value: .high)
        XCTAssertEqual(logic.rawValue, "'1'")
        let vectorLiteral = SignalLiteral.vector(value: .logics(value: [.high, .low, .high]))
        XCTAssertEqual(vectorLiteral.rawValue, "\"101\"")
    }

    /// Test rawValue initaliser for a bit value.
    func testBitInit() {
        XCTAssertEqual(SignalLiteral(rawValue: "'1'"), .bit(value: .high))
        XCTAssertEqual(SignalLiteral(rawValue: "'0'"), .bit(value: .low))
    }

    /// Test rawValue initaliser for a boolean value.
    func testBoolInit() {
        XCTAssertEqual(SignalLiteral(rawValue: "true"), .boolean(value: true))
        XCTAssertEqual(SignalLiteral(rawValue: "false"), .boolean(value: false))
    }

    /// Test rawValue initaliser for an integer value.
    func testIntInit() {
        XCTAssertEqual(SignalLiteral(rawValue: "5"), .integer(value: 5))
        XCTAssertEqual(SignalLiteral(rawValue: "-5"), .integer(value: -5))
        XCTAssertEqual(SignalLiteral(rawValue: "0"), .integer(value: 0))
    }

    /// Test rawValue initaliser for a logic value.
    func testLogicInit() {
        XCTAssertEqual(SignalLiteral(rawValue: "'1'"), .bit(value: .high))
        XCTAssertEqual(SignalLiteral(rawValue: "'0'"), .bit(value: .low))
        XCTAssertEqual(SignalLiteral(rawValue: "'U'"), .logic(value: .uninitialized))
        XCTAssertEqual(SignalLiteral(rawValue: "'X'"), .logic(value: .unknown))
        XCTAssertEqual(SignalLiteral(rawValue: "'Z'"), .logic(value: .highImpedance))
        XCTAssertEqual(SignalLiteral(rawValue: "'W'"), .logic(value: .weakSignal))
        XCTAssertEqual(SignalLiteral(rawValue: "'L'"), .logic(value: .weakSignalLow))
        XCTAssertEqual(SignalLiteral(rawValue: "'H'"), .logic(value: .weakSignalHigh))
    }

    /// Test a long string returns nil.
    func testLongStringReturnsNil() {
        let raw = "\"" + String(repeating: "1", count: 256) + "\""
        XCTAssertNil(SignalLiteral(rawValue: raw))
    }

    /// Test unbalanced quotes returns nil.
    func testUnbalancedQuotesReturnsNil() {
        XCTAssertNil(SignalLiteral(rawValue: "\"1"))
        XCTAssertNil(SignalLiteral(rawValue: "1\""))
    }

    /// Test rawValue initaliser for a vector value.
    func testVectorInit() {
        XCTAssertEqual(
            SignalLiteral(rawValue: "\"101\""), .vector(value: .bits(value: [.high, .low, .high]))
        )
        XCTAssertEqual(
            SignalLiteral(rawValue: "\"1U1\""), .vector(value: .logics(value: [.high, .uninitialized, .high]))
        )
    }

    /// Test rawValue initialiser for a vector value with an invalid bit.
    func testVectorInitWithInvalidBit() {
        XCTAssertNil(SignalLiteral(rawValue: "\"1A1\""))
    }

    /// Test default property sets the correct value.
    func testDefaultVectors() {
        let expected = SignalLiteral.vector(value: .logics(value: [.low, .low, .low]))
        let range = VectorSize.downto(upper: 2, lower: 0)
        XCTAssertEqual(
            SignalLiteral.default(for: .ranged(type: .stdLogicVector(size: range))),
            expected
        )
        XCTAssertEqual(SignalLiteral.default(for: .ranged(type: .signed(size: range))), expected)
        XCTAssertEqual(SignalLiteral.default(for: .ranged(type: .unsigned(size: range))), expected)
        XCTAssertEqual(SignalLiteral.default(for: .ranged(type: .stdULogicVector(size: range))), expected)
    }

    /// Test default property sets the correct value for non-vector types.
    func testDefaultBitTypes() {
        XCTAssertEqual(SignalLiteral.default(for: .bit), .bit(value: .low))
        XCTAssertEqual(SignalLiteral.default(for: .stdLogic), .logic(value: .low))
        XCTAssertEqual(SignalLiteral.default(for: .boolean), .boolean(value: false))
        XCTAssertEqual(SignalLiteral.default(for: .integer), .integer(value: 0))
        XCTAssertEqual(
            SignalLiteral.default(for: .ranged(type: .integer(size: .to(lower: 5, upper: 7)))),
            .integer(value: 5)
        )
        XCTAssertEqual(
            SignalLiteral.default(for: .ranged(type: .integer(size: .to(lower: -2, upper: 7)))),
            .integer(value: 0)
        )
    }

    /// Test isValid function returns correct result for valid signal types.
    func testIsValid() {
        XCTAssertTrue(SignalLiteral.bit(value: .low).isValid(for: .stdLogic))
        XCTAssertTrue(SignalLiteral.bit(value: .low).isValid(for: .stdULogic))
        XCTAssertTrue(SignalLiteral.logic(value: .low).isValid(for: .bit))
        XCTAssertTrue(SignalLiteral.logic(value: .high).isValid(for: .bit))
        XCTAssertFalse(SignalLiteral.logic(value: .dontCare).isValid(for: .bit))
        XCTAssertFalse(SignalLiteral.boolean(value: false).isValid(for: .bit))
        XCTAssertFalse(SignalLiteral.integer(value: 12).isValid(for: .bit))
        XCTAssertFalse(SignalLiteral.vector(value: .logics(value: [.low])).isValid(for: .bit))
        XCTAssertTrue(SignalLiteral.logic(value: .low).isValid(for: .stdLogic))
        XCTAssertTrue(SignalLiteral.logic(value: .low).isValid(for: .stdULogic))
        XCTAssertFalse(SignalLiteral.integer(value: 12).isValid(for: .stdULogic))
        XCTAssertFalse(SignalLiteral.integer(value: 12).isValid(for: .stdLogic))
        XCTAssertTrue(SignalLiteral.boolean(value: true).isValid(for: .boolean))
        XCTAssertFalse(SignalLiteral.integer(value: 0).isValid(for: .boolean))
        XCTAssertFalse(SignalLiteral.logic(value: .high).isValid(for: .boolean))
        XCTAssertFalse(SignalLiteral.vector(value: .logics(value: [.high])).isValid(for: .boolean))
    }

    /// Test isValid function returns correct result for integer types.
    func testIsValidIntegers() {
        XCTAssertFalse(SignalLiteral.integer(value: -12).isValid(for: .natural))
        XCTAssertFalse(SignalLiteral.integer(value: -12).isValid(for: .positive))
        XCTAssertTrue(SignalLiteral.integer(value: 12).isValid(for: .natural))
        XCTAssertTrue(SignalLiteral.integer(value: 12).isValid(for: .positive))
        XCTAssertTrue(SignalLiteral.integer(value: 12).isValid(for: .integer))
        XCTAssertTrue(SignalLiteral.integer(value: 0).isValid(for: .natural))
        XCTAssertFalse(SignalLiteral.integer(value: 0).isValid(for: .positive))
        XCTAssertTrue(SignalLiteral.integer(value: 0).isValid(for: .integer))
        XCTAssertFalse(SignalLiteral.boolean(value: false).isValid(for: .positive))
        XCTAssertFalse(SignalLiteral.boolean(value: false).isValid(for: .natural))
        XCTAssertFalse(SignalLiteral.boolean(value: false).isValid(for: .integer))
        XCTAssertTrue(
            SignalLiteral.integer(value: 12)
                .isValid(for: .ranged(type: .integer(size: .to(lower: 0, upper: 12))))
        )
        XCTAssertFalse(
            SignalLiteral.integer(value: 12)
                .isValid(for: .ranged(type: .integer(size: .to(lower: 0, upper: 10))))
        )
        XCTAssertTrue(
            SignalLiteral.integer(value: 0)
                .isValid(for: .ranged(type: .integer(size: .to(lower: 0, upper: 12))))
        )
        XCTAssertFalse(
            SignalLiteral.integer(value: -6)
                .isValid(for: .ranged(type: .integer(size: .to(lower: -5, upper: 12))))
        )
        XCTAssertFalse(
            SignalLiteral.vector(value: .logics(value: [.low]))
                .isValid(for: .ranged(type: .integer(size: .downto(upper: 5, lower: 3))))
        )
    }

    /// Test isValid function returns correct result for vector types.
    func testIsValidVectors() {
        XCTAssertTrue(
            SignalLiteral.vector(
                value: .logics(value: [.low, .high, .low])
            )
            .isValid(for: .ranged(type: .stdLogicVector(size: .downto(upper: 2, lower: 0))))
        )
        XCTAssertTrue(
            SignalLiteral.vector(
                value: .logics(value: [.low, .high, .low])
            )
            .isValid(for: .ranged(type: .stdULogicVector(size: .downto(upper: 2, lower: 0))))
        )
        XCTAssertTrue(
            SignalLiteral.vector(
                value: .logics(value: [.low, .high, .low])
            )
            .isValid(for: .ranged(type: .signed(size: .downto(upper: 2, lower: 0))))
        )
        XCTAssertTrue(
            SignalLiteral.vector(
                value: .logics(value: [.low, .high, .low])
            )
            .isValid(for: .ranged(type: .unsigned(size: .downto(upper: 2, lower: 0))))
        )
        XCTAssertFalse(
            SignalLiteral.vector(
                value: .logics(value: [.low, .high])
            )
            .isValid(for: .ranged(type: .stdLogicVector(size: .downto(upper: 2, lower: 0))))
        )
        XCTAssertFalse(
            SignalLiteral.logic(value: .low).isValid(
                for: .ranged(type: .stdLogicVector(size: .downto(upper: 2, lower: 0)))
            )
        )
        XCTAssertFalse(SignalLiteral.vector(value: .logics(value: [.low, .high])).isValid(for: .stdLogic))
    }

}
