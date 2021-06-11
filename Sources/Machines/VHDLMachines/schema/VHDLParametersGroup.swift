//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Foundation
import Attributes

struct VHDLParametersGroup: GroupProtocol {
    
    let path = Machine.path.attributes[0]
    
    @BoolProperty(label: "is_parameterised", validation: .required())
    var isParameterised
    
}
