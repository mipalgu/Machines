// SignalValue.swift
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

/// A type for representing all signal literals.
public enum SignalLiteral: RawRepresentable, Equatable, Hashable, Codable {

    /// A single-bit logic literal.
    case logic(value: BitLiteral)

    /// A vector of logic literals.
    case vector(value: VectorLiteral)

    /// The raw value of the signal literal is a string.
    public typealias RawValue = String

    /// The VHDL equivalent code.
    public var rawValue: String {
        switch self {
        case .logic(let value):
            return value.rawValue
        case .vector(let value):
            return value.rawValue
        }
    }

    /// Creates a signal literal from a VHDL representation.
    /// - Parameter rawValue: The VHDL code equivalent to this literal.
    public init?(rawValue: String) {
        if let val = BitLiteral(rawValue: rawValue) {
            self = .logic(value: val)
            return
        }
        if let val = VectorLiteral(rawValue: rawValue) {
            self = .vector(value: val)
            return
        }
        return nil
    }

    /// Creates the default signal literal for a given signal type.
    /// - Parameter type: The type to create the literal for.
    /// - Returns: The default literal for the given type.
    public static func `default`(for type: SignalType) -> SignalLiteral {
        switch type {
        case .stdLogic:
            return .logic(value: .low)
        case .stdLogicVector(let size):
            return .vector(value: .bits(value: [BitLiteral](repeating: .low, count: size.size)))
        }
    }

}