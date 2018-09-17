/*
 * VarParser.swift 
 * Sources 
 *
 * Created by Callum McColl on 02/04/2017.
 * Copyright © 2017 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Foundation

public final class VarParser {

    public init() {}

    func parse(fromString str: String) -> [Variable]? {
        let lines = str.components(separatedBy: CharacterSet.newlines)
        let statements = lines.lazy.flatMap { $0.components(separatedBy: ";") }
        let trimmedStatements = statements.map { $0.trimmingCharacters(in: .whitespaces) }
        let words = trimmedStatements.map { $0.components(separatedBy: CharacterSet.whitespaces) }
        let tokens = words.map { $0.lazy.flatMap { $0.components(separatedBy: ":") } }
        let trimmedTokens = tokens.flatMap { (tokens) -> [String]? in
            let tokens = Array(tokens.flatMap { (token: String) -> String? in
                let trimmed = token.trimmingCharacters(in: .whitespaces)
                if true == trimmed.isEmpty {
                    return nil
                }
                return trimmed
            })
            if true == tokens.isEmpty {
                return nil
            }
            return tokens
        }
        return trimmedTokens.failMap { tokens in
            if tokens.count < 3 {
                return nil
            }
            if (tokens[0] != "let" && tokens[0] != "var" ) {
                return nil
            }
            let constant = tokens[0] == "let"
            let label = tokens[1]
            if let index = tokens.index(of: "=") {
                if (index <= 2 || index + 1 >= tokens.count) {
                    return nil
                }
                return Variable(
                    constant: constant,
                    label: label,
                    type: tokens.dropFirst().dropFirst().prefix(index - 2).reduce("") { $0 + $1 + " " }.trimmingCharacters(in: .whitespaces),
                    initialValue: tokens.suffix(from: index + 1).reduce("") { $0 + $1 + " " }.trimmingCharacters(in: .whitespaces)
                )
            }
            return Variable(
                constant: constant,
                label: label,
                type: tokens.suffix(1).reduce("") { $0 + $1 + " " }.trimmingCharacters(in: .whitespaces),
                initialValue: nil
            )
        }
    }

}
