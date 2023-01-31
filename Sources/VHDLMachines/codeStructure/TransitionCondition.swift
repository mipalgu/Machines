// TransitionCondition.swift
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

import VHDLParsing

public indirect enum TransitionCondition: RawRepresentable, Equatable, Codable, Hashable, Sendable {

    case after(statement: AfterStatement)

    case conditional(condition: ConditionalExpression)

    /// An `and` operation.
    case and(lhs: TransitionCondition, rhs: TransitionCondition)

    /// An `or` operation.
    case or(lhs: TransitionCondition, rhs: TransitionCondition)

    /// A `nand` operation.
    case nand(lhs: TransitionCondition, rhs: TransitionCondition)

    /// A `not` operation.
    case not(value: TransitionCondition)

    /// A `nor` operation.
    case nor(lhs: TransitionCondition, rhs: TransitionCondition)

    /// An `xor` operation.
    case xor(lhs: TransitionCondition, rhs: TransitionCondition)

    /// An `xnor` operation.
    case xnor(lhs: TransitionCondition, rhs: TransitionCondition)

    public var rawValue: String {
        switch self {
        case .after(let statement):
            return statement.rawValue
        case .conditional(let condition):
            return condition.rawValue
        case .and(let lhs, let rhs):
            return "(\(lhs.rawValue) and \(rhs.rawValue))"
        case .or(let lhs, let rhs):
            return "(\(lhs.rawValue) or \(rhs.rawValue))"
        case .nand(let lhs, let rhs):
            return "(\(lhs.rawValue) nand \(rhs.rawValue))"
        case .not(let value):
            return "not \(value.rawValue)"
        case .nor(let lhs, let rhs):
            return "(\(lhs.rawValue) nor \(rhs.rawValue))"
        case .xor(let lhs, let rhs):
            return "(\(lhs.rawValue) xor \(rhs.rawValue))"
        case .xnor(let lhs, let rhs):
            return "(\(lhs.rawValue) xnor \(rhs.rawValue))"
        }
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 1024 else {
            return nil
        }
        if let statement = AfterStatement(rawValue: trimmedString) {
            self = .after(statement: statement)
            return
        }
        if let condition = ConditionalExpression(rawValue: trimmedString) {
            self = .conditional(condition: condition)
            return
        }
        guard trimmedString.lowercased().contains("after") else {
            return nil
        }
        return nil
    }

}
