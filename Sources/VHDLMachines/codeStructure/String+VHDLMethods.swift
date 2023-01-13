// String+indent.swift
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

/// Add helper methods for VHDL parsing.
extension String {

    var tab: String {
        "    "
    }

    func indent(amount: Int) -> String {
        let indentAmount = String(repeating: tab, count: amount)
        return self.components(separatedBy: .newlines).map { indentAmount + $0 }.joined(separator: "\n")
    }

    mutating func removeLast(character: Character) {
        guard let lastIndex = self.lastIndex(of: character) else {
            return
        }
        _ = self.remove(at: lastIndex)
    }

    /// Find all expressions within self that exist within a set of brackets.
    @usableFromInline var subExpressions: [Substring]? {
        var expressions: [Substring] = []
        var openCount = 0
        var openIndex = self.startIndex
        for i in self.indices {
            let c = self[i]
            if c == "(" && openCount == 0 {
                openCount += 1
                openIndex = i
                continue
            }
            if c == "(" {
                openCount += 1
                continue
            }
            if c == ")" && openCount == 0 {
                return nil
            }
            if c == ")" {
                openCount -= 1
                if openCount == 0 {
                    expressions.append(self[openIndex...i])
                }
            }
        }
        guard openCount == 0 else {
            return nil
        }
        return expressions
    }

    /// The string up to the first semicolon.
    @usableFromInline var uptoSemicolon: String {
        guard let semicolonIndex = self.firstIndex(where: { $0 == ";" }) else {
            return self
        }
        return String(self[self.startIndex..<semicolonIndex]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Split the string into 2 strings. The first string is the string up to the first character in the given
    /// character set.
    /// - Parameter characters: The characters to split on.
    /// - Returns: A tuple containing the 2 halves of the string and the character that was split on.
    @usableFromInline
    func split(on characters: CharacterSet) -> ([String], Character)? {
        guard let firstIndex = self.unicodeScalars.firstIndex(where: { characters.contains($0) }) else {
            return nil
        }
        let char = self[firstIndex]
        let op = String(char)
        let components = self.components(separatedBy: op)
        guard components.count >= 2 else {
            return nil
        }
        return ([components[0], components[1...].joined(separator: op)], char)
    }

}
