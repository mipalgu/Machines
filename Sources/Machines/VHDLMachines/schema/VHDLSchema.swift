//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Foundation
import Attributes

struct VHDLSchema: MachineSchema {
    
    var dependencyLayout: [Field] = []
    
    var parameters = VHDLParametersGroup()
    
}
