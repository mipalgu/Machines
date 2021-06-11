//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Foundation
import Attributes

struct VHDLParametersGroup: GroupProtocol {
    
    let path: Path<Machine, AttributeGroup> = Machine.path.attributes[0]
    
    @BoolProperty(label: "is_parameterised")
    var isParameterised
    
}
