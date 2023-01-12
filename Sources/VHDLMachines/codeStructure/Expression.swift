// Expression.swift
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

/// An `Expression` represents the RHS of a statement in VHDL.
indirect public enum Expression: RawRepresentable, Equatable, Hashable, Codable {

    /// A reference to a variable.
    case variable(name: String)

    /// An addition operation.
    case addition(lhs: Expression, rhs: Expression)

    /// A subtraction operation.
    case subtraction(lhs: Expression, rhs: Expression)

    /// A multiplication operation.
    case multiplication(lhs: Expression, rhs: Expression)

    /// A division operation.
    case division(lhs: Expression, rhs: Expression)

    /// A precedence operation. This is equivalent to placing brackets around an Expression.
    case precedence(value: Expression)

    /// A comment.
    case comment(comment: String)

    /// An expression with a comment.
    case expressionWithComment(expression: Expression, comment: String)

    /// The raw value is a string.
    public typealias RawValue = String

    /// The equivalent VHDL code of this expression.
    public var rawValue: String {
        switch self {
        case .variable(let name):
            return name
        case .addition(let lhs, let rhs):
            return "\(lhs.rawValue) + \(rhs.rawValue)"
        case .subtraction(let lhs, let rhs):
            return "\(lhs.rawValue) - \(rhs.rawValue)"
        case .multiplication(let lhs, let rhs):
            return "\(lhs.rawValue) * \(rhs.rawValue)"
        case .division(let lhs, let rhs):
            return "\(lhs.rawValue) / \(rhs.rawValue)"
        case .precedence(let value):
            return "(\(value.rawValue))"
        case .comment(let comment):
            return "-- \(comment)"
        case .expressionWithComment(let expression, let comment):
            return "\(expression.rawValue); -- \(comment)"
        }
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity

    /// Create an `Expression` from valid VHDL code.
    /// - Parameter rawValue: The code to convert to this expression.
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        guard !trimmedString.hasPrefix("--") else {
            self = .comment(comment: trimmedString.dropFirst(2).trimmingCharacters(in: .whitespaces))
            return
        }
        guard !trimmedString.contains("--") else {
            let components = trimmedString.components(separatedBy: "--")
            guard components.count >= 2, let expression = Expression(rawValue: components[0]) else {
                return nil
            }
            let comment = components[1...].joined(separator: "--").trimmingCharacters(in: .whitespaces)
            self = .expressionWithComment(expression: expression, comment: comment)
            return
        }
        let value = trimmedString.uptoSemicolon
        let operators = CharacterSet.vhdlOperators
        guard operators.within(string: value) else {
            guard !CharacterSet.whitespacesAndNewlines.within(string: value) else {
                return nil
            }
            self = .variable(name: value)
            return
        }
        if value.hasPrefix("(") && value.hasSuffix(")") {
            guard let expression = Expression(rawValue: String(value.dropFirst().dropLast())) else {
                return nil
            }
            self = .precedence(value: expression)
            return
        }
        if value.hasPrefix("(") {
            guard
                let subExpression = value.subExpressions?.first,
                let expression = Expression(rawValue: String(subExpression.dropFirst().dropLast())),
                let lastSubIndex = subExpression.indices.last
            else {
                return nil
            }
            let rhsStart = value.index(after: lastSubIndex)
            let rhs = value[rhsStart...]
            guard
                let (parts, char) = String(rhs).split(on: .vhdlOperations),
                parts[0].trimmingCharacters(in: .whitespaces).isEmpty,
                let other = parts.last,
                let rhsExp = Expression(rawValue: other)
            else {
                return nil
            }
            self.init(lhs: .precedence(value: expression), rhs: rhsExp, char: char)
            return
        }
        guard let multiplicative = Expression(value: value, characters: .vhdlMultiplicativeOperations) else {
            self.init(value: value, characters: .vhdlAdditiveOperations)
            return
        }
        self = multiplicative
    }

    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    /// Create a binary `Expression` from a string and a set of possible operations.
    /// - Parameters:
    ///   - value: The string containing a binary operation.
    ///   - characters: The valid characters representing the operator of this operation.
    private init?(value: String, characters: CharacterSet) {
        guard
            let (parts, char) = value.split(on: characters),
            let lhs = parts.first,
            let rhs = parts.last,
            let lhsExp = Expression(rawValue: lhs),
            let rhsExp = Expression(rawValue: rhs)
        else {
            return nil
        }
        self.init(lhs: lhsExp, rhs: rhsExp, char: char)
    }

    /// Create a binary `Expression` from a left and right hand side and an operator.
    /// - Parameters:
    ///   - lhs: The left-hand side expression.
    ///   - rhs: The right-hand side expression.
    ///   - char: The operator betweent the lhs and rhs.
    private init?(lhs: Expression, rhs: Expression, char: Character) {
        switch char {
        case "-":
            self = .subtraction(lhs: lhs, rhs: rhs)
        case "+":
            self = .addition(lhs: lhs, rhs: rhs)
        case "*":
            self = .multiplication(lhs: lhs, rhs: rhs)
        case "/":
            self = .division(lhs: lhs, rhs: rhs)
        default:
            return nil
        }
        return
    }

}

/// Add common VHDL character sets.
private extension CharacterSet {

    /// All VHDL operators.
    static var vhdlOperators: CharacterSet {
        CharacterSet(charactersIn: "+-/*()")
    }

    /// The VHDL binary operators.
    static var vhdlOperations: CharacterSet {
        CharacterSet(charactersIn: "+-/*")
    }

    /// The VHDL operators with additive precedence.
    static var vhdlAdditiveOperations: CharacterSet {
        CharacterSet(charactersIn: "+-")
    }

    /// The VHDL operators with multiplicative precedence.
    static var vhdlMultiplicativeOperations: CharacterSet {
        CharacterSet(charactersIn: "*/")
    }

    /// Whether a string contains characters in this character set.
    /// - Parameter string: The string to check.
    /// - Returns: Whether the string contains characters in this character set.
    func within(string: String) -> Bool {
        string.unicodeScalars.contains { self.contains($0) }
    }

}

/// Add helper methods for VHDL parsing.
private extension String {

    /// Find all expressions within self that exist within a set of brackets.
    var subExpressions: [Substring]? {
        var expressions: [Substring] = []
        var openCount = 0
        var openIndex = self.startIndex
        for i in self.indices {
            let c = self[i]
            if c == "(" && openCount == 0 {
                openCount += 1
                openIndex = i
                continue
            }
            if c == "(" {
                openCount += 1
                continue
            }
            if c == ")" && openCount == 0 {
                return nil
            }
            if c == ")" {
                openCount -= 1
                if openCount == 0 {
                    expressions.append(self[openIndex...i])
                }
            }
        }
        guard openCount == 0 else {
            return nil
        }
        return expressions
    }

    /// The string up to the first semicolon.
    var uptoSemicolon: String {
        guard let semicolonIndex = self.firstIndex(where: { $0 == ";" }) else {
            return self
        }
        return String(self[self.startIndex..<semicolonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Split the string into 2 strings. The first string is the string up to the first character in the given
    /// character set.
    /// - Parameter characters: The characters to split on.
    /// - Returns: A tuple containing the 2 halves of the string and the character that was split on.
    func split(on characters: CharacterSet) -> ([String], Character)? {
        guard let firstIndex = self.unicodeScalars.firstIndex(where: { characters.contains($0) }) else {
            return nil
        }
        let char = self[firstIndex]
        let op = String(char)
        let components = self.components(separatedBy: op)
        guard components.count >= 2 else {
            return nil
        }
        return ([components[0], components[1...].joined(separator: op)], char)
    }

}
