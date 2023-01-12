// BitLiteralTests.swift
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

/// Test class for ``BitLiteral``.
final class BitLiteralTests: XCTestCase {

    /// Test rawValue is created correctly.
    func testRawValue() {
        XCTAssertEqual(BitLiteral.high.rawValue, "'1'")
        XCTAssertEqual(BitLiteral.low.rawValue, "'0'")
    }

    /// Test that the init sets the correct case for valid raw values.
    func testValidRawInit() {
        XCTAssertEqual(BitLiteral(rawValue: "'1'"), .high)
        XCTAssertEqual(BitLiteral(rawValue: "'0'"), .low)
    }

    /// Test init returns nil for invalid raw values.
    func testInvalidRawValueInit() {
        XCTAssertNil(BitLiteral(rawValue: "1"))
        XCTAssertNil(BitLiteral(rawValue: "'i'"))
    }

    /// Test rawValue init creates correct cases when whitespace is present.
    func testWhitespaceRawValues() {
        XCTAssertEqual(BitLiteral(rawValue: " '1' "), .high)
        XCTAssertEqual(BitLiteral(rawValue: " '0' "), .low)
    }

    /// Test vector literal computed property is correct.
    func testVectorLiteral() {
        XCTAssertEqual(BitLiteral.high.vectorLiteral, "1")
        XCTAssertEqual(BitLiteral.low.vectorLiteral, "0")
    }

    /// Test bits required calculates the correct number of bits for an unsigned number.
    func testBitsRequired() {
        XCTAssertNil(BitLiteral.bitsRequired(for: 0))
        XCTAssertEqual(BitLiteral.bitsRequired(for: 1), 1)
        XCTAssertEqual(BitLiteral.bitsRequired(for: 2), 2)
        XCTAssertEqual(BitLiteral.bitsRequired(for: 3), 2)
        XCTAssertEqual(BitLiteral.bitsRequired(for: 4), 3)
        XCTAssertEqual(BitLiteral.bitsRequired(for: 5), 3)
        XCTAssertEqual(BitLiteral.bitsRequired(for: 6), 3)
        XCTAssertEqual(BitLiteral.bitsRequired(for: 7), 3)
        XCTAssertEqual(BitLiteral.bitsRequired(for: 8), 4)
    }

    /// Test bitVersions creates a correct layout of BitLiterals for a given value and size.
    func testBitVersion() {
        XCTAssertTrue(BitLiteral.bitVersion(of: -1, bitsRequired: 1).isEmpty)
        XCTAssertTrue(BitLiteral.bitVersion(of: 1, bitsRequired: 0).isEmpty)
        XCTAssertTrue(BitLiteral.bitVersion(of: 1, bitsRequired: -1).isEmpty)
        XCTAssertTrue(BitLiteral.bitVersion(of: 8, bitsRequired: 2).isEmpty)
        XCTAssertTrue(BitLiteral.bitVersion(of: 8, bitsRequired: 3).isEmpty)
        XCTAssertEqual(BitLiteral.bitVersion(of: 0, bitsRequired: 4), [.low, .low, .low, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 1, bitsRequired: 4), [.low, .low, .low, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 2, bitsRequired: 4), [.low, .low, .high, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 3, bitsRequired: 4), [.low, .low, .high, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 4, bitsRequired: 4), [.low, .high, .low, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 5, bitsRequired: 4), [.low, .high, .low, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 6, bitsRequired: 4), [.low, .high, .high, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 7, bitsRequired: 4), [.low, .high, .high, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 1, bitsRequired: 1), [.high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 2, bitsRequired: 2), [.high, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 3, bitsRequired: 2), [.high, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 4, bitsRequired: 3), [.high, .low, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 5, bitsRequired: 3), [.high, .low, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 6, bitsRequired: 3), [.high, .high, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 7, bitsRequired: 3), [.high, .high, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 8, bitsRequired: 4), [.high, .low, .low, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 9, bitsRequired: 4), [.high, .low, .low, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 10, bitsRequired: 4), [.high, .low, .high, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 11, bitsRequired: 4), [.high, .low, .high, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 12, bitsRequired: 4), [.high, .high, .low, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 13, bitsRequired: 4), [.high, .high, .low, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 14, bitsRequired: 4), [.high, .high, .high, .low])
        XCTAssertEqual(BitLiteral.bitVersion(of: 15, bitsRequired: 4), [.high, .high, .high, .high])
        XCTAssertEqual(BitLiteral.bitVersion(of: 16, bitsRequired: 5), [.high, .low, .low, .low, .low])
    }

}
