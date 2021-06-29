/*
 * Path.swift
 * Attributes
 *
 * Created by Callum McColl on 4/11/20.
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

@dynamicMemberLookup
public struct ReadOnlyPath<Root, Value>: ReadOnlyPathProtocol {
    
    public var ancestors: [AnyPath<Root>]
    
    public var keyPath: KeyPath<Root, Value>
    
    private let _isNil: (Root) -> Bool
    
    public init(keyPath: KeyPath<Root, Value>, ancestors: [AnyPath<Root>], isNil: @escaping (Root) -> Bool) {
        self.ancestors = ancestors.reversed().drop { $0.partialKeyPath == keyPath }.reversed()
        self.keyPath = keyPath
        self._isNil = { root in ancestors.last?.isNil(root) ?? false || isNil(root) }
    }
    
    public init(keyPath: KeyPath<Root, Value>, ancestors: [AnyPath<Root>]) {
        self.init(keyPath: keyPath, ancestors: ancestors, isNil: { _ in false })
    }
    
    public init<T>(keyPath: KeyPath<Root, Value>, ancestors: [AnyPath<Root>]) where Value == Optional<T> {
        self.init(keyPath: keyPath, ancestors: ancestors, isNil: { root in root[keyPath: keyPath] == nil })
    }
    
    public subscript<AppendedValue>(dynamicMember member: KeyPath<Value, AppendedValue>) -> ReadOnlyPath<Root, AppendedValue> {
        return ReadOnlyPath<Root, AppendedValue>(keyPath: keyPath.appending(path: member), ancestors: fullPath)
    }
    
    public func isNil(_ root: Root) -> Bool {
        return self._isNil(root)
    }
    
}

extension ReadOnlyPath {
    
    public static func ==(lhs: ReadOnlyPath<Root, Value>, rhs: ReadOnlyPath<Root, Value>) -> Bool {
        return lhs.ancestors == rhs.ancestors && lhs.keyPath == rhs.keyPath
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.ancestors)
        hasher.combine(self.keyPath)
    }
    
}

@dynamicMemberLookup
public struct Path<Root, Value>: PathProtocol {
    
    public var ancestors: [AnyPath<Root>]
    
    public var path: WritableKeyPath<Root, Value>
    
    private let _isNil: (Root) -> Bool
    
    init(path: WritableKeyPath<Root, Value>, ancestors: [AnyPath<Root>], isNil: @escaping (Root) -> Bool) {
        self.path = path
        self.ancestors = ancestors.reversed().drop { $0.partialKeyPath == path }.reversed()
        self._isNil = { root in ancestors.last?.isNil(root) ?? false || isNil(root) }
    }
    
    public init(path: WritableKeyPath<Root, Value>, ancestors: [AnyPath<Root>]) {
        self.init(path: path, ancestors: ancestors, isNil: { _ in false })
    }
    
    public init<T>(path: WritableKeyPath<Root, Value>, ancestors: [AnyPath<Root>]) where Value == Optional<T> {
        self.init(path: path, ancestors: ancestors, isNil: { root in root[keyPath: path] == nil })
    }
    
    public var readOnly: ReadOnlyPath<Root, Value> {
        return ReadOnlyPath(keyPath: self.path as KeyPath<Root, Value>, ancestors: self.ancestors)
    }
    
    public subscript<AppendedValue>(dynamicMember member: KeyPath<Value, AppendedValue>) -> ReadOnlyPath<Root, AppendedValue> {
        return ReadOnlyPath<Root, AppendedValue>(keyPath: path.appending(path: member), ancestors: fullPath)
    }
    
    public subscript<AppendedValue>(dynamicMember member: WritableKeyPath<Value, AppendedValue>) -> Path<Root, AppendedValue> {
        return Path<Root, AppendedValue>(path: path.appending(path: member), ancestors: fullPath)
    }
    
    public func appending<NewValue>(path: Path<Value, NewValue>) -> Path<Root, NewValue> {
        return Path<Root, NewValue>(
            path: self.path.appending(path: path.path),
            ancestors: self.ancestors + path.ancestors.map {
                $0.changeRoot(path: self)
            }
        )
    }
    
    public func changeRoot<NewRoot>(path: Path<NewRoot, Root>) -> Path<NewRoot, Value> {
        let ancestors = path.ancestors + self.ancestors.map {
            $0.changeRoot(path: path.readOnly)
        }
        return Path<NewRoot, Value>(path: path.path.appending(path: self.path), ancestors: ancestors)
    }
    
    public func isNil(_ root: Root) -> Bool {
        return self._isNil(root)
    }
    
}

extension Path {
    
    public static func ==(lhs: Path<Root, Value>, rhs: Path<Root, Value>) -> Bool {
        return lhs.ancestors == rhs.ancestors && lhs.keyPath == rhs.keyPath
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.ancestors)
        hasher.combine(self.keyPath)
    }
    
}

extension Path {
    
    public func validate(@ValidatorBuilder<Root> builder: (ValidationPath<Path<Root, Value>>) -> AnyValidator<Root>) -> AnyValidator<Root> {
        return builder(ValidationPath(path: Path(path: self.path, ancestors: self.fullPath)))
    }
    
}

extension Path {
    
    public func trigger(@TriggerBuilder<Root> builder: (WhenChanged<Path<Root, Value>, IdentityTrigger<Root>>) -> [AnyTrigger<Root>]) -> AnyTrigger<Root> {
        return AnyTrigger(builder(WhenChanged(Path(path: self.path, ancestors: self.fullPath))))
    }
    
}
