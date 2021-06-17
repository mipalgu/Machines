/*
 * Attributable.swift
 * 
 *
 * Created by Callum McColl on 12/6/21.
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

public protocol Attributable {
    
    associatedtype Root: Modifiable
    associatedtype AttributeRoot
    
    var path: Path<Root, AttributeRoot> { get }
    
    var pathToAttributes: Path<AttributeRoot, [String: Attribute]> { get }

    var properties: [SchemaAttribute<AttributeRoot>] { get }
    
    var propertiesValidator: AnyValidator<AttributeRoot> { get }
    
    var triggers: AnyTrigger<Root> { get }
    
    var extraValidation: AnyValidator<AttributeRoot> { get }
    
}

public extension Attributable {
    
    typealias BoolProperty = Attributes.BoolProperty<AttributeRoot>
    typealias IntegerProperty = Attributes.IntegerProperty<AttributeRoot>
    typealias ComplexProperty<Base> = Attributes.ComplexProperty<AttributeRoot, Base> where Base: ComplexProtocol, Base.Root == AttributeRoot
    
    var triggers: AnyTrigger<Root> {
        AnyTrigger<Root>()
    }
    
    var extraValidation: AnyValidator<AttributeRoot> {
        AnyValidator<AttributeRoot>()
    }
    
    var validate: ValidationPath<ReadOnlyPath<AttributeRoot, AttributeRoot>> {
        ValidationPath(path: ReadOnlyPath(keyPath: \.self, ancestors: []))
    }
    
    var properties: [SchemaAttribute<AttributeRoot>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = $0.value as? BoolProperty {
                return val.wrappedValue
            }
            if let val = $0.value as? IntegerProperty {
                return val.wrappedValue
            }
            if let val = $0.value as? SchemaAttributeConvertible, let attribute = val.schemaAttribute as? SchemaAttribute<AttributeRoot> {
                return attribute
            }
            return nil
        }
    }
    
    var propertiesValidator: AnyValidator<AttributeRoot>  {
        let propertyValidators = properties.map(\.validate)
        return AnyValidator(propertyValidators + [AnyValidator(extraValidation)])
    }
    
    func findProperty<Path: PathProtocol>(path: Path) -> SchemaAttribute<Path.Root>? where Path.Root == Root {
        guard let index = path.fullPath.firstIndex(where: { $0.partialKeyPath == self.path.keyPath }) else {
            return nil
        }
        let subpath = path.fullPath[index..<path.fullPath.count]
        if subpath.count > 2 {
            //complex?
            return nil
        }
        if subpath.count == 2 {
            //property of me
            return properties.first {
                path.keyPath == self.path.keyPath.appending(path: pathToAttributes.keyPath.appending(path: \.[$0.label]))
            }?.toNewRoot(path: self.path)
        }
        //itsa me
        return nil
    }
    
    func path(for attribute: SchemaAttribute<AttributeRoot>) -> Path<Root, Attribute> {
        self.path.appending(path: self.pathToAttributes)[attribute.label].wrappedValue
    }
    
    func WhenChanged(_ attribute: SchemaAttribute<AttributeRoot>) -> Attributes.WhenChanged<Path<Root, Attribute>, IdentityTrigger<Root>> {
        Attributes.WhenChanged(path(for: attribute))
    }
    
}
