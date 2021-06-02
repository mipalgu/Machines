//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct SchemaAttribute<Root> {
    
    public var available: Bool
    
    public var label: String
    
    public var trigger: AnyTrigger<Root>
    
    public var type: AttributeType
    
    public var validate: AnyValidator<Root>
    
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
            trigger: self.trigger.toNewRoot(path: path),
            type: self.type,
            validate: self.validate.toNewRoot(path: path)
        )
    }
    
}
