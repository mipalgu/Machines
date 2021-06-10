//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

//var path: Path<Root, AttributeGroup> { get }
//
//var properties: [SchemaProperty<AttributeGroup>] { get }
//
//var propertiesValidator: AnyValidator<AttributeGroup> { get }
//
//@ValidatorBuilder<Root>
//var extraValidation: [AnyValidator<Root>] { get }

public struct AnyGroup<Root: Modifiable>: GroupProtocol {
    
    private let _path: () -> Path<Root, AttributeGroup>
    
    private let _properties: () -> [SchemaProperty<AttributeGroup>]
    
    private let _propertiesValidator: () -> AnyValidator<AttributeGroup>
    
    private let _extraValidation: () -> AnyValidator<AttributeGroup>
    
    let base: Any
    
    public var path: Path<Root, AttributeGroup> {
        _path()
    }
    
    public var properties: [SchemaProperty<AttributeGroup>] {
        _properties()
    }
    
    public var propertiesValidator: AnyValidator<AttributeGroup> {
        self._propertiesValidator()
    }
    
    public var extraValidation: AnyValidator<AttributeGroup> {
        return self._extraValidation()
    }
    
    public init<Base: GroupProtocol>(_ base: Base) where Base.Root == Root {
        self._path = { base.path }
        self._properties = { base.properties }
        self._propertiesValidator = { base.propertiesValidator }
        self._extraValidation = { AnyValidator(base.extraValidation) }
        self.base = base
    }
    
}
