// SignalTypeTests.swift
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

/// Test class for ``SignalType``.
final class SignalTypeTests: XCTestCase {

    /// Test raw values are correct.
    func testRawValues() {
        let bit = SignalType.bit
        XCTAssertEqual(bit.rawValue, "bit")
        let bool = SignalType.boolean
        XCTAssertEqual(bool.rawValue, "boolean")
        let int = SignalType.integer
        XCTAssertEqual(int.rawValue, "integer")
        let natural = SignalType.natural
        XCTAssertEqual(natural.rawValue, "natural")
        let positive = SignalType.positive
        XCTAssertEqual(positive.rawValue, "positive")
        let real = SignalType.real
        XCTAssertEqual(real.rawValue, "real")
        let std = SignalType.stdLogic
        XCTAssertEqual(std.rawValue, "std_logic")
        let stdU = SignalType.stdULogic
        XCTAssertEqual(stdU.rawValue, "std_ulogic")
        let vector = SignalType.ranged(type: .stdLogicVector(size: .downto(upper: 5, lower: 3)))
        XCTAssertEqual(vector.rawValue, "std_logic_vector(5 downto 3)")
    }

    /// Test that a raw value of `std_logic` creates the correct case.
    func testStdLogic() {
        XCTAssertEqual(SignalType(rawValue: "std_logic"), .stdLogic)
    }

    /// Test that an uppercased `std_logic` raw value creates the correct case.
    func testStdLogicUppercased() {
        XCTAssertEqual(SignalType(rawValue: "STD_LOGIC"), .stdLogic)
    }

    /// Test that a small string returns nil.
    func testSmallString() {
        XCTAssertNil(SignalType(rawValue: "std"))
        XCTAssertNil(SignalType(rawValue: ""))
        XCTAssertNil(SignalType(rawValue: String(repeating: "a", count: 15)))
    }

    /// Test that a valid `std_logic_vector` raw value creates the correct case.
    func testStdLogicVector() {
        XCTAssertEqual(
            SignalType(rawValue: "std_logic_vector(5 downto 3)"),
            .ranged(type: .stdLogicVector(size: .downto(upper: 5, lower: 3)))
        )
    }

    /// Test upercasd std_logic_vector raw value creates the correct case.
    func testStdLogicVectorUppercased() {
        XCTAssertEqual(
            SignalType(rawValue: "STD_LOGIC_VECTOR(5 DOWNTO 3)"),
            .ranged(type: .stdLogicVector(size: .downto(upper: 5, lower: 3)))
        )
    }

    /// Test mispelled std_logic_vector raw value returns nil.
    func testStdLogicVectorMispelled() {
        XCTAssertNil(SignalType(rawValue: "std_logic_vectro(5 downto 3)"))
    }

    /// Test std_logic_vector with extra brackets returns nil.
    func testStdLogicVectorAdditionlBracketReturnsNil() {
        XCTAssertNil(SignalType(rawValue: "std_logic_vector(5 downto 3))"))
    }

    /// Test incorrect size returns nil.
    func testIncorrectSize() {
        XCTAssertNil(SignalType(rawValue: "std_logic_vector(5 downtwo 3"))
    }

    /// Test that a valid raw value creates the correct case.
    func testSimpleTypeRawInits() {
        XCTAssertEqual(SignalType(rawValue: "bit"), .bit)
        XCTAssertEqual(SignalType(rawValue: "boolean"), .boolean)
        XCTAssertEqual(SignalType(rawValue: "integer"), .integer)
        XCTAssertEqual(SignalType(rawValue: "natural"), .natural)
        XCTAssertEqual(SignalType(rawValue: "positive"), .positive)
        XCTAssertEqual(SignalType(rawValue: "std_ulogic"), .stdULogic)
        XCTAssertEqual(SignalType(rawValue: "real"), .real)
    }

    /// Test a long string returns nil.
    func testLongString() {
        XCTAssertNil(SignalType(rawValue: String(repeating: "a", count: 256)))
    }

}
