//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

struct VHDLVariable: Variable {
    
    var type: VariableType
    
    var name: String
    
    var defaultValue: String?
    
    var range: (Int, Int)?
    
    var comment: String?
    
}
