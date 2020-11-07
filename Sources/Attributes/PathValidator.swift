/*
 * PathValidator.swift
 * Attributes
 *
 * Created by Callum McColl on 6/11/20.
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

internal protocol _Push {
    
    associatedtype PathType: ReadOnlyPathProtocol
    
    var path: PathType { get }
    var _validate: (PathType.Root, PathType.Value) throws -> Void { get }
    
    init(_ path: PathType, _validate: @escaping (PathType.Root, PathType.Value) throws -> Void)
    
}

extension _Push {
    
    public func push(_ f: @escaping (PathType.Root, PathType.Value) throws -> Void) -> Self {
        return Self(self.path) {
            try self._validate($0, $1)
            try f($0, $1)
        }
    }
    
}

internal typealias _PathValidator = _Push & PathValidator

public protocol PathValidator: ValidatorProtocol where Root == PathType.Root {
    
    associatedtype PathType: ReadOnlyPathProtocol
    
    var path: PathType { get }
    
    init(path: PathType)
    
    func push(_ f: @escaping (PathType.Root, PathType.Value) throws -> Void) -> Self
    
}

extension PathValidator {
    
    public typealias Value = PathType.Value
    
    public func `if`<V: ValidatorProtocol>(_ condition: @escaping (Value) -> Bool, then validator: V) -> Self where V.Root == Root {
        return push {
            if condition($1) {
                return try validator.validate($0)
            }
        }
    }
    
}

extension PathValidator where Value: Hashable {
    
    public func `in`<P: ReadOnlyPathProtocol>(_ p: P) -> Self where P.Root == Root, P.Value == Set<Value> {
        return push {
            if !$0[keyPath: p.keyPath].contains($1) {
                throw ValidationError(message: "Must equal on of the following: '\(p)'.", path: path)
            }
        }
    }
    
    public func `in`(_ set: Set<Value>) -> Self {
        return push {
            if !set.contains($1) {
                throw ValidationError(message: "Must equal on of the following: '\(set)'.", path: path)
            }
        }
    }
    
}

extension PathValidator where Value: Equatable {
    
    public func equals(_ value: Value) -> Self {
        return push {
            if $1 != value {
                throw ValidationError(message: "Must equal \(value).", path: path)
            }
        }
    }
    
    public func notEquals(_ value: Value) -> Self {
        return push {
            if $1 == value {
                throw ValidationError(message: "Must not equal \(value).", path: path)
            }
        }
    }
    
}

extension PathValidator where Value == Bool {
    
    public func equalsFalse() -> Self {
        return self.equals(false)
    }
    
    public func equalsTrue() -> Self {
        return self.equals(true)
    }
    
}

extension PathValidator where Value: Comparable {
    
    public func between(min: Value, max: Value) -> Self {
        return push {
            if $1 < min || $1 > max {
                throw ValidationError(message: "Must be between \(min) and \(max).", path: path)
            }
        }
    }
    
    public func lessThan(_ value: Value) -> Self {
        return push {
            if $1 >= value {
                throw ValidationError(message: "Must be less than \(value).", path: path)
            }
        }
    }
    
    public func lessThanEqual(_ value: Value) -> Self {
        return push {
            if $1 > value {
                throw ValidationError(message: "Must be less than or equal to \(value).", path: path)
            }
        }
    }
    
    public func greaterThan(_ value: Value) -> Self {
        return push {
            if $1 <= value {
                throw ValidationError(message: "Must be greater than \(value).", path: path)
            }
        }
    }
    
    public func greaterThanEqual(_ value: Value) -> Self {
        return push {
            if $1 < value {
                throw ValidationError(message: "Must be greater than or equal to \(value).", path: path)
            }
        }
    }
    
}

extension PathValidator where Value: Collection {
    
    public func notEmpty() -> Self {
        return push {
            if $1.isEmpty {
                throw ValidationError(message: "Cannot be empty.", path: path)
            }
        }
    }
    
    public func length(_ length: Int) -> Self {
        return push {
            if $1.count != length {
                throw ValidationError(message: "Must have exactly \(length) elements.", path: path)
            }
        }
    }
    
    public func minLength(_ length: Int) -> Self {
        if length == 1 {
            return notEmpty()
        }
        return push {
            if $1.count < length {
                throw ValidationError(message: "Must provide at least \(length) values.", path: path)
            }
        }
    }
    
    public func maxLength(_ length: Int) -> Self {
        return push {
            if $1.count > length {
                throw ValidationError(message: "Must provide no more than \(length) values.", path: path)
            }
        }
    }
    
//    public func each(_ f: @escaping (Validator<Root, Value.Element>) throws -> Void) -> Self {
//        return push {
//            AnyValidator(Validator(, _validate: <#T##(_, _) throws -> Void#>))
//        }
//    }
    
    public func each(_ f: @escaping (Value.Element) throws -> Void) -> Self {
        return push {
            try $1.forEach(f)
        }
    }
    
    public func each(_ f: @escaping (Value.Element) throws -> Void, where filter: @escaping (Value.Element) -> Bool) -> Self {
        return push {
            try $1.filter(filter).forEach(f)
        }
    }
    
}

extension PathValidator where Value: Nilable {
    
    public func required() -> Self {
        return push {
            if $1.isNil {
                throw ValidationError(message: "Required.", path: path)
            }
        }
    }
    
}

extension PathValidator where Value: StringProtocol {
    
    public func alpha() -> Self {
        return push {
            if nil != $1.first(where: { !$0.isLetter }) {
                throw ValidationError(message: "Must be alphabetic.", path: path)
            }
        }
    }
    
    public func alphadash() -> Self {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber && $0 != "_" && $0 != "-" }) {
                throw ValidationError(message: "Must be alphabetic with underscores and dashes allowed.", path: path)
            }
        }
    }
    
    public func alphanumeric() -> Self {
        return push {
            if nil != $1.first(where: { !$0.isLetter && !$0.isNumber }) {
                throw ValidationError(message: "Must be alphanumeric.", path: path)
            }
        }
    }
    
    public func numeric() -> Self {
        return push {
            if nil != $1.first(where: { !$0.isNumber }) {
                throw ValidationError(message: "Must be numeric.", path: path)
            }
        }
    }
    
}
