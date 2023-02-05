// ArchitectureHeadTests.swift
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
@testable import VHDLMachines
import VHDLParsing
import XCTest

/// Test class for `ArchitectureHead` extensions.
final class ArchitectureHeadTests: XCTestCase {

    // swiftlint:disable function_body_length
    // swiftlint:disable force_unwrapping

    /// Test the machine init creates the correct variables.
    func testMachineInit() {
        let machine = Machine.testMachine(
            directory: URL(fileURLWithPath: PingPongArrangement().machinesFolder, isDirectory: true)
        )
        let result = ArchitectureHead(machine: machine)
        let internalStateType = SignalType.ranged(type: .stdLogicVector(size: .downto(upper: 3, lower: 0)))
        let stateType = SignalType.ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0)))
        let commandType = stateType
        let expected = ArchitectureHead(statements: [
            .comment(value: Comment(rawValue: "-- Internal State Representation Bits")!),
            .constant(value: ConstantSignal(
                name: .readSnapshot,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .low, .low, .low])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .onSuspend,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .low, .low, .high])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .onResume,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .low, .high, .low])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .onEntry,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .low, .high, .high])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .noOnEntry,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .high, .low, .low])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .checkTransition,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .high, .low, .high])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .onExit,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .high, .high, .low])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .internal,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .high, .high, .high])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .writeSnapshot,
                type: internalStateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.high, .low, .low, .low])
                ))),
                comment: nil
            )!),
            .definition(signal: LocalSignal(
                type: internalStateType,
                name: .internalState,
                defaultValue: .variable(name: .readSnapshot),
                comment: nil
            )),
            .comment(value: Comment(rawValue: "-- State Representation Bits")!),
            .constant(value: ConstantSignal(
                name: .initial,
                type: stateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .low])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .suspendedState,
                type: stateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .high])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .state0,
                type: stateType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.high, .low])
                ))),
                comment: nil
            )!),
            .definition(signal: LocalSignal(
                type: stateType,
                name: .currentState,
                defaultValue: .variable(
                    name: VariableName(rawValue: "STATE_\(VariableName.suspendedState)")!
                ),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: stateType,
                name: .targetState,
                defaultValue: .variable(
                    name: VariableName(rawValue: "STATE_\(VariableName.suspendedState)")!
                ),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: stateType,
                name: .previousRinglet,
                defaultValue: .literal(value: .vector(
                    value: .logics(value: LogicVector(values: [.highImpedance, .highImpedance]))
                )),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: stateType,
                name: .suspendedFrom,
                defaultValue: .variable(
                    name: VariableName(rawValue: "STATE_\(VariableName.initial)")!
                ),
                comment: nil
            )),
            .comment(value: Comment(rawValue: "-- Suspension Commands")!),
            .constant(value: ConstantSignal(
                name: .nullCommand,
                type: commandType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .low])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .restartCommand,
                type: commandType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.low, .high])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .suspendCommand,
                type: commandType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.high, .low])
                ))),
                comment: nil
            )!),
            .constant(value: ConstantSignal(
                name: .resumeCommand,
                type: commandType,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: [.high, .high])
                ))),
                comment: nil
            )!),
            .comment(value: Comment(rawValue: "-- After Variables")!),
            .definition(signal: LocalSignal(
                type: .natural,
                name: .ringletCounter,
                defaultValue: .literal(value: .integer(value: 0)),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .real,
                name: .clockPeriod,
                defaultValue: .literal(value: .decimal(value: 20000.00)),
                comment: Comment(rawValue: "-- ps")!
            )),
            .definition(signal: LocalSignal(
                type: .real,
                name: .ringletLength,
                defaultValue: .binary(operation: .multiplication(
                    lhs: .literal(value: .decimal(value: 5.0)), rhs: .variable(name: .clockPeriod)
                )),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .real,
                name: .ringletPerPs,
                defaultValue: .binary(operation: .division(
                    lhs: .literal(value: .decimal(value: 1.0)), rhs: .variable(name: .ringletLength)
                )),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .real,
                name: .ringletPerNs,
                defaultValue: .binary(operation: .multiplication(
                    lhs: .literal(value: .decimal(value: 1000.0)), rhs: .variable(name: .ringletPerPs)
                )),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .real,
                name: .ringletPerUs,
                defaultValue: .binary(operation: .multiplication(
                    lhs: .literal(value: .decimal(value: 1_000_000.0)), rhs: .variable(name: .ringletPerPs)
                )),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .real,
                name: .ringletPerMs,
                defaultValue: .binary(operation: .multiplication(
                    lhs: .literal(value: .decimal(value: 1_000_000_000.0)),
                    rhs: .variable(name: .ringletPerPs)
                )),
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .real,
                name: .ringletPerS,
                defaultValue: .binary(operation: .multiplication(
                    lhs: .literal(value: .decimal(value: 1_000_000_000_000.0)),
                    rhs: .variable(name: .ringletPerPs)
                )),
                comment: nil
            )),
            .comment(value: Comment(rawValue: "-- Snapshot of External Signals and Variables")!),
            .definition(signal: LocalSignal(
                type: .stdLogic,
                name: .x,
                defaultValue: nil,
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                name: .xx,
                defaultValue: nil,
                comment: nil
            )),
            .comment(value: Comment(rawValue: "-- Snapshot of Parameter Signals and Variables")!),
            .definition(signal: LocalSignal(
                type: .stdLogic,
                name: .parX,
                defaultValue: nil,
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                name: .parXs,
                defaultValue: nil,
                comment: nil
            )),
            .comment(value: Comment(rawValue: "-- Snapshot of Output Signals and Variables")!),
            .definition(signal: LocalSignal(
                type: .stdLogic,
                name: .retX,
                defaultValue: nil,
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
                name: .retXs,
                defaultValue: nil,
                comment: nil
            )),
            .comment(value: Comment(rawValue: "-- Machine Signals")!),
            .definition(signal: LocalSignal(
                type: .stdLogic,
                name: .machineSignal1,
                defaultValue: nil,
                comment: nil
            )),
            .definition(signal: LocalSignal(
                type: .ranged(type: .stdLogicVector(size: .downto(upper: 2, lower: 0))),
                name: .machineSignal2,
                defaultValue: .literal(value: .vector(
                    value: .bits(value: BitVector(values: [.high, .high, .high]))
                )),
                comment: Comment(rawValue: "-- machine signal 2")!
            )),
            .comment(value: Comment(rawValue: "-- User-Specific Code for Architecture Head")!)
        ])
        XCTAssertEqual(result, expected)
    }

    // swiftlint:enable force_unwrapping
    // swiftlint:enable function_body_length

}
