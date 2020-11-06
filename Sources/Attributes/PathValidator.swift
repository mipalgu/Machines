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
    
    associatedtype _Root
    associatedtype _Value
    
    var path: AnyPath<_Root> { get }
    var _validate: (_Value) throws -> Void { get }
    
    init(_ path: AnyPath<_Root>, _validate: @escaping (_Value) throws -> Void)
    
}

extension _Push {
    
    public func push(_ f: @escaping (_Value) throws -> Void) -> Self {
        return Self(self.path) {
            try self._validate($0)
            try f($0)
        }
    }
    
}

internal typealias _PathValidator = _Push & PathValidator

public protocol PathValidator {
    
    associatedtype Root
    associatedtype Value
    
    init(path: AnyPath<Root>)
    
    func push(_ f: @escaping (Value) throws -> Void) -> Self
    
}

extension PathValidator where Value: Hashable {
    
    public func `in`(_ set: Set<Value>) -> Self {
        return push {
            if !set.contains($0) {
                
            }
        }
    }
    
}

extension PathValidator where Value: Equatable {
    
    public func equal(to value: Value) -> Self {
        return push {
            if $0 != value {
                
            }
        }
    }
    
}

extension PathValidator where Value == Bool {
    
    public func equalsFalse() -> Self {
        return self.equal(to: false)
    }
    
    public func equalsTrue() -> Self {
        return self.equal(to: true)
    }
    
}

extension PathValidator where Value: Comparable {
    
    public func between(min: Value, max: Value) -> Self {
        return push {
            if $0 < min || $0 > max {
                
            }
        }
    }
    
    public func lessThan(_ value: Value) -> Self {
        return push {
            if $0 >= value {
                
            }
        }
    }
    
    public func lessThanEqual(_ value: Value) -> Self {
        return push {
            if $0 > value {
                
            }
        }
    }
    
    public func greaterThan(_ value: Value) -> Self {
        return push {
            if $0 <= value {
                
            }
        }
    }
    
    public func greaterThanEqual(_ value: Value) -> Self {
        return push {
            if $0 < value {
                
            }
        }
    }
    
}

extension PathValidator where Value: Collection {
    
    public func minLength(_ length: Int) -> Self {
        return push {
            if $0.count < length {
                
            }
        }
    }
    
    public func maxLength(_ length: Int) -> Self {
        return push {
            if $0.count > length {
                
            }
        }
    }
    
}

extension PathValidator where Value: StringProtocol {
    
    public func alpha() -> Self {
        return push {
            if nil != $0.first(where: { !$0.isLetter }) {
                
            }
        }
    }
    
    public func alphadash() -> Self {
        return push {
            if nil != $0.first(where: { !$0.isLetter && !$0.isNumber && $0 != "_" && $0 != "-" }) {
                
            }
        }
    }
    
    public func alphanumeric() -> Self {
        return push {
            if nil != $0.first(where: { !$0.isLetter && !$0.isNumber }) {
                
            }
        }
    }
    
}
