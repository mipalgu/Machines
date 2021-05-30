//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

struct SchemaAttribute<Root: Modifiable> {
    
    var available: Bool
    
    var trigger: AnyTrigger<Root>
    
    var type: AttributeType
    
    var validate: AnyValidator<Root>
    
}
