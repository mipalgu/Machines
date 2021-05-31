//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

struct SchemaAttribute<Root> {
    
    var available: Bool
    
    var label: String
    
    var trigger: AnyTrigger<Root>
    
    var type: AttributeType
    
    var validate: AnyValidator<Root>
    
}
