// RangedTypeTests.swift
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

/// Test class for ``RangedType``.
final class RangedTypeTests: XCTestCase {

    /// Test raw values are correct.
    func testRawValues() {
        let bitVector = RangedType.bitVector(size: .to(lower: 12, upper: 15))
        XCTAssertEqual(bitVector.rawValue, "bit_vector(12 to 15)")
        let integer = RangedType.integer(size: .to(lower: 12, upper: 15))
        XCTAssertEqual(integer.rawValue, "integer range 12 to 15")
        let signed = RangedType.signed(size: .downto(upper: 5, lower: 3))
        XCTAssertEqual(signed.rawValue, "signed(5 downto 3)")
        let vector = RangedType.stdLogicVector(size: .downto(upper: 5, lower: 3))
        XCTAssertEqual(vector.rawValue, "std_logic_vector(5 downto 3)")
        let stdULogicVector = RangedType.stdULogicVector(size: .downto(upper: 5, lower: 3))
        XCTAssertEqual(stdULogicVector.rawValue, "std_ulogic_vector(5 downto 3)")
        let unsigned = RangedType.unsigned(size: .to(lower: 12, upper: 15))
        XCTAssertEqual(unsigned.rawValue, "unsigned(12 to 15)")
    }

    /// Test that a long raw value returns nil.
    func testLongString() {
        XCTAssertNil(RangedType(rawValue: String(repeating: "a", count: 256)))
    }

    /// Test that a small string returns nil.
    func testSmallString() {
        XCTAssertNil(RangedType(rawValue: "std"))
        XCTAssertNil(RangedType(rawValue: ""))
        XCTAssertNil(RangedType(rawValue: String(repeating: "a", count: 15)))
    }

    /// Test that a valid `bitVector` raw value creates the correct case.
    func testBitVector() {
        XCTAssertEqual(
            RangedType(rawValue: "bit_vector(12 to 15)"), .bitVector(size: .to(lower: 12, upper: 15))
        )
    }

    /// Test that a valid `integer` raw value creates the correct case.
    func testInteger() {
        XCTAssertEqual(
            RangedType(rawValue: "integer range 12 to 15"), .integer(size: .to(lower: 12, upper: 15))
        )
    }

    /// Test upercased integer raw value creates the correct case.
    func testIntegerUppercased() {
        XCTAssertEqual(
            RangedType(rawValue: "INTEGER RANGE 12 TO 15"), .integer(size: .to(lower: 12, upper: 15))
        )
    }

    /// Test mispelled integer raw value returns nil.
    func testIntegerMispelled() {
        XCTAssertNil(RangedType(rawValue: "integar range 12 to 15"))
    }

    /// Test integer with extra brackets returns nil.
    func testIntegerAdditionlBracketReturnsNil() {
        XCTAssertNil(RangedType(rawValue: "integer range 12 to 15)"))
    }

    /// Test that a valid `signed` raw value creates the correct case.
    func testSigned() {
        XCTAssertEqual(
            RangedType(rawValue: "signed(5 downto 3)"),
            .signed(size: .downto(upper: 5, lower: 3))
        )
    }

    /// Test that a valid `stdULogicVector` raw value creates the correct case.
    func testStdULogicVector() {
        XCTAssertEqual(
            RangedType(rawValue: "std_ulogic_vector(5 downto 3)"),
            .stdULogicVector(size: .downto(upper: 5, lower: 3))
        )
    }

    /// Test that a valid `unsigned` raw value creates the correct case.
    func testUnsigned() {
        XCTAssertEqual(
            RangedType(rawValue: "unsigned(5 downto 3)"),
            .unsigned(size: .downto(upper: 5, lower: 3))
        )
    }

    /// Test that a valid `std_logic_vector` raw value creates the correct case.
    func testStdLogicVector() {
        XCTAssertEqual(
            RangedType(rawValue: "std_logic_vector(5 downto 3)"),
            .stdLogicVector(size: .downto(upper: 5, lower: 3))
        )
    }

    /// Test upercasd std_logic_vector raw value creates the correct case.
    func testStdLogicVectorUppercased() {
        XCTAssertEqual(
            RangedType(rawValue: "STD_LOGIC_VECTOR(5 DOWNTO 3)"),
            .stdLogicVector(size: .downto(upper: 5, lower: 3))
        )
    }

    /// Test mispelled std_logic_vector raw value returns nil.
    func testStdLogicVectorMispelled() {
        XCTAssertNil(RangedType(rawValue: "std_logic_vectro(5 downto 3)"))
    }

    /// Test std_logic_vector with extra brackets returns nil.
    func testStdLogicVectorAdditionlBracketReturnsNil() {
        XCTAssertNil(RangedType(rawValue: "std_logic_vector(5 downto 3))"))
    }

    /// Test incorrect size returns nil.
    func testIncorrectSize() {
        XCTAssertNil(RangedType(rawValue: "std_logic_vector(5 downtwo 3"))
    }

    /// Test size property.
    func testSize() {
        XCTAssertEqual(
            RangedType.bitVector(size: .to(lower: 12, upper: 15)).size,
            .to(lower: 12, upper: 15)
        )
        XCTAssertEqual(
            RangedType.integer(size: .to(lower: 12, upper: 15)).size,
            .to(lower: 12, upper: 15)
        )
        XCTAssertEqual(
            RangedType.signed(size: .downto(upper: 5, lower: 3)).size,
            .downto(upper: 5, lower: 3)
        )
        XCTAssertEqual(
            RangedType.stdLogicVector(size: .downto(upper: 5, lower: 3)).size,
            .downto(upper: 5, lower: 3)
        )
        XCTAssertEqual(
            RangedType.stdULogicVector(size: .downto(upper: 5, lower: 3)).size,
            .downto(upper: 5, lower: 3)
        )
        XCTAssertEqual(
            RangedType.unsigned(size: .to(lower: 12, upper: 15)).size,
            .to(lower: 12, upper: 15)
        )
    }

    /// Test description matches rawValue.
    func testDesciption() {
        let bitVector = RangedType.bitVector(size: .downto(upper: 5, lower: 3))
        XCTAssertEqual(bitVector.description, bitVector.rawValue)
        let integer = RangedType.integer(size: .to(lower: 0, upper: 512))
        XCTAssertEqual(integer.description, integer.rawValue)
        let signed = RangedType.signed(size: .downto(upper: 5, lower: 3))
        XCTAssertEqual(signed.description, signed.rawValue)
        let stdLogicVector = RangedType.stdLogicVector(size: .downto(upper: 5, lower: 3))
        XCTAssertEqual(stdLogicVector.description, stdLogicVector.rawValue)
        let stdULogicVector = RangedType.stdULogicVector(size: .downto(upper: 5, lower: 3))
        XCTAssertEqual(stdULogicVector.description, stdULogicVector.rawValue)
        let unsigned = RangedType.unsigned(size: .to(lower: 0, upper: 512))
        XCTAssertEqual(unsigned.description, unsigned.rawValue)
    }

}
