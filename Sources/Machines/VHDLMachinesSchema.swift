//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

import Attributes

struct VHDLMachinesSchema: SchemaProtocol {
    
    typealias Root = Machine
    
    let trigger: AnyTrigger<Root>
    
    let validator: AnyValidator<Machine>
    
}
