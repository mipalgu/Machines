//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct VHDLVariable: Variable {
    
    public var type: VariableType
    
    public var name: String
    
    public var defaultValue: String?
    
    public var range: (Int, Int)?
    
    public var comment: String?
    
}
