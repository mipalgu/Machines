//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct SchemaAttribute {
    
    public var label: String
    
    public var type: AttributeType
    
    public var validate: AnyValidator<Attribute>
    
    public init(label: String, type: AttributeType, validate: AnyValidator<Attribute> = AnyValidator()) {
        self.label = label
        self.type = type
        self.validate = validate
    }
    
}
