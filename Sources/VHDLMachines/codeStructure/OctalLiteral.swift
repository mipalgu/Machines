// OctalLiteral.swift
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

/// Possible octal values for a single octal digit (3 bits).
public enum OctalLiteral: Character, Equatable, Hashable, Codable {

    /// The octal value 0.
    case zero = "0"

    /// The octal value 1.
    case one = "1"

    /// The octal value 2.
    case two = "2"

    /// The octal value 3.
    case three = "3"

    /// The octal value 4.
    case four = "4"

    /// The octal value 5.
    case five = "5"

    /// The octal value 6.
    case six = "6"

    /// The octal value 7.
    case seven = "7"

    /// The equivalent bit vector for this octal digit.
    @inlinable public var bits: [BitLiteral] {
        switch self {
        case .zero:
            return [.low, .low, .low]
        case .one:
            return [.low, .low, .high]
        case .two:
            return [.low, .high, .low]
        case .three:
            return [.low, .high, .high]
        case .four:
            return [.high, .low, .low]
        case .five:
            return [.high, .low, .high]
        case .six:
            return [.high, .high, .low]
        case .seven:
            return [.high, .high, .high]
        }
    }

    /// Creates an octal digit from the given bit vector.
    /// - Parameter bits: The bit vector to convert to an octal digit.
    /// - Note: The bit vector must have exactly 3 bits.
    @inlinable
    public init?(bits: [BitLiteral]) {
        guard bits.count == 3 else {
            return nil
        }
        switch bits {
        case [.low, .low, .low]:
            self = .zero
        case [.low, .low, .high]:
            self = .one
        case [.low, .high, .low]:
            self = .two
        case [.low, .high, .high]:
            self = .three
        case [.high, .low, .low]:
            self = .four
        case [.high, .low, .high]:
            self = .five
        case [.high, .high, .low]:
            self = .six
        case [.high, .high, .high]:
            self = .seven
        default:
            return nil
        }
    }

}
