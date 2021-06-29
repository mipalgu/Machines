/*
 * TableProperty.swift
 * Attributes
 *
 * Created by Callum McColl on 21/6/21.
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

@propertyWrapper
public struct TableProperty {
    
    public var projectedValue: TableProperty {
        self
    }
    
    public var wrappedValue: SchemaAttribute
    
    public init(wrappedValue: SchemaAttribute) {
        self.wrappedValue = wrappedValue
    }
    
    public init(
        label: String,
        columns: [TableColumn],
        available: Bool = true,
        validation validatorFactories: ValidatorFactory<[[LineAttribute]]> ...
    ) {
        let path = ReadOnlyPath(keyPath: \Attribute.self, ancestors: []).blockAttribute.tableValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        let attribute: SchemaAttribute = SchemaAttribute(
            available: available,
            label: label,
            type: .table(columns: columns.map { ($0.label, $0.type) }),
            validate: validator
        )
        self.init(wrappedValue: attribute)
    }
    
}

public struct TableColumn {
    
    public var label: String
    
    public var type: LineAttributeType
    
    public var validator: AnyValidator<LineAttribute>
    
    private init(label: String, type: LineAttributeType, validator: AnyValidator<LineAttribute>) {
        self.label = label
        self.type = type
        self.validator = validator
    }
    
    public static func bool(label: String, validation validatorFactories: ValidatorFactory<Bool> ...) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).boolValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .bool, validator: validator)
    }
    
    public static func integer(label: String, validation validatorFactories: ValidatorFactory<Int> ...) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).integerValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .integer, validator: validator)
    }
    
    public static func float(label: String, validation validatorFactories: ValidatorFactory<Double> ...) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).floatValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .float, validator: validator)
    }
    
    public static func expression(label: String, language: Language, validation validatorFactories: ValidatorFactory<Expression> ...) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).expressionValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .expression(language: language), validator: validator)
    }
    
    public static func enumerated(label: String, validValues: Set<String>, validation validatorFactories: ValidatorFactory<String> ...) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).enumeratedValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .enumerated(validValues: validValues), validator: validator)
    }
    
    public static func line(label: String, validation validatorFactories: ValidatorFactory<String> ...) -> TableColumn {
        let path = ReadOnlyPath(keyPath: \LineAttribute.self, ancestors: []).lineValue
        let validator = AnyValidator(validatorFactories.map { $0.make(path: path) })
        return Self(label: label, type: .line, validator: validator)
    }
    
}
