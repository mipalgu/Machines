//
//  BlockAttributePath.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

extension ReadOnlyPathProtocol where Value == BlockAttribute {
    
    public var type: ReadOnlyPath<Root, BlockAttributeType> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.type), ancestors: fullPath)
    }
    
    public var codeValue: ReadOnlyPath<Root, String> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.codeValue), ancestors: fullPath)
    }
    
    public var textValue: ReadOnlyPath<Root, String> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.textValue), ancestors: fullPath)
    }
    
    public var collectionValue: ReadOnlyPath<Root, [Attribute]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionValue), ancestors: fullPath)
    }
    
    public var complexValue: ReadOnlyPath<Root, [String: Attribute]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.complexValue), ancestors: fullPath)
    }
    
    public var enumerableCollectionValue: ReadOnlyPath<Root, Set<String>> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.enumerableCollectionValue), ancestors: fullPath)
    }
    
    public var tableValue: ReadOnlyPath<Root, [[LineAttribute]]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.tableValue), ancestors: fullPath)
    }
    
    public var collectionBools: ReadOnlyPath<Root, [Bool]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionBools), ancestors: fullPath)
    }
    
    public var collectionIntegers: ReadOnlyPath<Root, [Int]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionIntegers), ancestors: fullPath)
    }
    
    public var collectionFloats: ReadOnlyPath<Root, [Double]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionFloats), ancestors: fullPath)
    }
    
    public var collectionExpressions: ReadOnlyPath<Root, [Expression]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionExpressions), ancestors: fullPath)
    }
    
    public var collectionEnumerated: ReadOnlyPath<Root, [String]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionEnumerated), ancestors: fullPath)
    }
    
    public var collectionLines: ReadOnlyPath<Root, [String]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionLines), ancestors: fullPath)
    }
    
    public var collectionCode: ReadOnlyPath<Root, [String]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionCode), ancestors: fullPath)
    }
    
    public var collectionText: ReadOnlyPath<Root, [String]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionText), ancestors: fullPath)
    }
    
    public var collectionComplex: ReadOnlyPath<Root, [[String: Attribute]]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionComplex), ancestors: fullPath)
    }
    
    public var collectionEnumerableCollection: ReadOnlyPath<Root, [Set<String>]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionEnumerableCollection), ancestors: fullPath)
    }
    
    public var collectionTable: ReadOnlyPath<Root, [[[LineAttribute]]]> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.collectionTable), ancestors: fullPath)
    }
    
}

extension PathProtocol where Value == BlockAttribute {
    
    public var codeValue: Path<Root, String> {
        return Path(path: path.appending(path: \.codeValue), ancestors: fullPath)
    }
    
    public var textValue: Path<Root, String> {
        return Path(path: path.appending(path: \.textValue), ancestors: fullPath)
    }
    
    public var collectionValue: Path<Root, [Attribute]> {
        return Path(path: path.appending(path: \.collectionValue), ancestors: fullPath)
    }
    
    public var complexValue: Path<Root, [String: Attribute]> {
        return Path(path: path.appending(path: \.complexValue), ancestors: fullPath)
    }
    
    public var enumerableCollectionValue: Path<Root, Set<String>> {
        return Path(path: path.appending(path: \.enumerableCollectionValue), ancestors: fullPath)
    }
    
    public var tableValue: Path<Root, [[LineAttribute]]> {
        return Path(path: path.appending(path: \.tableValue), ancestors: fullPath)
    }
    
    public var collectionBools: Path<Root, [Bool]> {
        return Path(path: path.appending(path: \.collectionBools), ancestors: fullPath)
    }
    
    public var collectionIntegers: Path<Root, [Int]> {
        return Path(path: path.appending(path: \.collectionIntegers), ancestors: fullPath)
    }
    
    public var collectionFloats: Path<Root, [Double]> {
        return Path(path: path.appending(path: \.collectionFloats), ancestors: fullPath)
    }
    
    public var collectionExpressions: Path<Root, [Expression]> {
        return Path(path: path.appending(path: \.collectionExpressions), ancestors: fullPath)
    }
    
    public var collectionEnumerated: Path<Root, [String]> {
        return Path(path: path.appending(path: \.collectionEnumerated), ancestors: fullPath)
    }
    
    public var collectionLines: Path<Root, [String]> {
        return Path(path: path.appending(path: \.collectionLines), ancestors: fullPath)
    }
    
    public var collectionCode: Path<Root, [String]> {
        return Path(path: path.appending(path: \.collectionCode), ancestors: fullPath)
    }
    
    public var collectionText: Path<Root, [String]> {
        return Path(path: path.appending(path: \.collectionText), ancestors: fullPath)
    }
    
    public var collectionComplex: Path<Root, [[String: Attribute]]> {
        return Path(path: path.appending(path: \.collectionComplex), ancestors: fullPath)
    }
    
    public var collectionEnumerableCollection: Path<Root, [Set<String>]> {
        return Path(path: path.appending(path: \.collectionEnumerableCollection), ancestors: fullPath)
    }
    
    public var collectionTable: Path<Root, [[[LineAttribute]]]> {
        return Path(path: path.appending(path: \.collectionTable), ancestors: fullPath)
    }
    
}

extension ValidationPath where Value == BlockAttribute {
    
    public var codeValue: ValidationPath<ReadOnlyPath<Root, String>> {
        return ValidationPath<ReadOnlyPath<Root, String>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.codeValue), ancestors: path.fullPath))
    }
    
    public var textValue: ValidationPath<ReadOnlyPath<Root, String>> {
        return ValidationPath<ReadOnlyPath<Root, String>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.textValue), ancestors: path.fullPath))
    }
    
    public var collectionValue: ValidationPath<ReadOnlyPath<Root, [Attribute]>> {
        return ValidationPath<ReadOnlyPath<Root, [Attribute]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionValue), ancestors: path.fullPath))
    }
    
    public var complexValue: ValidationPath<ReadOnlyPath<Root, [String: Attribute]>> {
        return ValidationPath<ReadOnlyPath<Root, [String: Attribute]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.complexValue), ancestors: path.fullPath))
    }
    
    public var enumerableCollectionValue: ValidationPath<ReadOnlyPath<Root, Set<String>>> {
        return ValidationPath<ReadOnlyPath<Root, Set<String>>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.enumerableCollectionValue), ancestors: path.fullPath))
    }
    
    public var tableValue: ValidationPath<ReadOnlyPath<Root, [[LineAttribute]]>> {
        return ValidationPath<ReadOnlyPath<Root, [[LineAttribute]]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.tableValue), ancestors: path.fullPath))
    }
    
    public var collectionBools: ValidationPath<ReadOnlyPath<Root, [Bool]>> {
        return ValidationPath<ReadOnlyPath<Root, [Bool]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionBools), ancestors: path.fullPath))
    }
    
    public var collectionIntegers: ValidationPath<ReadOnlyPath<Root, [Int]>> {
        return ValidationPath<ReadOnlyPath<Root, [Int]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionIntegers), ancestors: path.fullPath))
    }
    
    public var collectionFloats: ValidationPath<ReadOnlyPath<Root, [Double]>> {
        return ValidationPath<ReadOnlyPath<Root, [Double]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionFloats), ancestors: path.fullPath))
    }
    
    public var collectionExpressions: ValidationPath<ReadOnlyPath<Root, [Expression]>> {
        return ValidationPath<ReadOnlyPath<Root, [Expression]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionExpressions), ancestors: path.fullPath))
    }
    
    public var collectionEnumerated: ValidationPath<ReadOnlyPath<Root, [String]>> {
        return ValidationPath<ReadOnlyPath<Root, [String]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionEnumerated), ancestors: path.fullPath))
    }
    
    public var collectionLines: ValidationPath<ReadOnlyPath<Root, [String]>> {
        return ValidationPath<ReadOnlyPath<Root, [String]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionLines), ancestors: path.fullPath))
    }
    
    public var collectionCode: ValidationPath<ReadOnlyPath<Root, [String]>> {
        return ValidationPath<ReadOnlyPath<Root, [String]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionCode), ancestors: path.fullPath))
    }
    
    public var collectionText: ValidationPath<ReadOnlyPath<Root, [String]>> {
        return ValidationPath<ReadOnlyPath<Root, [String]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionText), ancestors: path.fullPath))
    }
    
    public var collectionComplex: ValidationPath<ReadOnlyPath<Root, [[String: Attribute]]>> {
        return ValidationPath<ReadOnlyPath<Root, [[String: Attribute]]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionComplex), ancestors: path.fullPath))
    }
    
    public var collectionEnumerableCollection: ValidationPath<ReadOnlyPath<Root, [Set<String>]>> {
        return ValidationPath<ReadOnlyPath<Root, [Set<String>]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionEnumerableCollection), ancestors: path.fullPath))
    }
    
    public var collectionTable: ValidationPath<ReadOnlyPath<Root, [[[LineAttribute]]]>> {
        return ValidationPath<ReadOnlyPath<Root, [[[LineAttribute]]]>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.collectionTable), ancestors: path.fullPath))
    }
    
}
