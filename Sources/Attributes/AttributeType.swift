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

import XMI

public enum AttributeType: Hashable {
    
    case line(LineAttributeType)
    case block(BlockAttributeType)
    
    public var defaultValue: Attribute {
        switch self {
        case .line(let lineAttribute):
            return .line(lineAttribute.defaultValue)
        case .block(let blockAttribute):
            return .block(blockAttribute.defaultValue)
        }
    }
    
    public static var bool: AttributeType {
        return .line(.bool)
    }
    
    public static var integer: AttributeType {
        return .line(.integer)
    }
    
    public static var float: AttributeType {
        return .line(.float)
    }
    
    public static func expression(language: Language) -> AttributeType {
        return .line(.expression(language: language))
    }
    
    public static func enumerated(validValues: Set<String>) -> AttributeType {
        return .line(.enumerated(validValues: validValues))
    }
    
    public static var line: AttributeType {
        return .line(.line)
    }
    
    public static func code(language: Language) -> AttributeType {
        return .block(.code(language: language))
    }
    
    public static var text: AttributeType {
        return .block(.text)
    }
    
    public static func collection(type: AttributeType) -> AttributeType {
        return .block(.collection(type: type))
    }
    
    public static func complex(layout: [Field]) -> AttributeType {
        return .block(.complex(layout: layout))
    }
    
    public static func enumerableCollection(validValues: Set<String>) -> AttributeType {
        return .block(.enumerableCollection(validValues: validValues))
    }
    
    public static func table(columns: [(name: String, type: LineAttributeType)]) -> AttributeType {
        return .block(.table(columns: columns.map { BlockAttributeType.TableColumn(name: $0.name, type: $0.type) }))
    }

}

extension AttributeType: Codable {
    
    public init(from decoder: Decoder) throws {
        if let lineAttributeType = try? LineAttributeType(from: decoder) {
            self = .line(lineAttributeType)
            return
        }
        if let blockAttributeType = try? BlockAttributeType(from: decoder) {
            self = .block(blockAttributeType)
            return
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
        case .line(let attributeType):
            try attributeType.encode(to: encoder)
        case .block(let attributeType):
            try attributeType.encode(to: encoder)
        }
    }
    
}

extension AttributeType: XMIConvertible {
    
    public var xmiName: String? {
        switch self {
        case .line(let type):
            return type.xmiName
        case .block(let type):
            return type.xmiName
        }
    }
    
}
