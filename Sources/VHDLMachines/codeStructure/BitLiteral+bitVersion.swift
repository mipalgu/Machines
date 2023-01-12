// BitLiteral+bitVersion.swift
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

extension BitLiteral {

    /// Helper function for `bitVersion(of:bitsRequired:)`. This function recurses on itself to produce the
    /// binary representation.
    /// - Parameters:
    ///   - value: The positive number to convert to a binary representation.
    ///   - carry: The current representation recursing on itself.
    ///   - bitPlace: The current index of the array.
    /// - Returns: The binary representation.
    private static func performBitVersion(
        of value: Double, carry: [BitLiteral] = [], bitPlace: Int
    ) -> [BitLiteral] {
        if bitPlace < 0 {
            return carry
        }
        if value.isZero {
            return carry + [BitLiteral](repeating: .low, count: bitPlace + 1)
        }
        let bitValue = exp2(Double(bitPlace))
        if bitValue > value {
            return performBitVersion(of: value, carry: carry + [.low], bitPlace: bitPlace - 1)
        }
        return performBitVersion(of: value - bitValue, carry: carry + [.high], bitPlace: bitPlace - 1)
    }

    /// Represent a positive number as an array of bits. This representation is standard binary notation with
    /// the largest bit at index 0 in the array.
    /// - Parameters:
    ///   - value: The number to convert to a binary representation.
    ///   - bitsRequired: The bit size of the number.
    /// - Returns: The binary representation of the number or an empty array if the number cannot be
    /// converted.
    /// - Note: Please make sure the `bitsRequired` is at least as large as the minimum number of bits
    /// required to represent the number.
    static func bitVersion(of value: Int, bitsRequired: Int) -> [BitLiteral] {
        if value == 0 && bitsRequired > 0 {
            return [BitLiteral](repeating: .low, count: bitsRequired)
        }
        guard
            value > 0,
            bitsRequired > 0,
            let minBits = self.bitsRequired(for: value),
            bitsRequired >= minBits
        else {
            return []
        }
        return performBitVersion(of: Double(value), bitPlace: bitsRequired - 1)
    }

    /// Calculate the bits required to represents a positive value as a binary number.
    /// - Parameter value: The positive number to represent.
    /// - Returns: Nil if the value is negative or zero, otherwise the number of bits required to represent
    /// the value.
    static func bitsRequired(for value: Int) -> Int? {
        guard value > 0 else {
            return nil
        }
        let result = floor(log2(Double(value))) + 1.0
        return Int(result)
    }

}
