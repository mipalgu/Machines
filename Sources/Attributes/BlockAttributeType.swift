/*
 * BlockAttributeType.swift
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

public enum BlockAttributeType: Hashable {
    
    public struct TableColumn: Hashable, Codable {
        
        public var name: String
        
        public var type: LineAttributeType
        
        public init(name: String, type: LineAttributeType) {
            self.name = name
            self.type = type
        }
        
    }
    
    case code(language: Language)
    case text
    indirect case collection(type: AttributeType)
    indirect case complex(layout: [String: AttributeType])
    case enumerableCollection(validValues: Set<String>)
    case table(columns: [TableColumn])
    
}

extension BlockAttributeType: Codable {
    
    public init(from decoder: Decoder) throws {
        if let code = try? CodeAttributeType(from: decoder) {
            self = .code(language: code.language)
            return
        }
        if let _ = try? TextAttributeType(from: decoder) {
            self = .text
            return
        }
        if let collection = try? CollectionAttributeType(from: decoder) {
            self = .collection(type: collection.type)
        }
        if let complex = try? ComplexAttributeType(from: decoder) {
            self = .complex(layout: complex.layout)
        }
        if let enumCollection = try? EnumCollectionAttributeType(from: decoder) {
            self = .enumerableCollection(validValues: enumCollection.validValues)
        }
        if let table = try? TableAttributeType(from: decoder) {
            self = .table(columns: table.columns)
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Unsupported type"
            )
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .code(let language):
            try CodeAttributeType(language: language).encode(to: encoder)
        case .text:
            try TextAttributeType().encode(to: encoder)
        case .collection(let type):
            try CollectionAttributeType(type: type).encode(to: encoder)
        case .complex(let layout):
            try ComplexAttributeType(layout: layout).encode(to: encoder)
        case .enumerableCollection(let validValues):
            try EnumCollectionAttributeType(validValues: validValues).encode(to: encoder)
        case .table(columns: let columns):
            try TableAttributeType(columns: columns).encode(to: encoder)
        }
    }
    
    private struct CodeAttributeType: Hashable, Codable, XMIConvertible {
        
        var xmiName: String? { "CodeAttributeType" }
        
        var language: Language
        
    }
    
    private struct TextAttributeType: Hashable, Codable, XMIConvertible {
        
        var xmiName: String? { "TextAttributeType" }
        
    }
    
    private struct CollectionAttributeType: Hashable, Codable, XMIConvertible {
        
        var xmiName: String? { "CollectionAttributeType" }
        
        var type: AttributeType
        
    }
    
    private struct ComplexAttributeType: Hashable, Codable, XMIConvertible {
        
        var xmiName: String? { "ComplexAttributeType" }
        
        var layout: [String: AttributeType]
        
    }
    
    private struct EnumCollectionAttributeType: Hashable, Codable, XMIConvertible {
        
        var xmiName: String? { "EnumCollectionAttributeType" }
        
        var validValues: Set<String>
        
    }
    
    private struct TableAttributeType: Hashable, Codable, XMIConvertible {
        
        var xmiName: String? { "TableAttributeType" }
        
        var columns: [BlockAttributeType.TableColumn]
        
    }
    
}

extension BlockAttributeType: XMIConvertible {
    
    public var xmiName: String? {
        switch self {
        case .code(let language):
            return CodeAttributeType(language: language).xmiName
        case .text:
            return TextAttributeType().xmiName
        case .collection(let type):
            return CollectionAttributeType(type: type).xmiName
        case .complex(let layout):
            return ComplexAttributeType(layout: layout).xmiName
        case .enumerableCollection(let validValues):
            return EnumCollectionAttributeType(validValues: validValues).xmiName
        case .table(columns: let columns):
            return TableAttributeType(columns: columns).xmiName
        }
    }
    
}
