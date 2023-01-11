// RangedType.swift
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

/// *VHDL* types that are bounded within a specific range.
public enum RangedType: RawRepresentable, Equatable, Hashable, Codable {

    /// Integer type (`integer`).
    case integer(size: VectorSize)

    /// Signed type (`signed`).
    case signed(size: VectorSize)

    /// Standard logic vector (`std_logic_vector`).
    case stdLogicVector(size: VectorSize)

    /// Standard unresolved logic vector (`std_ulogic_vector`).
    case stdULogicVector(size: VectorSize)

    /// Unsigned type (`unsigned`).
    case unsigned(size: VectorSize)

    /// The raw value is a `String`.
    public typealias RawValue = String

    /// The equivalent VHDL code for this type.
    @inlinable public var rawValue: String {
        switch self {
        case .integer(let size):
            return "integer range \(size.rawValue)"
        case .signed(let size):
            return "signed(\(size.rawValue))"
        case .stdLogicVector(let size):
            return "std_logic_vector(\(size.rawValue))"
        case .stdULogicVector(let size):
            return "std_ulogic_vector(\(size.rawValue))"
        case .unsigned(let size):
            return "unsigned(\(size.rawValue))"
        }
    }

    /// Initialise this ranged type from its VHDL representation.
    /// - Parameter rawValue: The VHDL code that defines this type.
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        guard trimmedString.count >= 9 else {
            return nil
        }
        let value = trimmedString.lowercased()
        if let size = VectorSize(vector: value, vectorType: "signed") {
            self = .signed(size: size)
            return
        }
        if let size = VectorSize(vector: value, vectorType: "std_logic_vector") {
            self = .stdLogicVector(size: size)
            return
        }
        if let size = VectorSize(vector: value, vectorType: "std_ulogic_vector") {
            self = .stdULogicVector(size: size)
            return
        }
        if let size = VectorSize(vector: value, vectorType: "unsigned") {
            self = .unsigned(size: size)
            return
        }
        if let size = VectorSize(raw: value, integerType: "integer") {
            self = .integer(size: size)
            return
        }
        return nil
    }

}

/// Add conversion inits.
private extension VectorSize {

    /// Initialise from a vector string.
    init?(vector: String, vectorType: String) {
        let primitiveSize = vectorType.count
        guard vector.count > primitiveSize else {
            return nil
        }
        let firstChars = vector[
            String.Index(utf16Offset: 0, in: vector)...String.Index(utf16Offset: primitiveSize, in: vector)
        ]
        let vectorString = "\(vectorType)("
        guard firstChars == vectorString else {
            return nil
        }
        let other = vector.dropFirst(primitiveSize + 1).dropLast()
        guard let size = VectorSize(rawValue: String(other)) else {
            return nil
        }
        self = size
    }

    /// Initialise the vector size from a raw string containing the VHDL code for a ranged integer.
    /// - Parameters:
    ///   - raw: The VHDL code to extract the range from.
    ///   - integerType: The type of the integer in the code.
    init?(raw: String, integerType: String) {
        let words = raw.components(separatedBy: .whitespacesAndNewlines)
        guard words.count > 2, words[0] == "integer", words[1] == "range" else {
            return nil
        }
        let range = words.dropFirst(2).joined(separator: " ")
        self.init(rawValue: range)
    }

}
