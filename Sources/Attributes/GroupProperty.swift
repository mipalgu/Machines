//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

@propertyWrapper
public struct GroupProperty {
    
    public var projectedValue: GroupProperty {
        self
    }
    
    public var wrappedValue: SchemaAttribute<AttributeGroup>
    
    public init(wrappedValue: SchemaAttribute<AttributeGroup>) {
        self.wrappedValue = wrappedValue
    }
    
    public init(
        label: String,
        available: Bool = true,
        @TriggerBuilder<AttributeGroup> trigger triggerBuilder: @escaping () -> [AnyTrigger<AttributeGroup>] = { [] },
        type: AttributeType,
        @ValidatorBuilder<AttributeGroup> validate validatorBuilder: @escaping () -> [AnyValidator<AttributeGroup>] = { [] }
    ) {
        let attribute: SchemaAttribute<AttributeGroup> = SchemaAttribute(
            available: available,
            label: label,
            trigger: AnyTrigger(triggerBuilder()),
            type: type,
            validate: AnyValidator(validatorBuilder())
        )
        self.init(wrappedValue: attribute)
    }
    
    public init(
        label: String,
        available: Bool = true,
        @TriggerBuilder<AttributeGroup> trigger triggerBuilder: @escaping () -> [AnyTrigger<AttributeGroup>] = { [] },
        type: AttributeType,
        validate: AnyValidator<Attribute>
    ) {
        let path = ReadOnlyPath<AttributeGroup, AttributeGroup>(keyPath: \.self, ancestors: [])
        let attribute: SchemaAttribute<AttributeGroup> = SchemaAttribute(
            available: available,
            label: label,
            trigger: AnyTrigger(triggerBuilder()),
            type: type,
            validate: AnyValidator<AttributeGroup>(ChainValidator(path: path.attributes[label].wrappedValue, validator: validate))
        )
        self.init(wrappedValue: attribute)
    }
    
}
