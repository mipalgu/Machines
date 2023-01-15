// VariableName.swift
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

/// Valid VHDL variable names. This struct represents a valid VHDL variable name. It is impossible to create
/// an invalid name using the public interface of this struct.
public struct VariableName: RawRepresentable,
    CustomStringConvertible, Equatable, Hashable, Codable, Sendable, Comparable {

    public static let clockPeriod = VariableName(text: "clockPeriod")

    public static let ringletLength = VariableName(text: "ringletLength")

    public static let ringletPerPs = VariableName(text: "RINGLETS_PER_PS")

    public static let ringletPerNs = VariableName(text: "RINGLETS_PER_NS")

    public static let ringletPerUs = VariableName(text: "RINGLETS_PER_US")

    public static let ringletPerMs = VariableName(text: "RINGLETS_PER_MS")

    public static let ringletPerS = VariableName(text: "RINGLETS_PER_S")

    public static let ringletCounter = VariableName(text: "ringletCounter")

    public static let suspended = VariableName(text: "suspended")

    public static let command = VariableName(text: "command")

    public static let currentState = VariableName(text: "currentState")

    public static let targetState = VariableName(text: "targetState")

    public static let previousRinglet = VariableName(text: "previousRinglet")

    public static let suspendedFrom = VariableName(text: "suspendedFrom")

    public static let internalState = VariableName(text: "internalState")

    public static let readSnapshot = VariableName(text: ReservedAction.readSnapshot.rawValue)

    public static let writeSnapshot = VariableName(text: ReservedAction.writeSnapshot.rawValue)

    public static let checkTransition = VariableName(text: ReservedAction.checkTransition.rawValue)

    public static let noOnEntry = VariableName(text: ReservedAction.noOnEntry.rawValue)

    public static let onEntry = VariableName(text: "OnEntry")

    public static let onExit = VariableName(text: "OnExit")

    public static let onResume = VariableName(text: "OnResume")

    public static let onSuspend = VariableName(text: "OnSuspend")

    public static let `internal` = VariableName(text: "Internal")

    /// The variable name.
    public let rawValue: String

    /// The description is the same as the raw value.
    @inlinable public var description: String {
        rawValue
    }

    /// Initialise this type with a valid VHDL variable name.
    /// - Parameter text: The verified VHDL variable name.
    /// - Warning: This initialiser does not verify that the name is valid. It is only intended to be used
    /// internally. Use the public initialiser instead.
    @usableFromInline
    init(text: String) {
        self.rawValue = text
    }

    /// Initialise this type with a valid VHDL variable name.
    /// - Parameter rawValue: The name of the variable.
    /// - Note: This initialiser will verify that the `rawValue` is valid, and will return nil if this is not
    /// the case.
    @inlinable
    public init?(rawValue: String) {
        let trimmedName = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowedChars = CharacterSet.variableNames
        guard
            trimmedName.count < 256,
            let firstChar = trimmedName.unicodeScalars.first,
            CharacterSet.letters.contains(firstChar),
            rawValue.unicodeScalars.allSatisfy({ allowedChars.contains($0) }),
            !Set<String>.vhdlAllReservedWords.contains(rawValue)
        else {
            return nil
        }
        self.rawValue = trimmedName
    }

    /// Comparison operator. Comparison of variable names is irrespective of case.
    @inlinable
    public static func < (lhs: VariableName, rhs: VariableName) -> Bool {
        lhs.rawValue.lowercased() < rhs.rawValue.lowercased()
    }

    /// Equality operation. Equality of variable names is irrespective of case.
    @inlinable
    public static func == (lhs: VariableName, rhs: VariableName) -> Bool {
        lhs.rawValue.lowercased() == rhs.rawValue.lowercased()
    }

    /// Hashable operation. Hashing of variable names is irrespective of case.
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.rawValue.lowercased())
    }

    public static func name(for state: State) -> VariableName {
        VariableName(text: "STATE_\(state.name.rawValue)")
    }

    public static func name(for external: ExternalSignal) -> VariableName {
        VariableName(text: "EXTERNAL_\(external.name.rawValue)")
    }

    public static func name(for parameter: Parameter) -> VariableName {
        VariableName(text: "PARAMETER_\(parameter.name.rawValue)")
    }

    public static func name(for returnable: ReturnableVariable) -> VariableName {
        VariableName(text: "OUTPUT_\(returnable.name.rawValue)")
    }

}
