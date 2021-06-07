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
        trigger: { [] },
        type: .bool,
        validate: AnyValidator(RequiredValidator(path: path.attributes["is_parameterised"].wrappedValue))
    )
    var isParameterised
    
}
