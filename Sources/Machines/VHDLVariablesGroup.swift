//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Foundation
import Attributes

struct VHDLVariablesGroup: GroupProtocol {
    
    @GroupProperty(
        label: <#T##String#>,
        available: <#T##Bool#>,
        trigger: <#T##() -> [AnyTrigger<AttributeGroup>]#>,
        type: <#T##AttributeType#>,
        validate: <#T##() -> [AnyValidator<AttributeGroup>]#>
    )
    var clocks
    
}
