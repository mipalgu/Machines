//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

@propertyWrapper
struct GroupProperty {
    
    var projectedValue: GroupProperty {
        self
    }
    
    var wrappedValue: SchemaAttribute<AttributeGroup>
    
    init(wrappedValue: SchemaAttribute<AttributeGroup>) {
        self.wrappedValue = wrappedValue
    }
    
    init(
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
    
}

@propertyWrapper
struct GroupBoolProperty {
    
    var projectedValue: GroupBoolProperty {
        self
    }
    
    var wrappedValue: SchemaAttribute<AttributeGroup>
    
    init(wrappedValue: SchemaAttribute<AttributeGroup>) {
        self.wrappedValue = wrappedValue
    }
    
    init(label: String, available: Bool = true, @TriggerBuilder<AttributeGroup> trigger triggerBuilder: @escaping () -> [AnyTrigger<AttributeGroup>] = { [] }) {
        self.init(
            label: label,
            available: available,
            trigger: AnyTrigger(triggerBuilder()),
            validator: Path(path: \AttributeGroup.self, ancestors: []).attributes[label].validate {
                $0.required()
            }
        )
    }
    
    init(label: String, available: Bool = true, @TriggerBuilder<AttributeGroup> trigger triggerBuilder: @escaping () -> [AnyTrigger<AttributeGroup>] = { [] }, @ValidatorBuilder<AttributeGroup> validate validatorBuilder: @escaping () -> [AnyValidator<AttributeGroup>] = { [] }) {
        self.init(label: label, available: available, trigger: AnyTrigger(triggerBuilder()), validator: AnyValidator(validatorBuilder()))
    }
    
    private init(
        label: String,
        available: Bool = true,
        trigger: AnyTrigger<AttributeGroup>,
        validator: AnyValidator<AttributeGroup>
    ) {
        let attribute: SchemaAttribute<AttributeGroup> = SchemaAttribute(
            available: available,
            label: label,
            trigger: trigger,
            type: .bool,
            validate: validator
        )
        self.init(wrappedValue: attribute)
    }
    
}
