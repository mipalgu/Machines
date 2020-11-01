/*
 * AttributeType.swift
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

public enum AttributeType: Hashable, Codable {
    
    public enum CodingKeys: CodingKey {
        case type
        case value
    }
    
    case bool
    case integer
    case float
    case expression(language: Language)
    case line
    case code(language: Language)
    case text
    indirect case collection(type: AttributeType)
    indirect case complex(layout: [String: AttributeType])
    case enumerated(validValues: Set<String>)
    case enumerableCollection(validValues: Set<String>)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "bool":
            self = .bool
        case "integer":
            self = .integer
        case "float":
            self = .float
        case "expression":
            let language = try container.decode(Language.self, forKey: .value)
            self = .expression(language: language)
        case "enumerated":
            let value = try container.decode(Set<String>.self, forKey: .value)
            self = .enumerated(validValues: value)
        case "line":
            self = .line
        case "code":
            let language = try container.decode(Language.self, forKey: .value)
            self = .code(language: language)
        case "text":
            self = .text
        case "collection":
            let value = try container.decode(AttributeType.self, forKey: .value)
            self = .collection(type: value)
        case "complex":
            let value = try container.decode([String: AttributeType].self, forKey: .value)
            self = .complex(layout: value)
        case "enumerableCollection":
            let cases = try container.decode(Set<String>.self, forKey: .value)
            self = .enumerableCollection(validValues: cases)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "Invalid value \(type)"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .bool:
            try container.encode("bool", forKey: .type)
        case .integer:
            try container.encode("integer", forKey: .type)
        case .float:
            try container.encode("float", forKey: .type)
        case .expression(let language):
            try container.encode("expression", forKey: .type)
            try container.encode(language, forKey: .value)
        case .enumerated(let value):
            try container.encode("enumerated", forKey: .type)
            try container.encode(value, forKey: .value)
        case .line:
            try container.encode("line", forKey: .type)
        case .code(let language):
            try container.encode("code", forKey: .type)
            try container.encode(language, forKey: .value)
        case .text:
            try container.encode("text", forKey: .type)
        case .collection(let values):
            try container.encode("collection", forKey: .type)
            try container.encode(values, forKey: .value)
        case .complex(let values):
            try container.encode("complex", forKey: .type)
            try container.encode(values, forKey: .value)
        case .enumerableCollection(let cases):
            try container.encode("enumerableCollection", forKey: .type)
            try container.encode(cases, forKey: .value)
        }
    }
    
}
