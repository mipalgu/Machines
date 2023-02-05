// ConstantSignal.swift
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
import GUUnits
import VHDLParsing

/// Helper getters for creating machine constants.
extension ConstantSignal {

    // swiftlint:disable force_unwrapping

    /// The suspension commands.
    static let commands = [
        ConstantSignal(
            name: .nullCommand,
            type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
            value: .literal(value: .vector(value: .bits(value: BitVector(values: [.low, .low])))),
            comment: nil
        )!,
        ConstantSignal(
            name: .restartCommand,
            type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
            value: .literal(value: .vector(value: .bits(value: BitVector(values: [.low, .high])))),
            comment: nil
        )!,
        ConstantSignal(
            name: .suspendCommand,
            type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
            value: .literal(value: .vector(value: .bits(value: BitVector(values: [.high, .low])))),
            comment: nil
        )!,
        ConstantSignal(
            name: .resumeCommand,
            type: .ranged(type: .stdLogicVector(size: .downto(upper: 1, lower: 0))),
            value: .literal(value: .vector(value: .bits(value: BitVector(values: [.high, .high])))),
            comment: nil
        )!
    ]

    /// The ringlet constants.
    static let ringletConstants: [ConstantSignal] = [
        ConstantSignal(
            name: .ringletLength,
            type: .real,
            value: .binary(operation: .multiplication(
                lhs: .literal(value: .decimal(value: 5.0)), rhs: .variable(name: .clockPeriod)
            ))
        )!,
        ConstantSignal(
            name: .ringletPerPs,
            type: .real,
            value: .binary(operation: .division(
                lhs: .literal(value: .decimal(value: 1.0)), rhs: .variable(name: .ringletLength)
            ))
        )!,
        ConstantSignal(
            name: .ringletPerNs,
            type: .real,
            value: .binary(operation: .multiplication(
                lhs: .literal(value: .decimal(value: 1000.0)), rhs: .variable(name: .ringletPerPs)
            ))
        )!,
        ConstantSignal(
            name: .ringletPerUs,
            type: .real,
            value: .binary(operation: .multiplication(
                lhs: .literal(value: .decimal(value: 1_000_000.0)), rhs: .variable(name: .ringletPerPs)
            ))
        )!,
        ConstantSignal(
            name: .ringletPerMs,
            type: .real,
            value: .binary(operation: .multiplication(
                lhs: .literal(value: .decimal(value: 1_000_000_000.0)),
                rhs: .variable(name: .ringletPerPs)
            ))
        )!,
        ConstantSignal(
            name: .ringletPerS,
            type: .real,
            value: .binary(operation: .multiplication(
                lhs: .literal(value: .decimal(value: 1_000_000_000_000.0)),
                rhs: .variable(name: .ringletPerPs)
            ))
        )!
    ]

    // swiftlint:enable force_unwrapping

    /// Create the constant declaration for the state.
    /// - Parameters:
    ///   - state: The state to convert.
    ///   - bitsRequired: The bits required for all the states to be covered.
    ///   - index: The index of this `state` in the states array of the machine.
    @usableFromInline
    init?(state: State, bitsRequired: Int, index: Int) {
        guard bitsRequired > 0, index >= 0 else {
            return nil
        }
        let bits = BitLiteral.bitVersion(of: index, bitsRequired: bitsRequired)
        let type = SignalType.ranged(type: .stdLogicVector(
            size: .downto(upper: bitsRequired - 1, lower: 0)
        ))
        self.init(
            name: VariableName.name(for: state),
            type: type,
            value: .literal(value: .vector(value: .bits(value: BitVector(values: bits)))),
            comment: nil
        )
    }

    /// Create the constant declaration for the state actions within a machine.
    /// - Parameter actions: The actions to convert.
    /// - Returns: The constant declaration for the state actions.
    /// - Note: This method also includes the reserved actions `NoOnEntry`, `CheckTransition`, `ReadSnapshot`
    /// and `WriteSnapshot`.
    @usableFromInline
    static func constants(for actions: [ActionName: String]) -> [ConstantSignal]? {
        let keys = actions.keys
        let actionNamesArray = [
            .noOnEntry, .checkTransition, VariableName.readSnapshot, .writeSnapshot
        ]
        let invalidKeys = Set(actionNamesArray)
        guard !keys.contains(where: { invalidKeys.contains($0) }) else {
            fatalError("Actions contain a reserved name.")
        }
        let actionNames = (actionNamesArray + keys).sorted()
        guard let bitsRequired = BitLiteral.bitsRequired(for: actionNames.count) else {
            return nil
        }
        let bitRepresentations = actionNames.indices.map {
            BitLiteral.bitVersion(of: $0, bitsRequired: bitsRequired)
        }
        let type = SignalType.ranged(type: .stdLogicVector(size: .downto(upper: bitsRequired - 1, lower: 0)))
        let signals: [ConstantSignal] = actionNames.indices.compactMap {
            ConstantSignal(
                name: actionNames[$0],
                type: type,
                value: .literal(value: .vector(value: .bits(
                    value: BitVector(values: bitRepresentations[$0])
                )))
            )
        }
        guard signals.count == actionNames.count else {
            return nil
        }
        return signals
    }

    /// Create a constant `VHDL` literal that represents a clocks period as a `real` value in picoseconds.
    /// - Parameter period: The period to convert.
    /// - Returns: The constant signal.
    @usableFromInline
    static func clockPeriod(period: Time) -> ConstantSignal? {
        guard
            let comment = Comment(rawValue: "-- ps"),
            let constant = ConstantSignal(
                name: VariableName.clockPeriod,
                type: .real,
                value: .literal(value: .decimal(value: Double(period.picoseconds_d))),
                comment: comment
            )
        else {
            return nil
        }
        return constant
    }

}
