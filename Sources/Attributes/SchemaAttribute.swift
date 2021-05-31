//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct SchemaAttribute<Root> {
    
    var available: Bool
    
    var label: String
    
    var trigger: AnyTrigger<Root>
    
    var type: AttributeType
    
    var validate: AnyValidator<Root>
    
    public init(available: Bool, label: String, trigger: AnyTrigger<Root>, type: AttributeType, validate: AnyValidator<Root>) {
        self.available = available
        self.label = label
        self.trigger = trigger
        self.type = type
        self.validate = validate
    }
    
    func toNewRoot<Path: PathProtocol>(path: Path) -> SchemaAttribute<Path.Root> where Path.Value == Root {
        SchemaAttribute<Path.Root>(
            available: self.available,
            label: self.label,
            trigger: ,
            type: self.type,
            validate: <#T##AnyValidator<Path.Root>#>
        )
    }
    
}
