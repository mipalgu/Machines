//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

enum SchemaProperty<Root: Modifiable> {
    
    case property(SchemaAttribute<Root>)
    
}
