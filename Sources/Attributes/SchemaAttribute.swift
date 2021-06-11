//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct SchemaAttribute<Root> {
    
    public var available: Bool
    
    public var label: String
    
    public var type: AttributeType
    
    public var validate: AnyValidator<Root>
    
    public init(available: Bool, label: String, type: AttributeType, validate: AnyValidator<Root> = AnyValidator()) {
        self.available = available
        self.label = label
        self.type = type
        self.validate = validate
    }
    
    func toNewRoot<Path: PathProtocol>(path: Path) -> SchemaAttribute<Path.Root> where Path.Value == Root {
        SchemaAttribute<Path.Root>(
            available: self.available,
            label: self.label,
            type: self.type,
            validate: self.validate.toNewRoot(path: path)
        )
    }
    
}
