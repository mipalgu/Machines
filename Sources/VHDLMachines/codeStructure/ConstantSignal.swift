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

/// A type representing a valid constant declaration in `VHDL`.
public struct ConstantSignal: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    /// The rawValue is a string.
    public typealias RawValue = String

    /// The name of the constant.
    public let name: VariableName

    /// The type of the constant.
    public let type: SignalType

    /// The value of this constant.
    public let value: Expression

    /// The comment associated with this constant.
    public let comment: Comment?

    /// The `VHDL` code defining this constant.
    @inlinable public var rawValue: String {
        let declaration = "constant \(name): \(type.rawValue) := \(value.rawValue);"
        guard let comment = comment else {
            return declaration
        }
        return declaration + " \(comment)"
    }

    /// Initialise this constant with the given name, type, value and comment.
    /// - Parameters:
    ///   - name: The name of the constant.
    ///   - type: The type of the constant.
    ///   - value: The value of the constant.
    ///   - comment: The comment associated with this constant.
    /// - Note: This initialiser will verify that the value is valid for the type of this constant.
    @inlinable
    public init?(name: VariableName, type: SignalType, value: Expression, comment: Comment? = nil) {
        if case Expression.literal(let literal) = value {
            guard literal.isValid(for: type) else {
                return nil
            }
        }
        self.name = name
        self.type = type
        self.value = value
        self.comment = comment
    }

    // swiftlint:disable function_body_length

    /// Initialise this constant from the `VHDL` code that defines it.
    /// - Parameter rawValue: The `VHDL` code defining this constant. This code should include the entire
    /// declaration of the constant, including the `constant` keyword, the name, the type, the value,
    /// semicolon and optionally the comment after the semicolon.
    @inlinable
    public init?(rawValue: String) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.hasPrefix("constant ") else {
            return nil
        }
        let components = trimmedValue.components(separatedBy: ";")
        guard
            components.count == 2, let declaration = components.first, let commentString = components.last
        else {
            return nil
        }
        let comment = Comment(rawValue: commentString)
        let declComponents = declaration.components(separatedBy: ":=")
        guard
            declComponents.count == 2,
            let valueString = declComponents.last,
            let value = Expression(rawValue: valueString),
            let declaration = declComponents.first?.trimmingCharacters(in: .whitespaces)
        else {
            return nil
        }
        let signalComponents = declaration.components(separatedBy: .whitespacesAndNewlines)
        guard signalComponents.count >= 2 else {
            return nil
        }
        let hasColonSuffix = signalComponents[1].hasSuffix(":")
        let colonComponents = signalComponents.filter { $0.contains(":") }
        guard
            signalComponents.count >= 3,
            hasColonSuffix || signalComponents[2] == ":",
            colonComponents.count == 1,
            colonComponents[0].filter({ $0 == ":" }).count == 1
        else {
            return nil
        }
        let typeIndex = hasColonSuffix ? 2 : 3
        guard
            signalComponents.first == "constant",
            signalComponents.count >= typeIndex,
            let type = SignalType(rawValue: signalComponents[typeIndex...].joined(separator: " "))
        else {
            return nil
        }
        let name = hasColonSuffix ? String(signalComponents[1].dropLast()) : signalComponents[1]
        guard
            !name.isEmpty,
            !CharacterSet.whitespacesAndNewlines.within(string: name),
            let varName = VariableName(rawValue: name)
        else {
            return nil
        }
        if case Expression.literal(let literal) = value {
            guard literal.isValid(for: type) else {
                return nil
            }
        }
        self.name = varName
        self.type = type
        self.value = value
        self.comment = comment
    }

    // swiftlint:enable function_body_length

    /// Create the constant declaration for the state actions within a machine.
    /// - Parameter actions: The actions to convert.
    /// - Returns: The constant declaration for the state actions.
    /// - Note: This method also includes the reserved actions `NoOnEntry`, `CheckTransition`, `ReadSnapshot`
    /// and `WriteSnapshot`.
    public static func constants(for actions: [ActionName: String]) -> [ConstantSignal]? {
        let keys = actions.keys
        let actionNamesArray = [
            "NoOnEntry", "CheckTransition", "ReadSnapshot", "WriteSnapshot"
        ].map { ActionName(text: $0) }
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
                value: .literal(value: .vector(value: .bits(value: bitRepresentations[$0])))
            )
        }
        guard signals.count == actionNames.count else {
            return nil
        }
        return signals
    }

}
