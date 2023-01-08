// VectorSizeTests.swift
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

/// Test class for ``VectorSize``.
final class VectorSizeTests: XCTestCase {

    /// Test raw value is created correctly.
    func testRawValue() {
        let downto = VectorSize.downto(upper: 12, lower: 5)
        XCTAssertEqual(downto.rawValue, "12 downto 5")
        let to = VectorSize.to(lower: 2, upper: 7)
        XCTAssertEqual(to.rawValue, "2 to 7")
    }

    /// Test valid raw data is convertible for `downto` case.
    func testDowntoValidRawValueInit() {
        let raw = "12 downto 5"
        let result = VectorSize(rawValue: raw)
        let expected = VectorSize.downto(upper: 12, lower: 5)
        XCTAssertEqual(result, expected)
    }

    /// Test valid raw data is convertible for `to` case.
    func testToValidRawValueInit() {
        let raw = "2 to 7"
        let result = VectorSize(rawValue: raw)
        let expected = VectorSize.to(lower: 2, upper: 7)
        XCTAssertEqual(result, expected)
    }

    /// Test result is nil for data that is too small.
    func testSmallRawData() {
        let raw = "2 t 4"
        XCTAssertNil(VectorSize(rawValue: raw))
        let raw2 = ""
        XCTAssertNil(VectorSize(rawValue: raw2))
    }

    /// Test init returns nil when `downto` and `to` are present in raw value.
    func testDowntoAndToCase() {
        let raw = "2 downto to 4"
        XCTAssertNil(VectorSize(rawValue: raw))
    }

    /// Test init returns nil for non-numeric `downto` case.
    func testNonNumericDowntoCase() {
        let raw = "a downto 4"
        XCTAssertNil(VectorSize(rawValue: raw))
    }

    /// Test init returns nil for non-numeric `to` case.
    func testNonNumericToCase() {
        let raw = "2 to b"
        XCTAssertNil(VectorSize(rawValue: raw))
    }

    /// Test that init returns nil for invalid size.
    func testInvalidSizeReturnsNil() {
        let raw = "4 to 2"
        XCTAssertNil(VectorSize(rawValue: raw))
        let raw2 = "2 downto 4"
        XCTAssertNil(VectorSize(rawValue: raw2))
    }

    /// Test upercased ranges still work.
    func testUppercasedRanges() {
        let raw = "2 TO 4"
        let result = VectorSize(rawValue: raw)
        let expected = VectorSize.to(lower: 2, upper: 4)
        XCTAssertEqual(result, expected)
        let raw2 = "4 DOWNTO 2"
        let result2 = VectorSize(rawValue: raw2)
        let expected2 = VectorSize.downto(upper: 4, lower: 2)
        XCTAssertEqual(result2, expected2)
    }

    /// Test the size is correct.
    func testSize() {
        let downto = VectorSize.downto(upper: 12, lower: 5)
        XCTAssertEqual(downto.size, 8)
        let to = VectorSize.to(lower: 2, upper: 7)
        XCTAssertEqual(to.size, 6)
    }

}
