//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation

public struct ReturnableVariable {
    
    public var type: ParameterType
    
    public var name: String
    
    public var comment: String?
    
    public init(type: ParameterType, name: String, comment: String? = nil) {
        self.type = type
        self.name = name
        self.comment = comment
    }
    
}
