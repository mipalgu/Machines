//
/*
 * AttributePath.swift
 * Attributes
 *
 * Created by Callum McColl on 7/11/20.
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

extension ReadOnlyPathProtocol where Value == Attribute {
    
    public var type: ReadOnlyPath<Root, AttributeType> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.type), ancestors: fullPath)
    }
    
    public var boolValue: ReadOnlyPath<Root, Bool?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.boolValue), ancestors: fullPath)
    }
    
    public var integerValue: ReadOnlyPath<Root, Int?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.integerValue), ancestors: fullPath)
    }
    
    public var floatValue: ReadOnlyPath<Root, Double?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.floatValue), ancestors: fullPath)
    }
    
    public var expressionValue: ReadOnlyPath<Root, Expression?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.expressionValue), ancestors: fullPath)
    }
    
    public var enumeratedValue: ReadOnlyPath<Root, String?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.enumeratedValue), ancestors: fullPath)
    }
    
    public var lineValue: ReadOnlyPath<Root, String?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.lineValue), ancestors: fullPath)
    }
    
    public var codeValue: ReadOnlyPath<Root, String?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.codeValue), ancestors: fullPath)
    }
    
    public var textValue: ReadOnlyPath<Root, String?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.textValue), ancestors: fullPath)
    }
    
    public var collectionValue: ReadOnlyPath<Root, [Attribute]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionValue), ancestors: fullPath)
    }
    
    public var complexValue: ReadOnlyPath<Root, [String: Attribute]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.complexValue), ancestors: fullPath)
    }
    
    public var enumerableCollectionValue: ReadOnlyPath<Root, Set<String>?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.enumerableCollectionValue), ancestors: fullPath)
    }
    
    public var collectionBools: ReadOnlyPath<Root, [Bool]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionBools), ancestors: fullPath)
    }
    
    public var collectionIntegers: ReadOnlyPath<Root, [Int]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionIntegers), ancestors: fullPath)
    }
    
    public var collectionFloats: ReadOnlyPath<Root, [Double]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionFloats), ancestors: fullPath)
    }
    
    public var collectionExpressions: ReadOnlyPath<Root, [Expression]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionExpressions), ancestors: fullPath)
    }
    
    public var collectionEnumerated: ReadOnlyPath<Root, [String]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionEnumerated), ancestors: fullPath)
    }
    
    public var collectionLines: ReadOnlyPath<Root, [String]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionLines), ancestors: fullPath)
    }
    
    public var collectionCode: ReadOnlyPath<Root, [String]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionCode), ancestors: fullPath)
    }
    
    public var collectionText: ReadOnlyPath<Root, [String]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionText), ancestors: fullPath)
    }
    
    public var collectionComplex: ReadOnlyPath<Root, [[String: Attribute]]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionComplex), ancestors: fullPath)
    }
    
    public var collectionEnumerableCollection: ReadOnlyPath<Root, [Set<String>]?> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionEnumerableCollection), ancestors: fullPath)
    }
    
}

extension ValidationPath where Value == Attribute {
    
    public var type: ValidationPath<ReadOnlyPath<Root, AttributeType>> {
        return ValidationPath<ReadOnlyPath<Root, AttributeType>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.type), ancestors: path.fullPath))
    }
    
    public var boolValue: ValidationPath<ReadOnlyPath<Root, Bool?>> {
        return ValidationPath<ReadOnlyPath<Root, Bool?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.boolValue), ancestors: path.fullPath))
    }
    
    public var integerValue: ValidationPath<ReadOnlyPath<Root, Int?>> {
        return ValidationPath<ReadOnlyPath<Root, Int?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.integerValue), ancestors: path.fullPath))
    }
    
    public var floatValue: ValidationPath<ReadOnlyPath<Root, Double?>> {
        return ValidationPath<ReadOnlyPath<Root, Double?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.floatValue), ancestors: path.fullPath))
    }
    
    public var expressionValue: ValidationPath<ReadOnlyPath<Root, Expression?>> {
        return ValidationPath<ReadOnlyPath<Root, Expression?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.expressionValue), ancestors: path.fullPath))
    }
    
    public var enumeratedValue: ValidationPath<ReadOnlyPath<Root, String?>> {
        return ValidationPath<ReadOnlyPath<Root, String?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.enumeratedValue), ancestors: path.fullPath))
    }
    
    public var lineValue: ValidationPath<ReadOnlyPath<Root, String?>> {
        return ValidationPath<ReadOnlyPath<Root, String?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.lineValue), ancestors: path.fullPath))
    }
    
    public var codeValue: ValidationPath<ReadOnlyPath<Root, String?>> {
        return ValidationPath<ReadOnlyPath<Root, String?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.codeValue), ancestors: path.fullPath))
    }
    
    public var textValue: ValidationPath<ReadOnlyPath<Root, String?>> {
        return ValidationPath<ReadOnlyPath<Root, String?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.textValue), ancestors: path.fullPath))
    }
    
    public var collectionValue: ValidationPath<ReadOnlyPath<Root, [Attribute]?>> {
        return ValidationPath<ReadOnlyPath<Root, [Attribute]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionValue), ancestors: path.fullPath))
    }
    
    public var complexValue: ValidationPath<ReadOnlyPath<Root, [String: Attribute]?>> {
        return ValidationPath<ReadOnlyPath<Root, [String: Attribute]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.complexValue), ancestors: path.fullPath))
    }
    
    public var enumerableCollectionValue: ValidationPath<ReadOnlyPath<Root, Set<String>?>> {
        return ValidationPath<ReadOnlyPath<Root, Set<String>?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.enumerableCollectionValue), ancestors: path.fullPath))
    }
    
    public var collectionBools: ValidationPath<ReadOnlyPath<Root, [Bool]?>> {
        return ValidationPath<ReadOnlyPath<Root, [Bool]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionBools), ancestors: path.fullPath))
    }
    
    public var collectionIntegers: ValidationPath<ReadOnlyPath<Root, [Int]?>> {
        return ValidationPath<ReadOnlyPath<Root, [Int]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionIntegers), ancestors: path.fullPath))
    }
    
    public var collectionFloats: ValidationPath<ReadOnlyPath<Root, [Double]?>> {
        return ValidationPath<ReadOnlyPath<Root, [Double]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionFloats), ancestors: path.fullPath))
    }
    
    public var collectionExpressions: ValidationPath<ReadOnlyPath<Root, [Expression]?>> {
        return ValidationPath<ReadOnlyPath<Root, [Expression]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionExpressions), ancestors: path.fullPath))
    }
    
    public var collectionEnumerated: ValidationPath<ReadOnlyPath<Root, [String]?>> {
        return ValidationPath<ReadOnlyPath<Root, [String]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionEnumerated), ancestors: path.fullPath))
    }
    
    public var collectionLines: ValidationPath<ReadOnlyPath<Root, [String]?>> {
        return ValidationPath<ReadOnlyPath<Root, [String]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionLines), ancestors: path.fullPath))
    }
    
    public var collectionCode: ValidationPath<ReadOnlyPath<Root, [String]?>> {
        return ValidationPath<ReadOnlyPath<Root, [String]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionCode), ancestors: path.fullPath))
    }
    
    public var collectionText: ValidationPath<ReadOnlyPath<Root, [String]?>> {
        return ValidationPath<ReadOnlyPath<Root, [String]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionText), ancestors: path.fullPath))
    }
    
    public var collectionComplex: ValidationPath<ReadOnlyPath<Root, [[String: Attribute]]?>> {
        return ValidationPath<ReadOnlyPath<Root, [[String: Attribute]]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionComplex), ancestors: path.fullPath))
    }
    
    public var collectionEnumerableCollection: ValidationPath<ReadOnlyPath<Root, [Set<String>]?>> {
        return ValidationPath<ReadOnlyPath<Root, [Set<String>]?>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionEnumerableCollection), ancestors: path.fullPath))
    }
    
}
