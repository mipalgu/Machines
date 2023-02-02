// AfterStatement.swift
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

import VHDLParsing

public struct AfterStatement: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The period of the time in an ``AfterStatement``. This period represents the amount of time elapsed
    /// during an after expression. The time may be a SI-prefixed time or the number of ringlets since the
    /// start of a states execution.
    public enum Period: RawRepresentable, Equatable, Hashable, Codable, Sendable {

        /// Picoseconds.
        case ps

        /// Nanoseconds.
        case ns

        /// Microseconds.
        case us

        /// Milliseconds.
        case ms

        /// Seconds.
        case s

        /// The number of ringlets since the start of a states execution.
        case ringlet

        /// The name of the variable storing the number of ringlet for a unit period.
        @inlinable public var rawValue: VariableName {
            switch self {
            case .ps:
                return VariableName.ringletPerPs
            case .ns:
                return VariableName.ringletPerNs
            case .us:
                return VariableName.ringletPerUs
            case .ms:
                return VariableName.ringletPerMs
            case .s:
                return VariableName.ringletPerS
            case .ringlet:
                return VariableName.ringletCounter
            }
        }

        /// The length of the `after` command for this period.
        @inlinable public var afterLength: Int {
            switch self {
            case .s:
                return 5
            default:
                return 8
            }
        }

        /// Creates a new period from the name of the variable storing the number of ringlets for a unit
        /// period.
        /// - Parameter rawValue: The name of the variable storing the number of ringlets per unit period.
        @inlinable
        public init?(rawValue: VariableName) {
            switch rawValue {
            case VariableName.ringletPerPs:
                self = .ps
            case VariableName.ringletPerNs:
                self = .ns
            case VariableName.ringletPerUs:
                self = .us
            case VariableName.ringletPerMs:
                self = .ms
            case VariableName.ringletPerS:
                self = .s
            case VariableName.ringletCounter:
                self = .ringlet
            default:
                return nil
            }
        }

        /// Create a new period from the `after` command.
        /// - Parameter after: The `after` command, e.g. `after`, `after_ps`, `after_ns`, `after_us`,
        /// `after_ms`, `after_rt`.
        @usableFromInline
        init?(after: String) {
            guard after.lowercased().hasPrefix("after"), after.count >= 5 else {
                return nil
            }
            if after.count == 5 {
                self = .s
                return
            }
            if after[after.index(after.startIndex, offsetBy: 5)] != "_" {
                self = .s
                return
            }
            guard after.count >= 8 else {
                return nil
            }
            let value = after[
                String.Index(utf16Offset: 6, in: after)...String.Index(utf16Offset: 7, in: after)
            ]
            switch value.lowercased() {
            case "ps":
                self = .ps
            case "ns":
                self = .ns
            case "us":
                self = .us
            case "ms":
                self = .ms
            case "rt":
                self = .ringlet
            default:
                return nil
            }
        }

    }

    public let amount: Expression

    public let period: Period

    public var rawValue: String {
        if case .ringlet = period {
            return Expression.conditional(condition: .comparison(value: .greaterThanOrEqual(
                lhs: .variable(name: .ringletCounter), rhs: .cast(operation: .real(expression: amount))
            ))).rawValue
        }
        return Expression.conditional(condition: .comparison(value: .greaterThanOrEqual(
            lhs: .variable(name: .ringletCounter),
            rhs: .precedence(value: .binary(
                operation: .multiplication(
                    lhs: .cast(operation: .real(expression: amount)),
                    rhs: .variable(name: period.rawValue)
                )
            ))
        ))).rawValue
    }

    public init(amount: Expression, period: Period) {
        self.amount = amount
        self.period = period
    }

    public init?(rawValue: String) {
        guard
            let expression = ComparisonOperation(rawValue: rawValue),
            case .greaterThanOrEqual(let lhs, let rhs) = expression,
            case .variable(let name) = lhs,
            name == .ringletCounter,
            case .precedence(let value) = rhs,
            case .binary(let operation) = value,
            case .multiplication(let lhs, let rhs) = operation,
            case .cast(let castOperation) = lhs,
            case .variable(let name) = rhs,
            let period = Period(rawValue: name)
        else {
            return nil
        }
        self.init(amount: castOperation.expression, period: period)
    }

    public init?(after: String) {
        let value = after.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.count < 256, let period = Period(after: value) else {
            return nil
        }
        let amount = value.dropFirst(period.afterLength)
        guard
            amount.hasPrefix("("),
            amount.hasSuffix(")"),
            let expression = Expression(rawValue: String(amount.dropFirst().dropLast()))
        else {
            return nil
        }
        self.init(amount: expression, period: period)
    }

}
