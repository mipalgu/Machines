/*
 * LineAttributeType.swift
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

public enum LineAttributeType: Hashable {

    
    case bool
    case integer
    case float
    case expression(language: Language)
    case enumerated(validValues: Set<String>)
    case line
    
}

extension LineAttributeType: Codable {
    
    public init(from decoder: Decoder) throws {
        if let _ = try? BoolAttributeType(from: decoder) {
            self = .bool
            return
        }
        if let _ = try? IntegerAttributeType(from: decoder) {
            self = .integer
            return
        }
        if let _ = try? FloatAttributeType(from: decoder) {
            self = .float
            return
        }
        if let expression = try? ExpressionAttributeType(from: decoder) {
            self = .expression(language: expression.language)
            return
        }
        if let enumerated = try? EnumAttributeType(from: decoder) {
            self = .enumerated(validValues: enumerated.validValues)
            return
        }
        if let _ = try? LineAttributeType(from: decoder) {
            self = .line
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
        case .bool:
            try BoolAttributeType().encode(to: encoder)
        case .integer:
            try IntegerAttributeType().encode(to: encoder)
        case .float:
            try FloatAttributeType().encode(to: encoder)
        case .expression(let language):
            try ExpressionAttributeType(language: language).encode(to: encoder)
        case .enumerated(let value):
            try EnumAttributeType(validValues: value).encode(to: encoder)
        case .line:
            try LineAttributeType().encode(to: encoder)
        }
    }
    
    private struct BoolAttributeType: Hashable, Codable {}
    
    private struct IntegerAttributeType: Hashable, Codable {}
    
    private struct FloatAttributeType: Hashable, Codable {}
    
    private struct ExpressionAttributeType: Hashable, Codable {
        
        var language: Language
        
    }
    
    private struct EnumAttributeType: Hashable, Codable {
        
        var validValues: Set<String>
        
    }
    
    private struct LineAttributeType: Hashable, Codable {}
    
}
