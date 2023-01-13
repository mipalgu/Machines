// ClockTests.swift
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

/// Test class for ``Clock``.
final class ClockTests: XCTestCase {

    /// The clock under test.
    var clock = Clock(name: VariableName(text: "clk"), frequency: 100, unit: .Hz)

    /// Initialise the clock before every test.
    override func setUp() {
        self.clock = Clock(name: VariableName(text: "clk"), frequency: 100, unit: .Hz)
    }

    /// Test frequency unit raw values.
    func testFrequencyUnit() {
        XCTAssertEqual(Clock.FrequencyUnit.Hz.rawValue, "Hz")
        XCTAssertEqual(Clock.FrequencyUnit.kHz.rawValue, "kHz")
        XCTAssertEqual(Clock.FrequencyUnit.MHz.rawValue, "MHz")
        XCTAssertEqual(Clock.FrequencyUnit.GHz.rawValue, "GHz")
        XCTAssertEqual(Clock.FrequencyUnit.THz.rawValue, "THz")
    }

    /// Test init sets stored properties correctly.
    func testInit() {
        XCTAssertEqual(self.clock.name, VariableName(text: "clk"))
        XCTAssertEqual(self.clock.frequency, 100)
        XCTAssertEqual(self.clock.unit, .Hz)
    }

    /// Test getters and setters work correctly.
    func testGettersAndSetters() {
        self.clock.name = VariableName(text: "clk2")
        XCTAssertEqual(self.clock.name, VariableName(text: "clk2"))
        self.clock.frequency = 200
        XCTAssertEqual(self.clock.frequency, 200)
        self.clock.unit = .kHz
        XCTAssertEqual(self.clock.unit, .kHz)
    }

    /// Test period computed property.
    func testPeriod() {
        XCTAssertEqual(self.clock.period.milliseconds_t, 10)
        self.clock.unit = .kHz
        XCTAssertEqual(self.clock.period.microseconds_t, 10)
        self.clock.unit = .MHz
        XCTAssertEqual(self.clock.period.nanoseconds_t, 10)
        self.clock.unit = .GHz
        XCTAssertEqual(self.clock.period.picoseconds_t, 10)
        self.clock.unit = .THz
        XCTAssertEqual(self.clock.period.picoseconds_d, 0.01)
    }

}
