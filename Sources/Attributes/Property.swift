//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

@propertyWrapper
struct Property<Root: Modifiable> {
    
    var projectedValue: Property<Root> {
        self
    }
    
    var wrappedValue: SchemaAttribute<Root>
    
    init(wrappedValue: SchemaAttribute<Root>) {
        self.wrappedValue = wrappedValue
    }
    
    init(
        available: Bool,
        @TriggerBuilder<Root> trigger triggerBuilder: @escaping () -> [AnyTrigger<Root>] = { [] },
        type: AttributeType,
        @ValidatorBuilder<Root> validate validatorBuilder: @escaping () -> [AnyValidator<Root>] = { [] }
    ) {
        let attribute: SchemaAttribute<Root> = SchemaAttribute(
            available: available,
            trigger: AnyTrigger(triggerBuilder()),
            type: type,
            validate: AnyValidator(validatorBuilder())
        )
        self.init(wrappedValue: attribute)
    }
    
}
