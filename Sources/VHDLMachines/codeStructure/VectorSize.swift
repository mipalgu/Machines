// VectorSize.swift
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

/// A type for representing VHDL vector sizes. This type is equivalent to the `range` of a VHDL vector type,
/// e.g. *5 downto 3* or *3 to 5*.
public enum VectorSize: RawRepresentable, Equatable, Hashable, Codable {

    /// The `downto` case. This represents the range as an upper limit down to a lower limit.
    case downto(upper: Int, lower: Int)

    /// The `to` case. This represents the range as a lower limit to an upper limit.
    case to(lower: Int, upper: Int)

    /// The raw value is a string.
    public typealias RawValue = String

    @inlinable public var max: Int {
        switch self {
        case .downto(let upper, _):
            return upper
        case .to(_, let upper):
            return upper
        }
    }

    @inlinable public var min: Int {
        switch self {
        case .downto(_, let lower):
            return lower
        case .to(let lower, _):
            return lower
        }
    }

    /// The equivalent VHDL code for this type.
    @inlinable public var rawValue: String {
        switch self {
        case .downto(let upper, let lower):
            return "\(upper) downto \(lower)"
        case .to(let lower, let upper):
            return "\(lower) to \(upper)"
        }
    }

    /// The number of bits in the vector.
    @inlinable public var size: Int {
        switch self {
        case .downto(let upper, let lower):
            return upper - lower + 1
        case .to(let lower, let upper):
            return upper - lower + 1
        }
    }

    /// Initialse the type from a string. This will return `nil` if the string is not a valid VHDL range.
    /// - Parameter rawValue: The value to convert.
    @inlinable
    public init?(rawValue: String) {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedValue.count > 5, trimmedValue.count < 256 else {
            return nil
        }
        let value = trimmedValue.lowercased()
        let hasDownto = value.contains(" downto ")
        let hasTo = value.contains(" to ")
        guard hasDownto != hasTo else {
            return nil
        }
        guard hasDownto else {
            let components = value.components(separatedBy: " to ")
            guard
                let lhs = Int(components.first ?? ""), let rhs = Int(components.last ?? ""), lhs <= rhs
            else {
                return nil
            }
            self = .to(lower: lhs, upper: rhs)
            return
        }
        let components = value.components(separatedBy: " downto ")
        guard let lhs = Int(components.first ?? ""), let rhs = Int(components.last ?? ""), lhs >= rhs else {
            return nil
        }
        self = .downto(upper: lhs, lower: rhs)
        return
    }

}
