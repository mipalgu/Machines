//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Foundation
import Attributes

struct VHDLParametersGroup: GroupProtocol {
    
    typealias Root = Machine
    
    var path: Path<Machine, AttributeGroup>
    
    var properties: [SchemaProperty<AttributeGroup>]
    
    @GroupProperty(
        label: "is_parameterised",
        available: true,
        trigger: <#T##() -> [AnyTrigger<AttributeGroup>]#>,
        type: .bool,
        validate: {
            path.validate(builder: {
                $0.attributes["is_parameterised"].required()
            })
        }
    )
    var isParameterised
    
}
