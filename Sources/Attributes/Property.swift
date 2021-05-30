//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

@propertyWrapper
struct Property<Root: Modifiable, Schema: SchemaProtocol> {
    
    var projectedValue: Property<Root, Schema> {
        self
    }
    
    var wrappedValue: SchemaAttribute<Root, Schema>
    
    init(wrappedValue: SchemaAttribute<Root, Schema>) {
        self.wrappedValue = wrappedValue
    }
    
    init(available: Bool, type: AttributeType, validate: AnyValidator<Root>) {
        let attribute: SchemaAttribute<Root, Schema> = SchemaAttribute(available: available, type: type, validate: validate)
        self.init(wrappedValue: attribute)
    }
    
}
