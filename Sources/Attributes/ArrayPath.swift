/*
 * ArrayPath.swift
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

import Foundation

extension ReadOnlyPathProtocol where Value: Collection, Value.Index: BinaryInteger {
    
    subscript(index: Value.Index) -> ReadOnlyPath<Root, Value.Element> {
        return ReadOnlyPath<Root, Value.Element>(
            keyPath: self.keyPath.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)],
            isNil: { root in root[keyPath: keyPath].count <= index }
        )
    }
    
}

extension PathProtocol where Value: MutableCollection, Value.Index: BinaryInteger {
    
    subscript(index: Value.Index) -> Path<Root, Value.Element> {
        return Path<Root, Value.Element>(
            path: self.path.appending(path: \.[index]),
            ancestors: self.ancestors + [AnyPath(self)],
            isNil: { root in root[keyPath: self.path].count <= index }
        )
    }
    
}

extension Path where Value: MutableCollection, Value.Index: Hashable {
    
    public func each<T>(_ f: @escaping (Value.Index, Path<Root, Value.Element>) -> T) -> (Root) -> [T] {
        return { root in
            root[keyPath: self.path].indices.map {
                return f($0, self[$0])
            }
        }
    }
    
}

extension ValidationPath where P.Value: Collection, P.Value.Index: Hashable {
    
    public func each(@ValidatorBuilder<Root> builder: @escaping (Value.Index, ValidationPath<ReadOnlyPath<Root, Value.Element>>) -> [AnyValidator<Root>]) -> PushValidator {
        return push { (root, value) in
            let validators: [AnyValidator<Root>] = value.indices.flatMap { (index) -> [AnyValidator<Root>] in
                return builder(
                    index,
                    ValidationPath<ReadOnlyPath<Root, Value.Element>>(
                        path: ReadOnlyPath<Root, Value.Element>(
                            keyPath: self.path.keyPath.appending(path: \.[index]),
                            ancestors: self.path.fullPath
                        )
                    )
                )
            }
            return try AnyValidator<Root>(validators).performValidation(root)
        }
    }
    
}
