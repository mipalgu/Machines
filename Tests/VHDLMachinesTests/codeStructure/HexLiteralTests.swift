// HexLiteralTests.swift
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

/// Test class for ``HexLiteral``.
final class HexLiteralTests: XCTestCase {

    /// Test that the raw values are correct.
    func testRawValues() {
        XCTAssertEqual(HexLiteral.zero.rawValue, "0")
        XCTAssertEqual(HexLiteral.one.rawValue, "1")
        XCTAssertEqual(HexLiteral.two.rawValue, "2")
        XCTAssertEqual(HexLiteral.three.rawValue, "3")
        XCTAssertEqual(HexLiteral.four.rawValue, "4")
        XCTAssertEqual(HexLiteral.five.rawValue, "5")
        XCTAssertEqual(HexLiteral.six.rawValue, "6")
        XCTAssertEqual(HexLiteral.seven.rawValue, "7")
        XCTAssertEqual(HexLiteral.eight.rawValue, "8")
        XCTAssertEqual(HexLiteral.nine.rawValue, "9")
        XCTAssertEqual(HexLiteral.ten.rawValue, "A")
        XCTAssertEqual(HexLiteral.eleven.rawValue, "B")
        XCTAssertEqual(HexLiteral.twelve.rawValue, "C")
        XCTAssertEqual(HexLiteral.thirteen.rawValue, "D")
        XCTAssertEqual(HexLiteral.fourteen.rawValue, "E")
        XCTAssertEqual(HexLiteral.fifteen.rawValue, "F")
    }

    /// Test valid raw values create the correct case.
    func testRawValueInit() {
        XCTAssertEqual(HexLiteral(rawValue: "0"), .zero)
        XCTAssertEqual(HexLiteral(rawValue: "1"), .one)
        XCTAssertEqual(HexLiteral(rawValue: "2"), .two)
        XCTAssertEqual(HexLiteral(rawValue: "3"), .three)
        XCTAssertEqual(HexLiteral(rawValue: "4"), .four)
        XCTAssertEqual(HexLiteral(rawValue: "5"), .five)
        XCTAssertEqual(HexLiteral(rawValue: "6"), .six)
        XCTAssertEqual(HexLiteral(rawValue: "7"), .seven)
        XCTAssertEqual(HexLiteral(rawValue: "8"), .eight)
        XCTAssertEqual(HexLiteral(rawValue: "9"), .nine)
        XCTAssertEqual(HexLiteral(rawValue: "A"), .ten)
        XCTAssertEqual(HexLiteral(rawValue: "B"), .eleven)
        XCTAssertEqual(HexLiteral(rawValue: "C"), .twelve)
        XCTAssertEqual(HexLiteral(rawValue: "D"), .thirteen)
        XCTAssertEqual(HexLiteral(rawValue: "E"), .fourteen)
        XCTAssertEqual(HexLiteral(rawValue: "F"), .fifteen)
        XCTAssertEqual(HexLiteral(rawValue: "a"), .ten)
        XCTAssertEqual(HexLiteral(rawValue: "b"), .eleven)
        XCTAssertEqual(HexLiteral(rawValue: "c"), .twelve)
        XCTAssertEqual(HexLiteral(rawValue: "d"), .thirteen)
        XCTAssertEqual(HexLiteral(rawValue: "e"), .fourteen)
        XCTAssertEqual(HexLiteral(rawValue: "f"), .fifteen)
    }

    /// Test incorrect raw values return nil.
    func testInvalidRawValueInit() {
        XCTAssertNil(HexLiteral(rawValue: "G"))
        XCTAssertNil(HexLiteral(rawValue: "S"))
        XCTAssertNil(HexLiteral(rawValue: "H"))
        XCTAssertNil(HexLiteral(rawValue: "-"))
        XCTAssertNil(HexLiteral(rawValue: "J"))
        XCTAssertNil(HexLiteral(rawValue: " "))
    }

    /// Test bits computed property creates correct bit vector.
    func testBits() {
        XCTAssertEqual(HexLiteral.zero.bits, [.low, .low, .low, .low])
        XCTAssertEqual(HexLiteral.one.bits, [.low, .low, .low, .high])
        XCTAssertEqual(HexLiteral.two.bits, [.low, .low, .high, .low])
        XCTAssertEqual(HexLiteral.three.bits, [.low, .low, .high, .high])
        XCTAssertEqual(HexLiteral.four.bits, [.low, .high, .low, .low])
        XCTAssertEqual(HexLiteral.five.bits, [.low, .high, .low, .high])
        XCTAssertEqual(HexLiteral.six.bits, [.low, .high, .high, .low])
        XCTAssertEqual(HexLiteral.seven.bits, [.low, .high, .high, .high])
        XCTAssertEqual(HexLiteral.eight.bits, [.high, .low, .low, .low])
        XCTAssertEqual(HexLiteral.nine.bits, [.high, .low, .low, .high])
        XCTAssertEqual(HexLiteral.ten.bits, [.high, .low, .high, .low])
        XCTAssertEqual(HexLiteral.eleven.bits, [.high, .low, .high, .high])
        XCTAssertEqual(HexLiteral.twelve.bits, [.high, .high, .low, .low])
        XCTAssertEqual(HexLiteral.thirteen.bits, [.high, .high, .low, .high])
        XCTAssertEqual(HexLiteral.fourteen.bits, [.high, .high, .high, .low])
        XCTAssertEqual(HexLiteral.fifteen.bits, [.high, .high, .high, .high])
    }

    /// Test bits init creates correct case for valid bit vector.
    func testBitsInit() {
        XCTAssertEqual(HexLiteral(bits: [.low, .low, .low, .low]), .zero)
        XCTAssertEqual(HexLiteral(bits: [.low, .low, .low, .high]), .one)
        XCTAssertEqual(HexLiteral(bits: [.low, .low, .high, .low]), .two)
        XCTAssertEqual(HexLiteral(bits: [.low, .low, .high, .high]), .three)
        XCTAssertEqual(HexLiteral(bits: [.low, .high, .low, .low]), .four)
        XCTAssertEqual(HexLiteral(bits: [.low, .high, .low, .high]), .five)
        XCTAssertEqual(HexLiteral(bits: [.low, .high, .high, .low]), .six)
        XCTAssertEqual(HexLiteral(bits: [.low, .high, .high, .high]), .seven)
        XCTAssertEqual(HexLiteral(bits: [.high, .low, .low, .low]), .eight)
        XCTAssertEqual(HexLiteral(bits: [.high, .low, .low, .high]), .nine)
        XCTAssertEqual(HexLiteral(bits: [.high, .low, .high, .low]), .ten)
        XCTAssertEqual(HexLiteral(bits: [.high, .low, .high, .high]), .eleven)
        XCTAssertEqual(HexLiteral(bits: [.high, .high, .low, .low]), .twelve)
        XCTAssertEqual(HexLiteral(bits: [.high, .high, .low, .high]), .thirteen)
        XCTAssertEqual(HexLiteral(bits: [.high, .high, .high, .low]), .fourteen)
        XCTAssertEqual(HexLiteral(bits: [.high, .high, .high, .high]), .fifteen)
    }

    /// Test bits init returns nil for invalid length bit vector.
    func testBitsInitInvalidLength() {
        XCTAssertNil(HexLiteral(bits: []))
        XCTAssertNil(HexLiteral(bits: [.low, .low, .low]))
        XCTAssertNil(HexLiteral(bits: [.low, .low, .low, .low, .low]))
        XCTAssertNil(HexLiteral(bits: [.low, .low, .low, .low, .low, .low]))
        XCTAssertNil(HexLiteral(bits: [.low, .low, .low, .low, .low, .low, .low]))
        XCTAssertNil(HexLiteral(bits: [.low, .low, .low, .low, .low, .low, .low, .low]))
    }

}
