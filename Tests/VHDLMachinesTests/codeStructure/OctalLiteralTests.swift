// OctalLiteralTests.swift
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

/// Test class for ``OctalLiteral``.
final class OctalLiteralTests: XCTestCase {

    /// Test `bits` computed property creates bit representation correctly.
    func testBits() {
        XCTAssertEqual(OctalLiteral.zero.bits, [.low, .low, .low])
        XCTAssertEqual(OctalLiteral.one.bits, [.low, .low, .high])
        XCTAssertEqual(OctalLiteral.two.bits, [.low, .high, .low])
        XCTAssertEqual(OctalLiteral.three.bits, [.low, .high, .high])
        XCTAssertEqual(OctalLiteral.four.bits, [.high, .low, .low])
        XCTAssertEqual(OctalLiteral.five.bits, [.high, .low, .high])
        XCTAssertEqual(OctalLiteral.six.bits, [.high, .high, .low])
        XCTAssertEqual(OctalLiteral.seven.bits, [.high, .high, .high])
    }

    /// Test bits init creates correct case.
    func testBitsInit() {
        XCTAssertEqual(OctalLiteral(bits: [.low, .low, .low]), OctalLiteral.zero)
        XCTAssertEqual(OctalLiteral(bits: [.low, .low, .high]), OctalLiteral.one)
        XCTAssertEqual(OctalLiteral(bits: [.low, .high, .low]), OctalLiteral.two)
        XCTAssertEqual(OctalLiteral(bits: [.low, .high, .high]), OctalLiteral.three)
        XCTAssertEqual(OctalLiteral(bits: [.high, .low, .low]), OctalLiteral.four)
        XCTAssertEqual(OctalLiteral(bits: [.high, .low, .high]), OctalLiteral.five)
        XCTAssertEqual(OctalLiteral(bits: [.high, .high, .low]), OctalLiteral.six)
        XCTAssertEqual(OctalLiteral(bits: [.high, .high, .high]), OctalLiteral.seven)
    }

    /// Test bits init returns nil for incorrect number of bits.
    func testBitsInitNil() {
        XCTAssertNil(OctalLiteral(bits: []))
        XCTAssertNil(OctalLiteral(bits: [.low]))
        XCTAssertNil(OctalLiteral(bits: [.low, .low]))
        XCTAssertNil(OctalLiteral(bits: [.low, .low, .low, .low]))
    }

    /// Test the raw values are correct.
    func testRawValue() {
        XCTAssertEqual(OctalLiteral.zero.rawValue, "0")
        XCTAssertEqual(OctalLiteral.one.rawValue, "1")
        XCTAssertEqual(OctalLiteral.two.rawValue, "2")
        XCTAssertEqual(OctalLiteral.three.rawValue, "3")
        XCTAssertEqual(OctalLiteral.four.rawValue, "4")
        XCTAssertEqual(OctalLiteral.five.rawValue, "5")
        XCTAssertEqual(OctalLiteral.six.rawValue, "6")
        XCTAssertEqual(OctalLiteral.seven.rawValue, "7")
    }

}
