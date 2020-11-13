/*
 * BlockAttribute.swift
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
import swift_helpers

public enum BlockAttribute: Hashable {
    
    case code(_ value: String, language: Language)
    
    case text(_ value: String)
    
    indirect case collection(_ values: [Attribute], type: AttributeType)
    
    indirect case complex(_ data: [String: Attribute], layout: [Field])
    
    case enumerableCollection(_ values: Set<String>, validValues: Set<String>)
    
    case table([[LineAttribute]], columns: [BlockAttributeType.TableColumn])
    
    public var type: BlockAttributeType {
        switch self {
        case .code(_, let language):
            return .code(language: language)
        case .text:
            return .text
        case .collection(_, let type):
            return .collection(type: type)
        case .complex(_, let layout):
            return .complex(layout: layout)
        case .enumerableCollection(_, let validValues):
            return .enumerableCollection(validValues: validValues)
        case .table(_, columns: let columns):
            return .table(columns: columns)
        }
    }
    
    public var codeValue: String? {
        switch self {
        case .code(let value, _):
            return value
        default:
            return nil
        }
    }
    
    public var textValue: String? {
        switch self {
        case .text(let value):
            return value
        default:
            return nil
        }
    }
    
    public var collectionValue: [Attribute]? {
        switch self {
        case .collection(let value, _):
            return value
        default:
            return nil
        }
    }
    
    public var complexValue: [String: Attribute]? {
        switch self {
        case .complex(let values, _):
            return values
        default:
            return nil
        }
    }
    
    public var enumerableCollectionValue: Set<String>? {
        switch self {
        case .enumerableCollection(let values, _):
            return values
        default:
            return nil
        }
    }
    
    public var tableValue: [[LineAttribute]]? {
        switch self {
        case .table(let values, _):
            return values
        default:
            return nil
        }
    }
    
    public var collectionBools: [Bool]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .bool:
                return values.failMap { $0.boolValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionIntegers: [Int]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .integer:
                return values.failMap { $0.integerValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionFloats: [Double]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .float:
                return values.failMap { $0.floatValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionExpressions: [Expression]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .line(.expression):
                return values.failMap { $0.expressionValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionEnumerated: [String]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .line(.enumerated):
                guard let values: [String] = values.failMap({
                    guard let elementValue = $0.enumeratedValue else {
                        return nil
                    }
                    return elementValue
                }) else {
                    return nil
                }
                return values
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionLines: [String]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .line:
                return values.failMap { $0.lineValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionCode: [String]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .block(.code):
                return values.failMap { $0.codeValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionText: [String]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .text:
                return values.failMap { $0.textValue }
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionComplex: [[String: Attribute]]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .block(.complex):
                guard let values: [[String: Attribute]] = values.failMap({
                    guard let elementValues = $0.complexValue else {
                        return nil
                    }
                    return elementValues
                }) else {
                    return nil
                }
                return values
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionEnumerableCollection: [Set<String>]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .block(.enumerableCollection):
                guard let values: [Set<String>] = values.failMap({
                    guard let elementValues = $0.enumerableCollectionValue else {
                        return nil
                    }
                    return elementValues
                }) else {
                    return nil
                }
                return values
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
    public var collectionTable: [[[LineAttribute]]]? {
        switch self {
        case .collection(let values, type: let type):
            switch type {
            case .block(.table):
                guard let values: [[[LineAttribute]]] = values.failMap({
                    return $0.tableValue
                }) else {
                    return nil
                }
                return values
            default:
                return nil
            }
        default:
            return nil
        }
    }
    
}

extension BlockAttribute: Codable {
    
    public enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    public init(from decoder: Decoder) throws {
        if let code = try? CodeAttribute(from: decoder) {
            self = .code(code.value, language: code.language)
            return
        }
        if let text = try? TextAttribute(from: decoder) {
            self = .text(text.value)
            return
        }
        if let collection = try? CollectionAttribute(from: decoder) {
            self = .collection(collection.values, type: collection.type)
        }
        if let complex = try? ComplexAttribute(from: decoder) {
            self = .complex(complex.values, layout: complex.layout)
        }
        if let enumCollection = try? EnumCollectionAttribute(from: decoder) {
            self = .enumerableCollection(enumCollection.values, validValues: enumCollection.cases)
        }
        if let table = try? TableAttribute(from: decoder) {
            self = .table(table.rows, columns: table.columns)
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported Value"
            )
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .code(let value, let language):
            try CodeAttribute(value: value, language: language).encode(to: encoder)
        case .text(let value):
            try TextAttribute(value).encode(to: encoder)
        case .collection(let values, let type):
            try CollectionAttribute(type: type, values: values).encode(to: encoder)
        case .complex(let values, let layout):
            try ComplexAttribute(values: values, layout: layout).encode(to: encoder)
        case .enumerableCollection(let values, let cases):
            try EnumCollectionAttribute(cases: cases, values: values).encode(to: encoder)
        case .table(let rows, columns: let columns):
            try TableAttribute(rows: rows, columns: columns).encode(to: encoder)
        }
    }
    
    private struct CodeAttribute: Hashable, Codable {
        
        var value: String
        
        var language: Language
        
    }
    
    private struct TextAttribute: Hashable, Codable {
        
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
    
    private struct CollectionAttribute: Hashable, Codable {
        
        var type: AttributeType
        
        var values: [Attribute]
        
    }
    
    private struct ComplexAttribute: Hashable, Codable {
        
        var values: [String: Attribute]
        
        var layout: [Field]
        
    }
    
    private struct EnumCollectionAttribute: Hashable, Codable {
        
        var cases: Set<String>
        
        var values: Set<String>
        
    }
    
    private struct TableAttribute: Hashable, Codable {
        
        var rows: [[LineAttribute]]
        
        var columns: [BlockAttributeType.TableColumn]
        
    }
    
}

extension BlockAttribute: XMIConvertible {
    
    public var xmiName: String? {
        switch self {
        case .code:
            return "CodeAttribute"
        case .text:
            return "TextAttribute"
        case .collection:
            return "CollectionAttribute"
        case .complex:
            return "ComplexAttribute"
        case .enumerableCollection:
            return "EnumerableAttribute"
        case .table:
            return "TableAttribute"
        }
    }
    
}
