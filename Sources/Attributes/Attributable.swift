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
    
    var pathToAttributes: KeyPath<AttributeRoot, [String: Attribute]> { get }

    var properties: [SchemaProperty<AttributeRoot>] { get }
    
    var propertiesValidator: AnyValidator<AttributeRoot> { get }
    
    @TriggerBuilder<AttributeGroup>
    var triggers: AnyTrigger<AttributeRoot> { get }
    
    @ValidatorBuilder<AttributeGroup>
    var extraValidation: AnyValidator<AttributeRoot> { get }
    
}

public extension Attributable {
    
    typealias BoolProperty = Attributes.BoolProperty<AttributeRoot>
    typealias IntegerProperty = Attributes.IntegerProperty<AttributeRoot>
    
    @TriggerBuilder<AttributeGroup>
    var triggers: AnyTrigger<AttributeGroup> {
        AnyTrigger<AttributeGroup>()
    }
    
    @ValidatorBuilder<AttributeGroup>
    var extraValidation: AnyValidator<AttributeGroup> {
        AnyValidator<AttributeGroup>()
    }
    
    var validate: ValidationPath<ReadOnlyPath<AttributeRoot, AttributeRoot>> {
        ValidationPath(path: ReadOnlyPath(keyPath: \.self, ancestors: []))
    }
    
    var properties: [SchemaProperty<AttributeRoot>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = $0.value as? BoolProperty {
                return .property(val.wrappedValue)
            }
            if let val = $0.value as? IntegerProperty {
                return .property(val.wrappedValue)
            }
            return nil
        }
    }
    
    private func propertyToValidator(property: SchemaProperty<AttributeRoot>) -> AnyValidator<AttributeRoot> {
        switch property {
        case .property(let attribute):
            return attribute.validate
        }
    }
    
    var propertiesValidator: AnyValidator<AttributeRoot>  {
        let propertyValidators = properties.map {
            propertyToValidator(property: $0)
        }
        return AnyValidator(propertyValidators + [AnyValidator(extraValidation)])
    }
    
    func findProperty<Path: PathProtocol>(path: Path) -> SchemaProperty<Path.Root>? where Path.Root == Root {
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
                switch $0 {
                case .property(let attribute):
                    return self.path.keyPath.appending(path: pathToAttributes.appending(path: \.[attribute.label])) == path.keyPath
                }
            }?.toNewRoot(path: self.path)
        }
        //itsa me
        return nil
    }
    
}
