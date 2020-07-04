/*
 * VariableHelpers.swift 
 * Sources 
 *
 * Created by Callum McColl on 21/04/2017.
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

public final class VariableHelpers {

    public init() {}

    public func isComplex(variable: Variable) -> Bool {
        let type = variable.type.trimmingCharacters(in: .whitespacesAndNewlines)
        if type.last == "?" || type.last == "!" {
            return false
        }
        switch type {
            case "Bool",
                 "Int8", "Int16", "Int32", "Int64", "Int",
                 "UInt8", "UInt16", "UInt32", "UInt64", "UInt",
                 "Float80", "Float", "Double",
                 "String", "Void":
                return false
            default:
                return true
        }
    }

    public func makeAssignment(withLabel label: String, andValue value: String) -> String {
        return "\(label) = \(value)"
    }

    public func makeDeclaration(forVariable variable: Variable, allowModifications: Bool = false) -> String {
        let trimmed = variable.type.trimmingCharacters(in: .whitespacesAndNewlines)
        let type: String
        if let last = trimmed.last {
            if nil != variable.initialValue {
                type = trimmed
            } else {
                type = last == "?" || last == "!" ? trimmed : trimmed + "!"
            }
            
        } else {
            type = "Void!"
        }
        let constantDeclaration = allowModifications ? "private(set) var" : "let"
        let declaration = variable.accessType == .writeOnly ? "@Sink var" : "var"
        return "\(variable.accessType == .readOnly ? constantDeclaration : declaration) \(variable.label): \(type)"
    } 

    public func makeDeclarationAndAssignment(forVariable variable: Variable, _ defaultValue: ((Variable) -> String)? = nil) -> String {
        let declaration = self.makeDeclaration(forVariable: variable)
        if let defaultFunc = defaultValue {
            return declaration + " = " + defaultFunc(variable)
        }
        guard let initialValue = variable.initialValue else {
            return declaration + " = nil"
        }
        return declaration + " = " + initialValue
    }
    
    public func makeDeclarationWithAvailableAssignment(forVariable variable: Variable, _ defaultValue: ((Variable) -> String)? = nil) -> String {
        let declaration = variable.accessType.rawValue + " " + variable.label + ": " + variable.type
        if let defaultFunc = defaultValue {
            return declaration + " = " + defaultFunc(variable)
        }
        if let initialValue = variable.initialValue {
            return declaration + " = " + initialValue
        }
        return declaration
    }

}
