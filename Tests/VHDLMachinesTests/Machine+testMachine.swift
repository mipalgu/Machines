// Machine+testMachine.swift
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

import Foundation
import VHDLMachines
import VHDLParsing

/// Add test machine.
extension Machine {

    // swiftlint:disable function_body_length
    // swiftlint:disable force_unwrapping

    /// A default test machine.
    static func testMachine(directory: URL = PingPongArrangement().machinePath) -> Machine {
        VHDLMachines.Machine(
            actions: [.onEntry, .internal, .onExit, .onResume, .onSuspend],
            name: VariableName(rawValue: "TestMachine")!,
            path: directory.appendingPathComponent("TestMachine.machine", isDirectory: true),
            includes: [
                .library(value: "IEEE"),
                .include(value: "IEEE.std_logic_1164.ALL"),
                .include(value: "IEEE.math_real.ALL")
            ],
            externalSignals: [
                PortSignal(
                    type: .stdLogic,
                    name: VariableName.x,
                    mode: .input,
                    defaultValue: .literal(value: .logic(value: .high)),
                    comment: Comment(rawValue: "-- A std_logic variable.")!
                ),
                PortSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "xx")!,
                    mode: .output,
                    defaultValue: .literal(value: .vector(value: .bits(
                        value: BitVector(values: [.low, .low])
                    ))),
                    comment: Comment(rawValue: "-- A variable called xx.")!
                )
            ],
            clocks: [
                Clock(name: VariableName.clk, frequency: 50, unit: .MHz),
                Clock(name: VariableName.clk2, frequency: 20, unit: .kHz)
            ],
            drivingClock: 0,
            dependentMachines: [:],
            machineSignals: [
                LocalSignal(
                    type: .stdLogic,
                    name: VariableName(rawValue: "machineSignal1")!,
                    defaultValue: nil,
                    comment: nil
                ),
                LocalSignal(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 2, lower: 0))),
                    name: VariableName(rawValue: "machineSignal2")!,
                    defaultValue: .literal(value: .vector(value: .bits(
                        value: BitVector(values: [.high, .high, .high])
                    ))),
                    comment: Comment(rawValue: "-- machine signal 2")!
                )
            ],
            isParameterised: true,
            parameterSignals: [
                Parameter(
                    type: .stdLogic,
                    name: VariableName(rawValue: "parX")!,
                    defaultValue: .literal(value: .logic(value: .high)),
                    comment: Comment(rawValue: "-- Parameter parX")!
                ),
                Parameter(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "parXs")!,
                    defaultValue: .literal(value: .vector(value: .bits(
                        value: BitVector(values: [.low, .high])
                    ))),
                    comment: Comment(rawValue: "-- Parameter parXs")!
                )
            ],
            returnableSignals: [
                ReturnableVariable(
                    type: .stdLogic,
                    name: VariableName(rawValue: "retX")!,
                    comment: Comment(rawValue: "-- Returnable retX")!
                ),
                ReturnableVariable(
                    type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                    name: VariableName(rawValue: "retXs")!,
                    comment: Comment(rawValue: "-- Returnable retXs")!
                )
            ],
            states: [
                State.defaultState(name: VariableName.initial),
                State.defaultState(name: VariableName.suspendedState),
                State.defaultState(name: VariableName.state0)
            ],
            transitions: [
                VHDLMachines.Transition(
                    condition: .conditional(condition: .literal(value: false)), source: 0, target: 1
                ),
                VHDLMachines.Transition(
                    // "after_ms(50) or after(2) or after_rt(20000)"
                    condition: .or(
                        lhs: .after(statement: AfterStatement(
                            amount: .literal(value: .decimal(value: 50)), period: .ms
                        )),
                        rhs: .or(
                            lhs: .after(statement: AfterStatement(
                                amount: .literal(value: .decimal(value: 2)), period: .s
                            )),
                            rhs: .after(statement: AfterStatement(
                                amount: .literal(value: .decimal(value: 20000)), period: .ringlet
                            ))
                        )
                    ),
                    source: 0,
                    target: 1
                ),
                VHDLMachines.Transition(
                    condition: TransitionCondition.conditional(condition: .literal(value: true)),
                    source: 0,
                    target: 1
                ),
                VHDLMachines.Transition(
                    // "xx = \"11\""
                    condition: .conditional(condition: .comparison(
                        value: .equality(
                            lhs: .variable(name: .xx),
                            rhs: .literal(value: .vector(
                                value: .bits(value: BitVector(values: [.high, .high]))
                            ))
                        )
                    )),
                    source: 1,
                    target: 2
                ),
                VHDLMachines.Transition(
                    // // "x = '1'"
                    condition: .conditional(condition: .comparison(
                        value: .equality(lhs: .variable(name: .x), rhs: .literal(value: .bit(value: .high)))
                    )),
                    source: 1,
                    target: 2
                ),
                VHDLMachines.Transition(
                    condition: .conditional(condition: .literal(value: true)), source: 1, target: 0
                )
            ],
            initialState: 0,
            suspendedState: 1,
            architectureHead: nil,
            architectureBody: nil
        )
    }

    // swiftlint:enable force_unwrapping
    // swiftlint:enable function_body_length

}
