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

public enum BlockAttribute: Hashable, Codable {
    
    public enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    case code(_ value: String)
    
    case text(_ value: String)
    
    indirect case collection(_ values: [Attribute], type: AttributeType)
    
    indirect case complex(_ data: [String: Attribute])
    
    case enumerableCollection(_ values: Set<String>, validValues: Set<String>)
    
    public var type: BlockAttributeType {
        switch self {
        case .code:
            return .code
        case .text:
            return .text
        case .collection(_, let type):
            return .collection(type: type)
        case .complex(let values):
            return .complex(layout: values.mapValues { $0.type })
        case .enumerableCollection(_, let validValues):
            return .enumerableCollection(validValues: validValues)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "code":
            let value = try container.decode(String.self, forKey: .value)
            self = .code(value)
        case "text":
            let value = try container.decode(String.self, forKey: .value)
            self = .text(value)
        case "collection":
            let attributes = try container.decode(TypeValuesPair.self, forKey: .value)
            self = .collection(attributes.values, type: attributes.type)
        case "complex":
            let attributes = try container.decode([String: Attribute].self, forKey: .value)
            self = .complex(attributes)
        case "enumerableCollection":
            let pair = try container.decode(EnumCollection.self, forKey: .value)
            self = .enumerableCollection(pair.values, validValues: pair.cases)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "Invalid value \(type)"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .code(let value):
            try container.encode("code", forKey: .type)
            try container.encode(value, forKey: .value)
        case .text(let value):
            try container.encode("text", forKey: .type)
            try container.encode(value, forKey: .value)
        case .collection(let values, let type):
            try container.encode("collection", forKey: .type)
            try container.encode(TypeValuesPair(type: type, values: values), forKey: .value)
        case .complex(let values):
            try container.encode("complex", forKey: .type)
            try container.encode(values, forKey: .value)
        case .enumerableCollection(let values, let cases):
            try container.encode("enumerableCollection", forKey: .type)
            try container.encode(EnumCollection(cases: cases, values: values), forKey: .value)
        }
    }
    
    private struct TypeValuesPair: Hashable, Codable {
        
        var type: AttributeType
        
        var values: [Attribute]
        
    }
    
    private struct KeyValuePair: Hashable, Codable {
        
        var key: String
        
        var value: Attribute
        
        init(key: String, value: Attribute) {
            self.key = key
            self.value = value
        }
        
    }
    
    private struct EnumCollection: Hashable, Codable {
        
        var cases: Set<String>
        
        var values: Set<String>
        
        init(cases: Set<String>, values: Set<String>) {
            self.cases = cases
            self.values = values
        }
        
    }
    
}
