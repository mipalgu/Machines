/*
 * ValidatorFactory.swift
 * Attributes
 *
 * Created by Callum McColl on 11/6/21.
 * Copyright © 2021 Callum McColl. All rights reserved.
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

public struct ValidatorFactory<Value> {
    
    private let _make: () -> AnyValidator<Value>
    
    private let required: Bool
    
    private init(required: Bool, make: @escaping () -> AnyValidator<Value>) {
        self._make = make
        self.required = required
    }
    
    func make<Path: ReadOnlyPathProtocol>(path: Path) -> AnyValidator<Path.Root> where Path.Value == Value {
        AnyValidator { root in
            if required && path.isNil(root) {
                throw AttributeError(message: "Does not exist", path: AnyPath(path))
            }
            if !required && path.isNil(root) {
                return
            }
            try _make().performValidation(root[keyPath: path.keyPath])
        }
    }
    
    public static func required() -> ValidatorFactory<Value> {
        .init(required: true) { AnyValidator() }
    }
    
    public static func optional() -> ValidatorFactory<Value> {
        .init(required: false) { AnyValidator() }
    }
    
    internal func push<Validator: ValidatorProtocol>(_ make: @escaping (ValidationPath<ReadOnlyPath<Value, Value>>) -> Validator) -> ValidatorFactory<Value> where Validator.Root == Value {
        ValidatorFactory(required: required) {
            let newValidator = make(ValidationPath(path: ReadOnlyPath(keyPath: \Value.self, ancestors: [])))
            return AnyValidator([_make(), AnyValidator(newValidator)])
        }
    }
    
}

extension ValidatorFactory {

    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Value> then builder: @escaping () -> AnyValidator<Value>
    ) -> ValidatorFactory<Value> {
        push { $0.if(condition, then: builder) }
    }

    public func `if`(
        _ condition: @escaping (Value) -> Bool,
        @ValidatorBuilder<Value> then builder1: @escaping () -> AnyValidator<Value>,
        @ValidatorBuilder<Value> else builder2: @escaping () -> AnyValidator<Value>
    ) -> ValidatorFactory<Value> {
        push { $0.if(condition, then: builder1, else: builder2) }
    }

}


extension ValidatorFactory where Value: Equatable {
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence, S2: Sequence>(_ p: P, transform: @escaping (S) -> S2) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S, S2.Element == Value {
        push { $0.in(p, transform: transform) }
    }
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S, S.Element == Value {
        push { $0.in(p) }
    }
    
}

extension ValidatorFactory where Value: Hashable {
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P, transform: @escaping (S) -> Set<Value>) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S {
        push { $0.in(p, transform: transform) }
    }
    
    public func `in`<P: ReadOnlyPathProtocol, S: Sequence>(_ p: P) -> ValidatorFactory<Value> where P.Root == Value, P.Value == S, S.Element == Value {
        push { $0.in(p) }
    }
    
    public func `in`<P: ReadOnlyPathProtocol>(_ p: P) -> ValidatorFactory<Value> where P.Root == Value, P.Value == Set<Value> {
        push { $0.in(p) }
    }
    
    public func `in`(_ set: Set<Value>) -> ValidatorFactory<Value> {
        push { $0.in(set) }
    }
    
}

extension ValidatorFactory where Value: Equatable {
    
    public func equals(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.equals(value) }
    }
    
    public func notEquals(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.notEquals(value) }
    }
    
}

extension ValidatorFactory where Value == Bool {
    
    public func equalsFalse() -> ValidatorFactory<Value>  {
        push { $0.equalsFalse() }
    }
    
    public func equalsTrue() -> ValidatorFactory<Value>  {
        push { $0.equalsTrue() }
    }
    
}

extension ValidatorFactory where Value: Comparable {
    
    public func between(min: Value, max: Value) -> ValidatorFactory<Value> {
        push { $0.between(min: min, max: max) }
    }
    
    public func lessThan(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.lessThan(value) }
    }
    
    public func lessThanEqual(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.lessThanEqual(value) }
    }
    
    public func greaterThan(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.greaterThan(value) }
    }
    
    public func greaterThanEqual(_ value: Value) -> ValidatorFactory<Value> {
        push { $0.greaterThanEqual(value) }
    }
    
}

extension ValidatorFactory where Value: Collection {
    
    public func empty() -> ValidatorFactory<Value> {
        push { $0.empty() }
    }
    
    public func notEmpty() -> ValidatorFactory<Value> {
        push { $0.notEmpty() }
    }
    
    public func length(_ length: Int) -> ValidatorFactory<Value> {
        push { $0.length(length) }
    }
    
    public func minLength(_ length: Int) -> ValidatorFactory<Value> {
        push { $0.minLength(length) }
    }
    
    public func maxLength(_ length: Int) -> ValidatorFactory<Value> {
        push { $0.maxLength(length) }
    }
    
}

extension ValidatorFactory where Value: Sequence {
    
    public func unique<S: Sequence>(_ transform: @escaping (Value) -> S) -> ValidatorFactory<Value> where S.Element: Hashable {
        push { $0.unique(transform) }
    }
    
}

extension ValidatorFactory where Value: Sequence, Value.Element: Hashable {
    
    public func unique() -> ValidatorFactory<Value> {
        push { $0.unique() }
    }
    
}

extension ValidatorFactory where Value: StringProtocol {
    
    public func alpha() -> ValidatorFactory<Value> {
        push { $0.alpha() }
    }
    
    public func alphadash() -> ValidatorFactory<Value> {
        push { $0.alphadash() }
    }
    
    public func alphafirst() -> ValidatorFactory<Value> {
        push { $0.alphafirst() }
    }
    
    public func alphanumeric() -> ValidatorFactory<Value> {
        push { $0.alphanumeric() }
    }
    
    public func alphaunderscore() -> ValidatorFactory<Value> {
        push { $0.alphaunderscore() }
    }
    
    public func alphaunderscorefirst() -> ValidatorFactory<Value> {
        push { $0.alphaunderscorefirst() }
    }
    
    public func blacklist(_ list: Set<String>) -> ValidatorFactory<Value> {
        push { $0.blacklist(list) }
    }
    
    public func numeric() -> ValidatorFactory<Value> {
        push { $0.numeric() }
    }
    
    public func whitelist(_ list: Set<String>) -> ValidatorFactory<Value> {
        push { $0.whitelist(list) }
    }
    
}
