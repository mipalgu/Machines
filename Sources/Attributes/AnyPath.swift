/*
 * AnyPath.swift
 * Attributes
 *
 * Created by Callum McColl on 5/11/20.
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

public struct AnyPath<Root> {
    
    fileprivate let ancestors: [AnyPath<Root>]
    
    fileprivate let partialKeyPath: PartialKeyPath<Root>
    
    public let isOptional: Bool
    
    let _value: (Root) -> Any
    
    let _isNil: (Root) -> Bool
    
    private init<P: PathProtocol>(_ path: P, isOptional: Bool, isNil: @escaping (Root) -> Bool) where P.Root == Root {
        self.ancestors = path.ancestors
        self.partialKeyPath = path.path
        self._value = { $0[keyPath: path.path] as Any }
        self.isOptional = isOptional || (path.ancestors.last?.isOptional ?? false)
        self._isNil = { root in (path.ancestors.last?.isNil(root) ?? false) || isNil(root) }
    }
    
    public init<P: PathProtocol>(_ path: P) where P.Root == Root {
        self.init(path, isOptional: false, isNil: { _ in false })
    }
    
    public init<P: PathProtocol, V>(optional path: P) where P.Root == Root, P.Value == V? {
        self.init(path, isOptional: true, isNil: { nil == $0[keyPath: path.path] })
    }
    
    public func hasValue(_ root: Root) -> Bool {
        return !isOptional || !isNil(root)
    }
    
    public func value(_ root: Root) -> Any {
        return self._value(root)
    }
    
    public func isNil(_ root: Root) -> Bool {
        return self._isNil(root)
    }
    
}

extension AnyPath: Equatable {
    
    public static func == <Root>(lhs: AnyPath<Root>, rhs: AnyPath<Root>) -> Bool {
        lhs.ancestors == rhs.ancestors && lhs.partialKeyPath == rhs.partialKeyPath
    }
    
}
