/*
 * LineAttribute.swift
 * Machines
 *
 * Created by Callum McColl on 31/10/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

import XMI

public enum LineAttribute: Hashable {
    
    case bool(Bool)
    case integer(Int)
    case float(Double)
    case expression(Expression, language: Language)
    case enumerated(String, validValues: Set<String>)
    case line(String)
    
    public var type: LineAttributeType {
        switch self {
        case .bool:
            return .bool
        case .integer:
            return .integer
        case .float:
            return .float
        case .expression(_, let language):
            return .expression(language: language)
        case .enumerated(_, let validValues):
            return .enumerated(validValues: validValues)
        case .line:
            return .line
        }
    }
    
    public var boolValue: Bool? {
        switch self {
        case .bool(let value):
            return value
        default:
            return nil
        }
    }
    
    public var integerValue: Int? {
        switch self {
        case .integer(let value):
            return value
        default:
            return nil
        }
    }
    
    public var floatValue: Double? {
        switch self {
        case .float(let value):
            return value
        default:
            return nil
        }
    }
    
    public var expressionValue: Expression? {
        switch self {
        case .expression(let value, _):
            return value
        default:
            return nil
        }
    }
    
    public var enumeratedValue: (String, validValues: Set<String>)? {
        switch self {
        case .enumerated(let value, validValues: let validValues):
            return (value, validValues)
        default:
            return nil
        }
    }
    
    public var lineValue: String? {
        switch self {
        case .line(let value):
            return value
        default:
            return nil
        }
    }
    
    public init?(type: LineAttributeType, value: String) {
        switch type {
        case .bool:
            guard let value = Bool(value) else {
                return nil
            }
            self = .bool(value)
        case .integer:
            guard let value = Int(value) else {
                return nil
            }
            self = .integer(value)
        case .float:
            guard let value = Double(value) else {
                return nil
            }
            self = .float(value)
        case .expression(let language):
            self = .expression(Expression(value), language: language)
        case .enumerated(let validValues):
            if !validValues.contains(value) {
                return nil
            }
            self = .enumerated(value, validValues: validValues)
        case .line:
            self = .line(value)
        }
    }
    
}

extension LineAttribute: Codable {
    
    public init(from decoder: Decoder) throws {
        if let bool = try? BoolAttribute(from: decoder) {
            self = .bool(bool.value)
            return
        }
        if let integer = try? IntegerAttribute(from: decoder) {
            self = .integer(integer.value)
            return
        }
        if let float = try? FloatAttribute(from: decoder) {
            self = .float(float.value)
            return
        }
        if let expression = try? ExpressionAttribute(from: decoder) {
            self = .expression(expression.value, language: expression.language)
            return
        }
        if let enumerated = try? EnumAttribute(from: decoder) {
            self = .enumerated(enumerated.value, validValues: enumerated.cases)
            return
        }
        if let line = try? LineAttribute(from: decoder) {
            self = .line(line.value)
            return
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported value"
            )
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .bool(let value):
            try BoolAttribute(value).encode(to: encoder)
        case .integer(let value):
            try IntegerAttribute(value).encode(to: encoder)
        case .float(let value):
            try FloatAttribute(value).encode(to: encoder)
        case .expression(let value, let language):
            try ExpressionAttribute(value: value, language: language).encode(to: encoder)
        case .enumerated(let value, let cases):
            try EnumAttribute(cases: cases, value: value).encode(to: encoder)
        case .line(let value):
            try LineAttribute(value).encode(to: encoder)
        }
    }
    
    private struct BoolAttribute: Hashable, Codable {
        
        var value: Bool
        
        init(_ value: Bool) {
            self.value = value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Bool.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
        
    }
    
    private struct IntegerAttribute: Hashable, Codable {
        
        var value: Int
        
        init(_ value: Int) {
            self.value = value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Int.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
        
    }
    
    private struct FloatAttribute: Hashable, Codable {
        
        var value: Double
        
        init(_ value: Double) {
            self.value = value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Double.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
        
    }
    
    private struct ExpressionAttribute: Hashable, Codable {
        
        var value: Expression
        
        var language: Language
        
    }
    
    private struct EnumAttribute: Hashable, Codable {
        
        var cases: Set<String>
        
        var value: String
        
    }
    
    private struct LineAttribute: Hashable, Codable {
        
        var value: String
        
        init(_ value: String) {
            self.value = value
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(String.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.value)
        }
        
    }
    
}

extension LineAttribute: XMIConvertible {
    
    public var xmiName: String? {
        switch self {
        case .bool:
            return "BoolAttribute"
        case .integer:
            return "IntegerAttribute"
        case .float:
            return "FloatAttribute"
        case .enumerated:
            return "EnumeratedAttribute"
        case .expression:
            return "ExpressionAttribute"
        case .line:
            return "LineAttribute"
        }
    }
    
}
