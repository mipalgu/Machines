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
    
    public let ancestors: [AnyPath<Root>]
    
    public let partialKeyPath: PartialKeyPath<Root>
    
    public let isOptional: Bool
    
    public let targetType: Any.Type
    
    let _value: (Root) -> Any
    
    let _isNil: (Root) -> Bool
    
    let _isSame: (PartialKeyPath<Root>) -> Bool
    
    private init(_ path: PartialKeyPath<Root>, ancestors: [AnyPath<Root>], targetType: Any.Type, isOptional: Bool, isNil: @escaping (Root) -> Bool, isSame: @escaping (PartialKeyPath<Root>) -> Bool) {
        self.ancestors = ancestors
        self.partialKeyPath = path
        self.targetType = targetType
        self._value = { $0[keyPath: path] as Any }
        self.isOptional = isOptional || (ancestors.last?.isOptional ?? false)
        self._isNil = { root in ancestors.last?.isNil(root) ?? false || isNil(root) }
        self._isSame = isSame
    }
    
    private init<P: ReadOnlyPathProtocol>(_ path: P, isOptional: Bool, isNil: @escaping (Root) -> Bool, isSame: @escaping (PartialKeyPath<Root>) -> Bool) where P.Root == Root {
        self.init(path.keyPath, ancestors: path.ancestors, targetType: P.Value.self, isOptional: isOptional, isNil: isNil, isSame: isSame)
    }
    
    public init<P: ReadOnlyPathProtocol>(_ path: P) where P.Root == Root {
        self.init(path, isOptional: false, isNil: { path.isNil($0) }, isSame: { $0 == path.keyPath })
    }
    
    public init<P: ReadOnlyPathProtocol, V>(optional path: P) where P.Root == Root, P.Value == V? {
        self.init(path, isOptional: true, isNil: { path.isNil($0) }, isSame: { $0 == path.keyPath || $0 == path.keyPath.appending(path: \.wrappedValue) })
    }
    
    public func isParent(of path: AnyPath<Root>) -> Bool {
        return path.isChild(of: self)
    }
    
    public func isParent<Path: ReadOnlyPathProtocol>(of path: Path) -> Bool where Path.Root == Root {
        return self.isParent(of: AnyPath(path))
    }
    
    public func isChild(of path: AnyPath<Root>) -> Bool {
        return self.isChild(of: path.partialKeyPath)
    }
    
    public func isChild(of path: PartialKeyPath<Root>) -> Bool {
        return nil != self.ancestors.first(where: { $0.isSame(as: path) })
    }
    
    public func isChild<Path: ReadOnlyPathProtocol>(of path: Path) -> Bool where Path.Root == Root {
        return self.isChild(of: path.keyPath)
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
    
    public func isSame(as path: AnyPath<Root>) -> Bool {
        return self._isSame(path.partialKeyPath)
    }
    
    public func isSame(as path: PartialKeyPath<Root>) -> Bool {
        return self._isSame(path)
    }
    
    public func isSame<Path: ReadOnlyPathProtocol>(as path: Path) -> Bool where Path.Root == Root {
        return self._isSame(path.keyPath)
    }
    
    public func appending<Value>(_ path: AnyPath<Value>) -> AnyPath<Root>? {
        guard
            let keyPath = self.partialKeyPath as? KeyPath<Root, Value>,
            let newPartialKeyPath = self.partialKeyPath.appending(path: path.partialKeyPath)
        else {
            return nil
        }
        return AnyPath(
            newPartialKeyPath,
            ancestors: [],
            targetType: Any.self,
            isOptional: path.isOptional,
            isNil: { path.isNil($0[keyPath: keyPath]) },
            isSame: { $0 == newPartialKeyPath }
        )
    }
    
}

extension AnyPath: Equatable {
    
    public static func == <Root>(lhs: AnyPath<Root>, rhs: AnyPath<Root>) -> Bool {
        lhs.partialKeyPath == rhs.partialKeyPath
    }
    
}

extension AnyPath: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.ancestors)
        hasher.combine(self.partialKeyPath)
    }
    
}

extension AnyPath: CustomStringConvertible {
    
    public var description: String {
        return (self.ancestors.map { String(describing: $0.partialKeyPath) } + [String(describing: self.partialKeyPath)]).joined(separator: ", ")
    }
    
}
