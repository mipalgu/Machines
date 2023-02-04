// TransitionCondition.swift
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
import VHDLParsing

/// A condition that labels a transition between states in an LLFSM.
public indirect enum TransitionCondition: RawRepresentable, Equatable, Codable, Hashable, Sendable {

    /// An ``AfterStatement``. This condition evaluates to `true` after the specified time has elapsed.
    case after(statement: AfterStatement)

    /// A `VHDL` `ConditionalExpression`.
    case conditional(condition: ConditionalExpression)

    /// A `VHDL` `BooleanExpression`.
    case boolean(expression: BooleanExpression)

    /// An `and` operation containing an `after` statement..
    case and(lhs: TransitionCondition, rhs: TransitionCondition)

    /// An `or` operation containing an `after` statement..
    case or(lhs: TransitionCondition, rhs: TransitionCondition)

    /// A `nand` operation containing an `after` statement..
    case nand(lhs: TransitionCondition, rhs: TransitionCondition)

    /// A `not` operation containing an `after` statement..
    case not(value: TransitionCondition)

    /// A `nor` operation containing an `after` statement..
    case nor(lhs: TransitionCondition, rhs: TransitionCondition)

    /// An `xor` operation containing an `after` statement..
    case xor(lhs: TransitionCondition, rhs: TransitionCondition)

    /// An `xnor` operation containing an `after` statement..
    case xnor(lhs: TransitionCondition, rhs: TransitionCondition)

    /// A `VHDL` equality operation containing an `after` statement.
    case equals(lhs: TransitionCondition, rhs: TransitionCondition)

    /// A `VHDL` inequality operation containing an `after` statement.
    case notEquals(lhs: TransitionCondition, rhs: TransitionCondition)

    /// A `VHDL` precedence operation containing an `after` statement.
    case precedence(condition: TransitionCondition)

    /// A `VHDL` variable.
    case variable(name: VariableName)

    /// Whether this condition contains an ``AfterStatement``.
    @inlinable public var hasAfter: Bool {
        switch self {
        case .after:
            return true
        case .conditional:
            return false
        case .boolean:
            return false
        case .and(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        case .or(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        case .nand(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        case .not(let value):
            return value.hasAfter
        case .nor(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        case .xor(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        case .xnor(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        case .precedence(let condition):
            return condition.hasAfter
        case .variable:
            return false
        case .equals(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        case .notEquals(let lhs, let rhs):
            return lhs.hasAfter || rhs.hasAfter
        }
    }

    /// The `VHDL` code enacting this condition.
    @inlinable public var rawValue: String {
        switch self {
        case .after(let statement):
            return statement.rawValue
        case .conditional(let condition):
            return condition.rawValue
        case .boolean(let expression):
            return expression.rawValue
        case .and(let lhs, let rhs):
            return "\(lhs.rawValue) and \(rhs.rawValue)"
        case .or(let lhs, let rhs):
            return "\(lhs.rawValue) or \(rhs.rawValue)"
        case .nand(let lhs, let rhs):
            return "\(lhs.rawValue) nand \(rhs.rawValue)"
        case .not(let value):
            return "not \(value.rawValue)"
        case .nor(let lhs, let rhs):
            return "\(lhs.rawValue) nor \(rhs.rawValue)"
        case .xor(let lhs, let rhs):
            return "\(lhs.rawValue) xor \(rhs.rawValue)"
        case .xnor(let lhs, let rhs):
            return "\(lhs.rawValue) xnor \(rhs.rawValue)"
        case .precedence(let condition):
            return "(\(condition.rawValue))"
        case .variable(let name):
            return name.rawValue
        case .equals(let lhs, let rhs):
            return "\(lhs.rawValue) = \(rhs.rawValue)"
        case .notEquals(let lhs, let rhs):
            return "\(lhs.rawValue) /= \(rhs.rawValue)"
        }
    }

    /// Creates a new ``TransitionCondition`` from `VHDL` code that may also contain the `LLFSM` `after`
    /// commands.
    /// - Parameter rawValue: The code to parse.
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 1024 else {
            return nil
        }
        if let name = VariableName(rawValue: trimmedString) {
            self = .variable(name: name)
            return
        }
        if let statement = AfterStatement(after: trimmedString) {
            self = .after(statement: statement)
            return
        }
        if trimmedString.hasPrefix("("), trimmedString.hasSuffix(")"),
            let subString = trimmedString.uptoBalancedBracket, subString.endIndex == trimmedString.endIndex {
            guard
                let condition = TransitionCondition(rawValue: String(subString.dropFirst().dropLast()))
            else {
                return nil
            }
            self = .precedence(condition: condition)
            return
        }
        let words = trimmedString.components(
            separatedBy: .whitespacesAndNewlines.union(.vhdlOperators.union(CharacterSet(charactersIn: ";")))
        )
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        .filter { !$0.isEmpty }
        guard !words.contains(where: { Set.afters.contains($0) }) else {
            self.init(hasAfter: trimmedString)
            return
        }
        if let condition = ConditionalExpression(rawValue: trimmedString) {
            self = .conditional(condition: condition)
            return
        }
        if let boolean = BooleanExpression(rawValue: trimmedString) {
            self = .boolean(expression: boolean)
            return
        }
        return nil
    }

    /// Initialise this condition when the code contains an `after` command.
    /// - Parameter value: The code containing the `after` command.
    private init?(hasAfter value: String) {
        if value.hasPrefix("(") {
            guard let lhs = value.uptoBalancedBracket else {
                return nil
            }
            let remaining = value[lhs.endIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
            guard
                let operation = remaining.firstWord,
                Set.vhdlBooleanBinaryOperations.contains(operation.lowercased()),
                let startIndex = remaining.startIndex(word: operation)
            else {
                return nil
            }
            let rhs = remaining[remaining.index(startIndex, offsetBy: operation.count)...]
            guard
                let lhsCondition = TransitionCondition(rawValue: String(lhs)),
                let rhsCondition = TransitionCondition(rawValue: String(rhs))
            else {
                return nil
            }
            self.init(lhs: lhsCondition, rhs: rhsCondition, operation: operation)
            return
        }
        guard
            let (startIndex, operation) = Set.vhdlBooleanBinaryOperations.union(["=", "/="])
            .compactMap({ word -> (String.Index, String)? in
                guard let index = value.startIndex(word: word) else {
                    return nil
                }
                return (index, word)
            })
            .min(by: { $0.0 < $1.0 })
        else {
            return nil
        }
        let lhs = value[value.startIndex..<startIndex]
        let rhs = value[value.index(startIndex, offsetBy: operation.count)...]
        guard
            let lhsCondition = TransitionCondition(rawValue: String(lhs)),
            let rhsCondition = TransitionCondition(rawValue: String(rhs))
        else {
            return nil
        }
        self.init(lhs: lhsCondition, rhs: rhsCondition, operation: operation)
    }

    /// Creates a condition when the code can be separated into a operation with two arguments.
    /// - Parameters:
    ///   - lhs: The left-hand side of the `operator`.
    ///   - rhs: The right-hand side of the `operator`.
    ///   - operation: The operation symbol.
    private init?(lhs: TransitionCondition, rhs: TransitionCondition, operation: String) {
        switch operation.lowercased() {
        case "and":
            self = .and(lhs: lhs, rhs: rhs)
        case "or":
            self = .or(lhs: lhs, rhs: rhs)
        case "nand":
            self = .nand(lhs: lhs, rhs: rhs)
        case "nor":
            self = .nor(lhs: lhs, rhs: rhs)
        case "xor":
            self = .xor(lhs: lhs, rhs: rhs)
        case "xnor":
            self = .xnor(lhs: lhs, rhs: rhs)
        case "=":
            self = .equals(lhs: lhs, rhs: rhs)
        case "/=":
            self = .notEquals(lhs: lhs, rhs: rhs)
        default:
            return nil
        }
    }

}
