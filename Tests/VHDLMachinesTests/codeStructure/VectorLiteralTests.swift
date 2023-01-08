// VectorLiteralTests.swift
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

/// Test class for ``VectorLiteral``.
final class VectorLiteralTests: XCTestCase {

    /// Test the raw values are correct.
    func testRawValues() {
        XCTAssertEqual(VectorLiteral.bits(value: [.high, .low, .high]).rawValue, "\"101\"")
        XCTAssertEqual(VectorLiteral.hexademical(value: [.ten, .eleven]).rawValue, "x\"AB\"")
        XCTAssertEqual(VectorLiteral.octal(value: [.six, .seven]).rawValue, "o\"67\"")
    }

    /// Test valid raw values initialise the correct ``VectorLiteral``.
    func testRawValueInitForValidInput() {
        XCTAssertEqual(VectorLiteral(rawValue: "\"101\""), VectorLiteral.bits(value: [.high, .low, .high]))
        XCTAssertEqual(VectorLiteral(rawValue: "x\"AB\""), VectorLiteral.hexademical(value: [.ten, .eleven]))
        XCTAssertEqual(VectorLiteral(rawValue: "o\"67\""), VectorLiteral.octal(value: [.six, .seven]))
    }

    /// Test that a long rawValue returns nil in the init.
    func testLongRawValueReturnsNilInInit() {
        XCTAssertNil(VectorLiteral(rawValue: "\"" + String(repeating: "1", count: 257) + "\""))
    }

    /// Test that rawValue with incorrect prefix and suffic returns nil in init.
    func testRawValueWithIncorrectPrefixAndSuffixReturnsNilInInit() {
        XCTAssertNil(VectorLiteral(rawValue: "101"))
        XCTAssertNil(VectorLiteral(rawValue: "\"101"))
        XCTAssertNil(VectorLiteral(rawValue: "101\""))
        XCTAssertNil(VectorLiteral(rawValue: "x\"AB"))
        XCTAssertNil(VectorLiteral(rawValue: "\"AB\""))
        XCTAssertNil(VectorLiteral(rawValue: "\"AB"))
        XCTAssertNil(VectorLiteral(rawValue: "AB\""))
        XCTAssertNil(VectorLiteral(rawValue: "o\"67"))
        XCTAssertNil(VectorLiteral(rawValue: "\"67\""))
        XCTAssertNil(VectorLiteral(rawValue: "\"67"))
        XCTAssertNil(VectorLiteral(rawValue: "67\""))
    }

    /// Test init returns nil when rawValue contains invalid characters.
    func testInvalidCharacters() {
        XCTAssertNil(VectorLiteral(rawValue: "121"))
        XCTAssertNil(VectorLiteral(rawValue: "x\"ABT\""))
        XCTAssertNil(VectorLiteral(rawValue: "o\"67T\""))
    }

    /// Test size property correctly calculates the number of bits.
    func testSize() {
        XCTAssertEqual(VectorLiteral.bits(value: [.high, .low, .high]).size, 3)
        XCTAssertEqual(VectorLiteral.hexademical(value: [.ten, .eleven]).size, 8)
        XCTAssertEqual(VectorLiteral.octal(value: [.six, .seven]).size, 6)
    }

}
