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

public struct ConstantSignal: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    public let name: String

    public let type: SignalType

    public let value: SignalLiteral

    public typealias RawValue = String

    public var rawValue: String {
        "constant \(name): \(type.rawValue) := \(value.rawValue);"
    }

    public init?(name: String, type: SignalType, value: SignalLiteral) {
        guard value.isValid(for: type) else {
            return nil
        }
        self.name = name
        self.type = type
        self.value = value
    }

    public init?(rawValue: String) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.hasPrefix("constant ") else {
            return nil
        }
        let components = trimmedValue.components(separatedBy: ":=")
        guard components.count == 2 else {
            return nil
        }
        let value = components[1]
        guard value.hasSuffix(";"), let literal = SignalLiteral(rawValue: String(value.dropLast())) else {
            return nil
        }
        let nameAndType = components[0].components(separatedBy: ":").map {
            $0.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        guard
            nameAndType.count == 2,
            let lastComponent = nameAndType.last,
            let type = SignalType(rawValue: lastComponent)
        else {
            return nil
        }
        self.name = nameAndType[0].dropFirst("constant ".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        self.type = type
        self.value = literal
    }

    public static func constants(for actions: [ActionName: String]) -> [ConstantSignal]? {
        let actionNames = actions.keys.sorted()
        guard let bitsRequired = BitLiteral.bitsRequired(for: actionNames.count) else {
            return nil
        }
        let bitRepresentations = actionNames.indices.map {
            BitLiteral.bitVersion(of: $0, bitsRequired: bitsRequired)
        }
        let type = SignalType.ranged(type: .stdLogicVector(size: .downto(upper: bitsRequired - 1, lower: 0)))
        let signals = actionNames.indices.compactMap {
            ConstantSignal(
                name: actionNames[$0],
                type: type,
                value: SignalLiteral.vector(value: .bits(value: bitRepresentations[$0]))
            )
        }
        guard signals.count == actionNames.count else {
            return nil
        }
        return signals
    }

}
