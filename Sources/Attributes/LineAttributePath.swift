//
//  LineAttributePath.swift
//  
//
//  Created by Morgan McColl on 14/11/20.
//

extension ReadOnlyPathProtocol where Value == LineAttribute {
    
    public var type: ReadOnlyPath<Root, LineAttributeType> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.type), ancestors: fullPath)
    }
    
    public var boolValue: ReadOnlyPath<Root, Bool> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.boolValue), ancestors: fullPath)
    }
    
    public var integerValue: ReadOnlyPath<Root, Int> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.integerValue), ancestors: fullPath)
    }
    
    public var floatValue: ReadOnlyPath<Root, Double> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.floatValue), ancestors: fullPath)
    }
    
    public var expressionValue: ReadOnlyPath<Root, Expression> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.expressionValue), ancestors: fullPath)
    }
    
    public var enumeratedValue: ReadOnlyPath<Root, String> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.enumeratedValue), ancestors: fullPath)
    }
    
    public var lineValue: ReadOnlyPath<Root, String> {
        return ReadOnlyPath(keyPath: keyPath.appending(path: \.lineValue), ancestors: fullPath)
    }
    
}

extension PathProtocol where Value == LineAttribute {
    
    public var boolValue: Path<Root, Bool> {
        return Path(path: path.appending(path: \.boolValue), ancestors: fullPath)
    }
    
    public var integerValue: Path<Root, Int> {
        return Path(path: path.appending(path: \.integerValue), ancestors: fullPath)
    }
    
    public var floatValue: Path<Root, Double> {
        return Path(path: path.appending(path: \.floatValue), ancestors: fullPath)
    }
    
    public var expressionValue: Path<Root, Expression> {
        return Path(path: path.appending(path: \.expressionValue), ancestors: fullPath)
    }
    
    public var enumeratedValue: Path<Root, String> {
        return Path(path: path.appending(path: \.enumeratedValue), ancestors: fullPath)
    }
    
    public var lineValue: Path<Root, String> {
        return Path(path: path.appending(path: \.lineValue), ancestors: fullPath)
    }
    
}

extension ValidationPath where Value == LineAttribute {
    
    public var type: ValidationPath<ReadOnlyPath<Root, LineAttributeType>> {
        return ValidationPath<ReadOnlyPath<Root, LineAttributeType>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.type), ancestors: path.fullPath))
    }
    
    public var boolValue: ValidationPath<ReadOnlyPath<Root, Bool>> {
        return ValidationPath<ReadOnlyPath<Root, Bool>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.boolValue), ancestors: path.fullPath))
    }
    
    public var integerValue: ValidationPath<ReadOnlyPath<Root, Int>> {
        return ValidationPath<ReadOnlyPath<Root, Int>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.integerValue), ancestors: path.fullPath))
    }
    
    public var floatValue: ValidationPath<ReadOnlyPath<Root, Double>> {
        return ValidationPath<ReadOnlyPath<Root, Double>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.floatValue), ancestors: path.fullPath))
    }
    
    public var expressionValue: ValidationPath<ReadOnlyPath<Root, Expression>> {
        return ValidationPath<ReadOnlyPath<Root, Expression>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.expressionValue), ancestors: path.fullPath))
    }
    
    public var enumeratedValue: ValidationPath<ReadOnlyPath<Root, String>> {
        return ValidationPath<ReadOnlyPath<Root, String>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.enumeratedValue), ancestors: path.fullPath))
    }
    
    public var lineValue: ValidationPath<ReadOnlyPath<Root, String>> {
        return ValidationPath<ReadOnlyPath<Root, String>>(path: ReadOnlyPath(keyPath: path.keyPath.appending(path: \.lineValue), ancestors: path.fullPath))
    }
    
}
