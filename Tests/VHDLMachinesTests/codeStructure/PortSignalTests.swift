// PortSignalTests.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
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

/// Tests for the ``PortSignal`` type.
final class PortSignalTests: XCTestCase {

    /// The signal under test.
    var signal = PortSignal(
        type: .stdLogic,
        name: VariableName(text: "x"),
        mode: .output,
        defaultValue: .literal(value: .logic(value: .high)),
        comment: Comment(text: "signal x")
    )

    /// Initialises the signal under test.
    override func setUp() {
        self.signal = PortSignal(
            type: .stdLogic,
            name: VariableName(text: "x"),
            mode: .output,
            defaultValue: .literal(value: .logic(value: .high)),
            comment: Comment(text: "signal x")
        )
    }

    /// Test init sets properties correctly.
    func testInit() {
        guard let comment = Comment(rawValue: "-- signal x") else {
            XCTFail("Failed to create comment.")
            return
        }
        XCTAssertEqual(self.signal.type, .stdLogic)
        XCTAssertEqual(self.signal.name, VariableName(text: "x"))
        XCTAssertEqual(self.signal.mode, .output)
        XCTAssertEqual(self.signal.defaultValue, .literal(value: .logic(value: .high)))
        XCTAssertEqual(self.signal.comment, comment)
    }

    /// Test getters and setters work correctly.
    func testGettersAndSetters() {
        guard let comment = Comment(rawValue: "-- signal y") else {
            XCTFail("Failed to create comment.")
            return
        }
        self.signal.type = .ranged(type: .stdLogicVector(size: .downto(upper: 7, lower: 0)))
        self.signal.name = VariableName(text: "y")
        self.signal.mode = .input
        self.signal.defaultValue = .literal(value: .vector(value: .hexademical(value: [.ten, .ten])))
        self.signal.comment = comment
        XCTAssertEqual(self.signal.type, .ranged(type: .stdLogicVector(size: .downto(upper: 7, lower: 0))))
        XCTAssertEqual(self.signal.name, VariableName(text: "y"))
        XCTAssertEqual(self.signal.mode, .input)
        XCTAssertEqual(
            self.signal.defaultValue, .literal(value: .vector(value: .hexademical(value: [.ten, .ten])))
        )
        XCTAssertEqual(self.signal.comment, comment)
    }

    /// Test rawValue creates correct representation.
    func testRawValue() {
        XCTAssertEqual(self.signal.rawValue, "x: out std_logic := '1'; -- signal x")
        self.signal.comment = nil
        XCTAssertEqual(self.signal.rawValue, "x: out std_logic := '1';")
        self.signal.defaultValue = nil
        XCTAssertEqual(self.signal.rawValue, "x: out std_logic;")
        self.signal.comment = Comment(text: "signal x")
        XCTAssertEqual(self.signal.rawValue, "x: out std_logic; -- signal x")
    }

    /// Test rawValue init works for valid string.
    func testRawValueInit() {
        XCTAssertEqual(PortSignal(rawValue: "x: out std_logic := '1'; -- signal x"), self.signal)
        self.signal.comment = nil
        XCTAssertEqual(PortSignal(rawValue: "x: out std_logic := '1';"), self.signal)
        self.signal.defaultValue = nil
        XCTAssertEqual(PortSignal(rawValue: "x: out std_logic;"), self.signal)
        self.signal.comment = Comment(text: "signal x")
        XCTAssertEqual(PortSignal(rawValue: "x: out std_logic; -- signal x"), self.signal)
    }

    /// Test rawValue init when the colon has spaces around it.
    func testRawValueInitWithSpace() {
        XCTAssertEqual(PortSignal(rawValue: "x : out std_logic := '1'; -- signal x"), self.signal)
        self.signal.comment = nil
        XCTAssertEqual(PortSignal(rawValue: "x : out std_logic := '1';"), self.signal)
        self.signal.defaultValue = nil
        XCTAssertEqual(PortSignal(rawValue: "x : out std_logic;"), self.signal)
        self.signal.comment = Comment(text: "signal x")
        XCTAssertEqual(PortSignal(rawValue: "x : out std_logic; -- signal x"), self.signal)
    }

    /// Test rawValue init works for vector types.
    func testRawValueInitVectorType() {
        signal.type = .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0)))
        XCTAssertEqual(
            PortSignal(rawValue: "x: out std_logic_vector(3 downto 0) := '1'; -- signal x"), signal
        )
        signal.comment = nil
        XCTAssertEqual(
            PortSignal(rawValue: "x: out std_logic_vector(3 downto 0) := '1';"), signal
        )
        signal.defaultValue = nil
        XCTAssertEqual(PortSignal(rawValue: "x: out std_logic_vector(3 downto 0);"), signal)
        signal.comment = Comment(text: "signal x")
        XCTAssertEqual(
            PortSignal(rawValue: "x: out std_logic_vector(3 downto 0); -- signal x"), signal
        )
    }

}
