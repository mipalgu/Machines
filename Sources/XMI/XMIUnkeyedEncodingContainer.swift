/*
 * XMIUnkeyedEncodingContainer.swift
 * XMI
 *
 * Created by Callum McColl on 1/11/20.
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

import Foundation

final class XMIUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    
    private struct IndexCodingKey: CodingKey {
        
        fileprivate var intValue: Int?
        
        fileprivate var stringValue: String {
            return "\(intValue!)"
        }
        
        fileprivate init?(intValue: Int) {
            self.intValue = intValue
        }
        
        fileprivate init?(stringValue: String) {
            guard let int = Int(stringValue) else {
                return nil
            }
            self.init(intValue: int)
        }
        
    }
    
    var codingPath: [CodingKey]
    
    var count: Int = 0
    
    var data: [String] = []
    
    var combined: String {
        return data.joined(separator: "")
    }
    
    private var nextIndex: IndexCodingKey {
        get {
            return IndexCodingKey(intValue: self.count)!
        }
    }
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    func addToData(_ value: String, type: String) throws {
        defer { self.count += 1 }
        let str = "<" + type + " index=\"" + String(describing: self.nextIndex) + "\" type=\"" + type + "\">" + value + "<" + type + "/>"
        data.append(str)
    }
    
    func encodeNil() throws {
        try addToData("nil", type: "nil")
    }
    
    func encode(_ value: Bool) throws {
        try addToData(String(describing: value), type: "Bool")
    }

    func encode(_ value: String) throws {
        try addToData(String(describing: value), type: "String")
    }

    func encode(_ value: Double) throws {
        try addToData(String(describing: value), type: "Double")
    }

    func encode(_ value: Float) throws {
        try addToData(String(describing: value), type: "Float")
    }

    func encode(_ value: Int) throws {
        try addToData(String(describing: value), type: "Int")
    }

    func encode(_ value: Int8) throws {
        try addToData(String(describing: value), type: "Int8")
    }

    func encode(_ value: Int16) throws {
        try addToData(String(describing: value), type: "Int16")
    }

    func encode(_ value: Int32) throws {
        try addToData(String(describing: value), type: "Int32")
    }

    func encode(_ value: Int64) throws {
        try addToData(String(describing: value), type: "Int64")
    }

    func encode(_ value: UInt) throws {
        try addToData(String(describing: value), type: "UInt")
    }

    func encode(_ value: UInt8) throws {
        try addToData(String(describing: value), type: "UInt8")
    }

    func encode(_ value: UInt16) throws {
        try addToData(String(describing: value), type: "UInt16")
    }

    func encode(_ value: UInt32) throws {
        try addToData(String(describing: value), type: "UInt32")
    }

    func encode(_ value: UInt64) throws {
        try addToData(String(describing: value), type: "UInt64")
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        let encoder = XMIEncoder()
        let str: String = try encoder.encode(value)
        try addToData(str, type: "\(T.self)")
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedEncodingContainer(XMIKeyedEncodingContainer<NestedKey>(codingPath: codingPath))
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        return XMIUnkeyedEncodingContainer(codingPath: codingPath)
    }
    
    func superEncoder() -> Encoder {
        defer { self.count += 1 }
        return XMIEncoder(codingPath: [self.nextIndex], userInfo: [:])
    }
    
}
