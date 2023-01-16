// Statement.swift
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

public enum Statement: RawRepresentable, Equatable, Hashable, Codable, Sendable {

    case constant(value: ConstantSignal)

    case definition(signal: LocalSignal)

    case assignment(name: VariableName, value: Expression)

    case expression(value: Expression)

    case externalDefinition(value: PortSignal)

    public typealias RawValue = String

    @inlinable public var rawValue: String {
        switch self {
        case .constant(let value):
            return value.rawValue
        case .definition(let signal):
            return signal.rawValue
        case .assignment(let name, let value):
            return "\(name) := \(value.rawValue)"
        case .expression(let value):
            return value.rawValue
        case .externalDefinition(let value):
            return value.rawValue
        }
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        let value = trimmedString.lowercased()
        guard !value.contains("<=") else {
            let components = value.components(separatedBy: "<=")
            guard
                components.count == 2,
                let name = VariableName(rawValue: components[0]),
                let exp = Expression(rawValue: components[1].trimmingCharacters(in: .whitespacesAndNewlines))
            else {
                return nil
            }
            self = .assignment(name: name, value: exp)
            return
        }
        guard !value.contains("constant ") else {
            guard let constant = ConstantSignal(rawValue: value) else {
                return nil
            }
            self = .constant(value: constant)
            return
        }
        guard !value.contains("signal ") else {
            guard let signal = LocalSignal(rawValue: value) else {
                return nil
            }
            self = .definition(signal: signal)
            return
        }
        let modes = Set(Mode.allCases.map(\.rawValue))
        guard
            !value.components(separatedBy: .whitespacesAndNewlines).contains(where: { modes.contains($0) })
        else {
            guard let external = PortSignal(rawValue: value) else {
                return nil
            }
            self = .externalDefinition(value: external)
            return
        }
        if let exp = Expression(rawValue: value) {
            self = .expression(value: exp)
            return
        }
        return nil
    }

    public static func readSnapshots(machine: Machine) -> [Statement] {
        machine.externalSignals.map {
            .assignment(name: $0.name, value: .variable(name: .name(for: $0)))
        }
    }

}
