/*
 * XMIKeyedEncodingContainer.swift
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

final class XMIKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var data: [String: String] = [:]
    
    var codingPath: [CodingKey]
    
    init(codingPath: [CodingKey]) {
        self.codingPath = codingPath
    }
    
    func combined(separator: String) -> String {
        return self.data.sorted { $0.key < $1.key }.lazy.map { $1 }.joined(separator: separator)
    }
    
    private func addtoData(_ value: String, key: Key, type: String) throws {
        let str = "<" + key.stringValue + " type=\"" + type + "\">\n" + value + "\n</" + key.stringValue + ">"
        data[key.stringValue] = str
    }
    
    func encodeNil(forKey key: Key) throws {
        try addtoData("nil", key: key, type: "nil")
    }
    
    func encode(_ value: Bool, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Bool")
    }
    
    func encode(_ value: String, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "String")
    }
    
    func encode(_ value: Double, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Double")
    }
    
    func encode(_ value: Float, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Float")
    }
    
    func encode(_ value: Int, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Int")
    }
    
    func encode(_ value: Int8, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Int8")
    }
    
    func encode(_ value: Int16, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Int16")
    }
    
    func encode(_ value: Int32, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Int32")
    }
    
    func encode(_ value: Int64, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "Int64")
    }
    
    func encode(_ value: UInt, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "UInt")
    }
    
    func encode(_ value: UInt8, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "UInt8")
    }
    
    func encode(_ value: UInt16, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "UInt16")
    }
    
    func encode(_ value: UInt32, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "UInt32")
    }
    
    func encode(_ value: UInt64, forKey key: Key) throws {
        try addtoData(String(describing: value), key: key, type: "UInt64")
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let encoder = XMIEncoder()
        let str: String = try encoder.encode(value)
        try addtoData(str, key: key, type: "\(T.self)")
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        return KeyedEncodingContainer(XMIKeyedEncodingContainer<NestedKey>(codingPath: codingPath + [key]))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
       return XMIUnkeyedEncodingContainer(codingPath: codingPath + [key])
    }
    
    func superEncoder() -> Encoder {
        let key = Key(stringValue: "super")!
        return self.superEncoder(forKey: key)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        return XMIEncoder(codingPath: self.codingPath + [key], userInfo: [:])
    }
    
}
