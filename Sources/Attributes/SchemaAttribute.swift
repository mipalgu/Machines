//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct SchemaAttribute {
    
    public var available: Bool
    
    public var label: String
    
    public var type: AttributeType
    
    public var validate: AnyValidator<Attribute>
    
    public init(available: Bool, label: String, type: AttributeType, validate: AnyValidator<Attribute> = AnyValidator()) {
        self.available = available
        self.label = label
        self.type = type
        self.validate = validate
    }
    
}
