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

public enum Attribute: Hashable, Codable {
    
    public enum CodingKeys: CodingKey {
        case type
        case value
    }
    
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
            case .expression:
                return .expression
            case .enumerated(_, let validValues):
                return .enumerated(validValues: validValues)
            case .line:
                return .line
            }
        case .block(let attribute):
            switch attribute {
            case .code:
                return .code
            case .text:
                return .text
            case .collection:
                return .collection
            case .complex:
                return .complex
            case .enumerableCollection(_, let validValues):
                return .enumerableCollection(validValues: validValues)
            }
        }
    }
    
    public init(lineAttribute: LineAttribute) {
        self = .line(lineAttribute)
    }
    
    public init(blockAttribute: BlockAttribute) {
        self = .block(blockAttribute)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "line":
            let value = try container.decode(LineAttribute.self, forKey: .value)
            self = .line(value)
        case "block":
            let value = try container.decode(BlockAttribute.self, forKey: .value)
            self = .block(value)
        default:
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [CodingKeys.type], debugDescription: "Invalid value \(type)"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .line(let lineValue):
            try container.encode("line", forKey: .type)
            try container.encode(lineValue, forKey: .value)
        case .block(let blockValue):
            try container.encode("block", forKey: .type)
            try container.encode(blockValue, forKey: .value)
        }
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
    
    public static func expression(_ value: Expression) -> Attribute {
        return .line(.expression(value))
    }
    
    public static func line(_ value: String) -> Attribute {
        return .line(.line(value))
    }
    
    public static func code(_ value: String) -> Attribute {
        return .block(.code(value))
    }
    
    public static func text(_ value: String) -> Attribute {
        return .block(.text(value))
    }
    
    public static func collection(_ value: [Attribute]) -> Attribute {
        return .block(.collection(value))
    }
    
    public static func complex(_ value: [String: Attribute]) -> Attribute {
        return .block(.complex(value))
    }
    
    public static func enumerated(_ value: String, validValues: Set<String>) -> Attribute {
        return .line(.enumerated(value, validValues: validValues))
    }
    
    public static func enumerableCollection(_ value: Set<String>, validValues: Set<String>) -> Attribute {
        return .block(.enumerableCollection(value, validValues: validValues))
    }
    
}
