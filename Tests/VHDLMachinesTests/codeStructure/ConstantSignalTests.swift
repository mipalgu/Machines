// ConstantSignalTests.swift
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
import VHDLParsing
import XCTest

/// Test class for ``ConstantSignal``.
final class ConstantSignalTests: XCTestCase {

    // swiftlint:disable function_body_length

    /// Test that the action bit representations are correct.
    func testActionConstants() {
        let actions: [VariableName] = [.onEntry, .onExit, .internal, .onResume, .onSuspend]
        let constants = [
            ConstantSignal(
                name: VariableName.checkTransition,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .low, .low, .low])
                )))
            ),
            ConstantSignal(
                name: VariableName.internal,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .low, .low, .high])
                )))
            ),
            ConstantSignal(
                name: VariableName.noOnEntry,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .low, .high, .low])
                )))
            ),
            ConstantSignal(
                name: VariableName.onEntry,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .low, .high, .high])
                )))
            ),
            ConstantSignal(
                name: VariableName.onExit,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .high, .low, .low])
                )))
            ),
            ConstantSignal(
                name: VariableName.onResume,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .high, .low, .high])
                )))
            ),
            ConstantSignal(
                name: VariableName.onSuspend,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .high, .high, .low])
                )))
            ),
            ConstantSignal(
                name: VariableName.readSnapshot,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.low, .high, .high, .high])
                )))
            ),
            ConstantSignal(
                name: VariableName.writeSnapshot,
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0))),
                value: .literal(value: .vector(value: .logics(
                    value: LogicVector(values: [.high, .low, .low, .low])
                )))
            )
        ].compactMap { $0 }
        guard constants.count == 9 else {
            XCTFail("Incorrect number of constants")
            return
        }
        XCTAssertEqual(ConstantSignal.constants(for: actions), constants)
    }

    // swiftlint:enable function_body_length

    /// Test clock period is generated correctly.
    func testClockPeriod() {
        let machine = Machine.testMachine()
        guard machine.drivingClock >= 0, machine.drivingClock < machine.clocks.count else {
            XCTFail("Could not get driving clock.")
            return
        }
        let clock = machine.clocks[machine.drivingClock]
        let result = ConstantSignal.clockPeriod(period: clock.period)
        XCTAssertNotNil(result)
        XCTAssertEqual(
            result,
            ConstantSignal(
                name: .clockPeriod,
                type: .real,
                value: .literal(value: .decimal(value: Double(clock.period.picoseconds_d))),
                // swiftlint:disable:next force_unwrapping
                comment: Comment(rawValue: "-- ps")!
            )
        )
    }

    /// Test the state init creates the constant signal correctly.
    func testStateInit() {
        let state = State(name: .initial, actions: [:], signals: [], externalVariables: [])
        let result = ConstantSignal(state: state, bitsRequired: 2, index: 1)
        XCTAssertNotNil(result)
        XCTAssertEqual(
            result,
            ConstantSignal(
                name: .name(for: state),
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                value: .literal(value: .vector(value: .bits(value: BitVector(values: [.low, .high]))))
            )
        )
    }

}
