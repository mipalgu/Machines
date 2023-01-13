// VariableNameTests.swift
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

/// Test class for ``VariableName``.
final class VariableNameTests: XCTestCase {

    /// The name under test.
    var variable = VariableName(text: "clk")

    /// Initialise the name under test before every test.
    override func setUp() {
        self.variable = VariableName(text: "clk")
    }

    /// Test init sets stored property correctly.
    func testInit() {
        XCTAssertEqual(self.variable.rawValue, "clk")
    }

    /// Test that the description matches the raw value.
    func testDescription() {
        XCTAssertEqual(self.variable.description, self.variable.rawValue)
    }

    /// Test comparison operator.
    func testComparison() {
        XCTAssertLessThan(VariableName(text: "clk"), VariableName(text: "dlk"))
    }

    /// Test equality works correctly.
    func testEquality() {
        XCTAssertEqual(VariableName(text: "CLK"), self.variable)
        XCTAssertNotEqual(VariableName(text: "clk2"), self.variable)
    }

    /// Test hashable conformance.
    func testHasher() {
        XCTAssertEqual(self.variable.hashValue, "clk".hashValue)
        XCTAssertEqual(VariableName(text: "CLK").hashValue, "clk".hashValue)
    }

    /// Test rawValue init works correctly.
    func testRawValueInit() {
        XCTAssertEqual(VariableName(rawValue: "clk"), self.variable)
        XCTAssertEqual(VariableName(rawValue: "CLK"), self.variable)
        XCTAssertEqual(VariableName(rawValue: "clk12"), VariableName(text: "clk12"))
        XCTAssertNil(VariableName(rawValue: ""))
        XCTAssertNil(VariableName(rawValue: "2clk"))
        XCTAssertNil(VariableName(rawValue: "clk-"))
        XCTAssertEqual(VariableName(rawValue: "clk_"), VariableName(text: "clk_"))
        XCTAssertNil(VariableName(rawValue: "clk-12"))
        XCTAssertEqual(VariableName(rawValue: "clk_12"), VariableName(text: "clk_12"))
        XCTAssertNil(VariableName(rawValue: "clk-12_"))
        XCTAssertNil(VariableName(rawValue: "clk_12-"))
        XCTAssertNil(VariableName(rawValue: "clk-12_12"))
        XCTAssertNil(VariableName(rawValue: "std_logic"))
        XCTAssertNil(VariableName(rawValue: "std_logic_vector"))
        XCTAssertNil(VariableName(rawValue: "std_ulogic"))
        XCTAssertNil(VariableName(rawValue: "xor"))
        XCTAssertNil(VariableName(rawValue: "clk 12"))
    }

}
