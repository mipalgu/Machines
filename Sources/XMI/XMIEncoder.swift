/*
 * XMIEncoder.swift
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

public final class XMIEncoder: Encoder {
    
    public var codingPath: [CodingKey]
    
    public var userInfo: [CodingUserInfoKey : Any]
    
    private var lastData: (() -> String)!
    
    public convenience init() {
        self.init(codingPath: [], userInfo: [:])
    }
    
    internal init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    public func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let encoder = XMIKeyedEncodingContainer<Key>(codingPath: self.codingPath)
        self.lastData = { encoder.combined(separator: "\n") }
        return KeyedEncodingContainer(encoder)
    }
    
    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        let encoder = XMIUnkeyedEncodingContainer(codingPath: self.codingPath)
        self.lastData = { encoder.combined(separator: "\n") }
        return encoder
    }
    
    public func singleValueContainer() -> SingleValueEncodingContainer {
        let encoder = XMISingleValueEncodingContainer(codingPath: self.codingPath)
        self.lastData = { encoder.data }
        return encoder
    }
    
    public func encode<T : Encodable>(_ value: T) throws -> Data {
        return try self.encode(value, xmiName: "\(T.self)")
    }
    
    public func encode<T: Encodable>(_ value: T) throws -> Data where T: XMIConvertible {
        return try self.encode(value, xmiName: value.xmiName ?? "\(T.self)")
    }
    
    internal func encode<T: Encodable>(_ value: T, xmiName: String) throws -> Data {
        let body: String = try self.encode(value, xmiName: xmiName)
        let head = """
            <?xml version="1.0" encoding="UTF-8"?>
            <xmi:XMI xmi:version="2.0">
            """
        let tail = """
            </xmi:XMI>
            """
        let document = [head, body, tail].joined(separator: "\n")
        guard let result = document.data(using: .utf8) else {
            throw EncodingError.invalidValue(document, EncodingError.Context(codingPath: [], debugDescription: "Unable to convert string to Data using utf8 encoding"))
        }
        return result
    }
    
    internal func encode<T: Encodable>(_ value: T, xmiName: String) throws -> String {
        self.lastData = nil
        try value.encode(to: self)
        let body = self.lastData()
        return body
    }
    
}
