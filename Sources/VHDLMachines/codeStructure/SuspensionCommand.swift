// SuspensionCommand.swift
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

/// The suspension command bit representations.
public enum SuspensionCommand: RawRepresentable, CaseIterable, Equatable, Hashable, Codable, Sendable {

    /// Null command.
    case null

    /// Restart a machine.
    case restart

    /// Suspend a machine.
    case suspend

    /// Resume a machine.
    case resume

    /// The raw value is a string.
    public typealias RawValue = String

    /// The binary representations of these commands.
    public static var bitRepresentation: [SuspensionCommand: VectorLiteral]? {
        let all = SuspensionCommand.allCases.sorted { $0.rawValue < $1.rawValue }
        guard let bitsRequired = BitLiteral.bitsRequired(for: all.count - 1) else {
            return nil
        }
        let bits = all.enumerated().map {
            ($1, VectorLiteral.bits(value: BitVector(
                values: BitLiteral.bitVersion(of: $0, bitsRequired: bitsRequired)
            )))
        }
        return Dictionary(uniqueKeysWithValues: bits)
    }

    /// The type of the signal that represents these commands.
    @inlinable public static var bitsType: SignalType? {
        guard let bitsRequired = BitLiteral.bitsRequired(for: SuspensionCommand.allCases.count - 1) else {
            return nil
        }
        return .ranged(type: .stdLogicVector(size: .downto(upper: bitsRequired - 1, lower: 0)))
    }

    public static var suspensionConstants: [ConstantSignal] {
        guard let commands = SuspensionCommand.bitRepresentation, let type = SuspensionCommand.bitsType else {
            fatalError("Failed to create suspension commands.")
        }
        let constants: [ConstantSignal] = commands.sorted { $0.key.rawValue < $1.key.rawValue }.compactMap {
            guard let name = VariableName(rawValue: $0.rawValue) else {
                return nil
            }
            return ConstantSignal(name: name, type: type, value: .literal(value: .vector(value: $1)))
        }
        guard constants.count == commands.count else {
            fatalError("Failed to convert suspension commands to constants.")
        }
        return constants
    }

    /// The VHDL constant labels for these commands.
    @inlinable public var rawValue: String {
        switch self {
        case .null:
            return VariableName.nullCommand.rawValue
        case .restart:
            return VariableName.restartCommand.rawValue
        case .suspend:
            return VariableName.suspendCommand.rawValue
        case .resume:
            return VariableName.resumeCommand.rawValue
        }
    }

    /// Initialise this command from it's label.
    /// - Parameter rawValue: The VHDL label for the command.
    @inlinable
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard
            let maxSize = Self.allCases.map({ $0.rawValue.count }).max(),
            trimmedString.count <= maxSize,
            let command = VariableName(rawValue: trimmedString)
        else {
            return nil
        }
        switch command {
        case .nullCommand:
            self = .null
        case .restartCommand:
            self = .restart
        case .suspendCommand:
            self = .suspend
        case .resumeCommand:
            self = .resume
        default:
            return nil
        }
    }

}
