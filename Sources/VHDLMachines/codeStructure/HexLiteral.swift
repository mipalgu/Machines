// HexLiteral.swift
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

/// All of the possible values for a single hexadecimal digit (4 bits).
public enum HexLiteral: Character, Equatable, Hashable, Codable, Sendable {

    /// The value 0.
    case zero = "0"

    /// The value 1.
    case one = "1"

    /// The value 2.
    case two = "2"

    /// The value 3.
    case three = "3"

    /// The value 4.
    case four = "4"

    /// The value 5.
    case five = "5"

    /// The value 6.
    case six = "6"

    /// The value 7.
    case seven = "7"

    /// The value 8.
    case eight = "8"

    /// The value 9.
    case nine = "9"

    /// The value 10.
    case ten = "A"

    /// The value 11.
    case eleven = "B"

    /// The value 12.
    case twelve = "C"

    /// The value 13.
    case thirteen = "D"

    /// The value 14.
    case fourteen = "E"

    /// The value 15.
    case fifteen = "F"

    /// The equivalent bit vector for this hex digit.
    @inlinable public var bits: [BitLiteral] {
        switch self {
        case .zero:
            return [.low, .low, .low, .low]
        case .one:
            return [.low, .low, .low, .high]
        case .two:
            return [.low, .low, .high, .low]
        case .three:
            return [.low, .low, .high, .high]
        case .four:
            return [.low, .high, .low, .low]
        case .five:
            return [.low, .high, .low, .high]
        case .six:
            return [.low, .high, .high, .low]
        case .seven:
            return [.low, .high, .high, .high]
        case .eight:
            return [.high, .low, .low, .low]
        case .nine:
            return [.high, .low, .low, .high]
        case .ten:
            return [.high, .low, .high, .low]
        case .eleven:
            return [.high, .low, .high, .high]
        case .twelve:
            return [.high, .high, .low, .low]
        case .thirteen:
            return [.high, .high, .low, .high]
        case .fourteen:
            return [.high, .high, .high, .low]
        case .fifteen:
            return [.high, .high, .high, .high]
        }
    }

    /// Initialise a `HexLiteral` from a `Character`.
    /// - Parameter rawValue: The character equivalent of the hex digit. Lowercased and uppercased characters
    /// can be used in this initialiser.
    @inlinable
    public init?(rawValue: Character) {
        switch rawValue.uppercased() {
        case "0":
            self = .zero
        case "1":
            self = .one
        case "2":
            self = .two
        case "3":
            self = .three
        case "4":
            self = .four
        case "5":
            self = .five
        case "6":
            self = .six
        case "7":
            self = .seven
        case "8":
            self = .eight
        case "9":
            self = .nine
        case "A":
            self = .ten
        case "B":
            self = .eleven
        case "C":
            self = .twelve
        case "D":
            self = .thirteen
        case "E":
            self = .fourteen
        case "F":
            self = .fifteen
        default:
            return nil
        }
    }

    /// Create the hex digit from a bit vector.
    /// - Parameter bits: The bits to convert to this hex digit.
    /// - Note: The bits vector must be exactly 4 bits long.
    @inlinable
    public init?(bits: [BitLiteral]) {
        guard bits.count == 4 else {
            return nil
        }
        switch bits {
        case [.low, .low, .low, .low]:
            self = .zero
        case [.low, .low, .low, .high]:
            self = .one
        case [.low, .low, .high, .low]:
            self = .two
        case [.low, .low, .high, .high]:
            self = .three
        case [.low, .high, .low, .low]:
            self = .four
        case [.low, .high, .low, .high]:
            self = .five
        case [.low, .high, .high, .low]:
            self = .six
        case [.low, .high, .high, .high]:
            self = .seven
        case [.high, .low, .low, .low]:
            self = .eight
        case [.high, .low, .low, .high]:
            self = .nine
        case [.high, .low, .high, .low]:
            self = .ten
        case [.high, .low, .high, .high]:
            self = .eleven
        case [.high, .high, .low, .low]:
            self = .twelve
        case [.high, .high, .low, .high]:
            self = .thirteen
        case [.high, .high, .high, .low]:
            self = .fourteen
        case [.high, .high, .high, .high]:
            self = .fifteen
        default:
            return nil
        }
    }

}
