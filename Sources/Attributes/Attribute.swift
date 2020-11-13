/*
 * Attribute.swift
 * Machines
 *
 * Created by Callum McColl on 29/10/20.
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

public enum Attribute: Hashable {
    
    case line(LineAttribute)
    case block(BlockAttribute)
    
    public var type: AttributeType {
        switch self {
        case .line(let attribute):
            switch attribute {
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
        case .block(let attribute):
            switch attribute {
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
                return .table(columns: columns.map { ($0.name, $0.type) })
            }
        }
    }
    
    public var lineAttribute: LineAttribute {
        get {
            switch self {
            case .line(let attribute):
                return attribute
            default:
                fatalError("Attempting to access line attribute of block attribute")
            }
        } set {
            self = .line(newValue)
        }
    }
    
    public var blockAttribute: BlockAttribute {
        get {
            switch self {
            case .block(let attribute):
                return attribute
            default:
                fatalError("Attempting to access block attribute of line attribute")
            }
        } set {
            self = .block(newValue)
        }
    }
    
    public var boolValue: Bool? {
        switch self {
        case .line(let attribute):
            return attribute.boolValue
        default:
            return nil
        }
    }
    
    public var integerValue: Int? {
        switch self {
        case .line(let attribute):
            return attribute.integerValue
        default:
            return nil
        }
    }
    
    public var floatValue: Double? {
        switch self {
        case .line(let value):
            return value.floatValue
        default:
            return nil
        }
    }
    
    public var expressionValue: Expression? {
        switch self {
        case .line(let value):
            return value.expressionValue
        default:
            return nil
        }
    }
    
    public var enumeratedValue: String? {
        switch self {
        case .line(let value):
            return value.enumeratedValue
        default:
            return nil
        }
    }
    
    public var lineValue: String? {
        switch self {
        case .line(let value):
            return value.lineValue
        default:
            return nil
        }
    }
    
    public var codeValue: String? {
        switch self {
        case .block(let value):
            return value.codeValue
        default:
            return nil
        }
    }
    
    public var textValue: String? {
        switch self {
        case .block(let value):
            return value.textValue
        default:
            return nil
        }
    }
    
    public var collectionValue: [Attribute]? {
        switch self {
        case .block(let value):
            return value.collectionValue
        default:
            return nil
        }
    }
    
    public var complexValue: [String: Attribute]? {
        switch self {
        case .block(let value):
            return value.complexValue
        default:
            return nil
        }
    }
    
    public var enumerableCollectionValue: Set<String>? {
        switch self {
        case .block(let value):
            return value.enumerableCollectionValue
        default:
            return nil
        }
    }
    
    public var tableValue: [[LineAttribute]] {
        get {
            switch self {
            case .block(.table(let rows, _)):
                return rows
            default:
                fatalError("Attempting to access table value of non table value attribute")
            }
        } set {
            switch self.type {
            case .block(.table(let cols)):
                self = .block(.table(newValue, columns: cols))
            default:
                return
            }
        }
    }
    
    public var collectionBools: [Bool]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionBools
        default:
            return nil
        }
    }
    
    public var collectionIntegers: [Int]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionIntegers
        default:
            return nil
        }
    }
    
    public var collectionFloats: [Double]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionFloats
        default:
            return nil
        }
    }
    
    public var collectionExpressions: [Expression]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionExpressions
        default:
            return nil
        }
    }
    
    public var collectionEnumerated: [String]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionEnumerated
        default:
            return nil
        }
    }
    
    public var collectionLines: [String]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionLines
        default:
            return nil
        }
    }
    
    public var collectionCode: [String]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionCode
        default:
            return nil
        }
    }
    
    public var collectionText: [String]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionText
        default:
            return nil
        }
    }
    
    public var collectionComplex: [[String: Attribute]]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionComplex
        default:
            return nil
        }
    }
    
    public var collectionEnumerableCollection: [Set<String>]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionEnumerableCollection
        default:
            return nil
        }
    }
    
    public var collectionTable: [[[LineAttribute]]]? {
        switch self {
        case .block(let blockAttribute):
            return blockAttribute.collectionTable
        default:
            return nil
        }
    }
    
    public init(lineAttribute: LineAttribute) {
        self = .line(lineAttribute)
    }
    
    public init(blockAttribute: BlockAttribute) {
        self = .block(blockAttribute)
    }
    
    public static func bool(_ value: Bool) -> Attribute {
        return .line(.bool(value))
    }
    
    public static func integer(_ value: Int) -> Attribute {
        return .line(.integer(value))
    }
    
    public static func float(_ value: Double) -> Attribute {
        return .line(.float(value))
    }
    
    public static func expression(_ value: Expression, language: Language) -> Attribute {
        return .line(.expression(value, language: language))
    }
    
    public static func line(_ value: String) -> Attribute {
        return .line(.line(value))
    }
    
    public static func code(_ value: String, language: Language) -> Attribute {
        return .block(.code(value, language: language))
    }
    
    public static func text(_ value: String) -> Attribute {
        return .block(.text(value))
    }
    
    public static func collection(bools: [Bool]) -> Attribute {
        return .block(.collection(bools.map { Attribute.bool($0) }, type: .bool))
    }
    
    public static func collection(integers: [Int]) -> Attribute {
        return .block(.collection(integers.map { Attribute.integer($0) }, type: .integer))
    }
    
    public static func collection(floats: [Double]) -> Attribute {
        return .block(.collection(floats.map { Attribute.float($0) }, type: .float))
    }
    
    public static func collection(expressions: [Expression], language: Language) -> Attribute {
        return .block(.collection(expressions.map { Attribute.expression($0, language: language) }, type: .expression(language: language)))
    }
    
    public static func collection(lines: [String]) -> Attribute {
        return .block(.collection(lines.map { Attribute.line($0) }, type: .line))
    }
    
    public static func collection(code: [String], language: Language) -> Attribute {
        return .block(.collection(code.map { Attribute.code($0, language: language) }, type: .code(language: language)))
    }
    
    public static func collection(text: [String]) -> Attribute {
        return .block(.collection(text.map { Attribute.text($0) }, type: .text))
    }
    
    public static func collection(complex: [[String: Attribute]], layout: [String: AttributeType]) -> Attribute {
        return .block(.collection(complex.map { Attribute.complex($0, layout: layout) }, type: .complex(layout: layout)))
    }
    
    public static func collection(enumerated: [String], validValues: Set<String>) -> Attribute {
        return .block(.collection(enumerated.map { Attribute.enumerated($0, validValues: validValues) }, type: .enumerated(validValues: validValues)))
    }
    
    public static func collection(enumerables: [Set<String>], validValues: Set<String>) -> Attribute {
        return .block(.collection(enumerables.map { Attribute.enumerableCollection($0, validValues: validValues) }, type: .enumerableCollection(validValues: validValues)))
    }
    
    public static func collection(tables: [[[LineAttribute]]], columns: [(name: String, type: LineAttributeType)]) -> Attribute {
        return .block(.collection(tables.map { Attribute.table($0, columns: columns) }, type: .table(columns: columns)))
    }
    
    public static func collection(collection: [[Attribute]], type: AttributeType) -> Attribute {
        return .block(.collection(collection.map { Attribute.collection($0, type: type) }, type: type))
    }
    
    public static func collection(_ values: [Attribute], type: AttributeType) -> Attribute {
        return .block(.collection(values, type: type))
    }
    
    public static func complex(_ values: [String: Attribute], layout: [String: AttributeType]) -> Attribute {
        return .block(.complex(values, layout: layout))
    }
    
    public static func enumerated(_ value: String, validValues: Set<String>) -> Attribute {
        return .line(.enumerated(value, validValues: validValues))
    }
    
    public static func enumerableCollection(_ value: Set<String>, validValues: Set<String>) -> Attribute {
        return .block(.enumerableCollection(value, validValues: validValues))
    }
    
    public static func table(_ rows: [[LineAttribute]], columns: [(name: String, type: LineAttributeType)]) -> Attribute {
        return .block(.table(rows, columns: columns.map { BlockAttributeType.TableColumn(name: $0.name, type: $0.type) }))
    }
    
}

extension Attribute: Codable {
    
    public init(from decoder: Decoder) throws {
        if let lineAttribute = try? LineAttribute(from: decoder) {
            self = .line(lineAttribute)
            return
        }
        if let blockAttribute = try? BlockAttribute(from: decoder) {
            self = .block(blockAttribute)
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
        case .line(let attribute):
            try attribute.encode(to: encoder)
        case .block(let attribute):
            try attribute.encode(to: encoder)
        }
    }
    
}

extension Attribute: XMIConvertible {
    
    public var xmiName: String? {
        switch self {
        case .line(let attribute):
            return attribute.xmiName
        case .block(let attribute):
            return attribute.xmiName
        }
    }
    
}
