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
    
    @TriggerBuilder<Machine>
    var triggers: AnyTrigger<Machine> {
        WhenChanged(path(for: isParameterised)).sync(target: path(for: somethingElse))
        WhenChanged(path(for: isParameterised)).sync(target: path(for: somethingElse))
    }
    
    @BoolProperty(label: "is_parameterised", validation: .required())
    var isParameterised
    
    @BoolProperty(label: "something_else", validation: .required())
    var somethingElse
    
}
