//
//  File.swift
//  
//
//  Created by Morgan McColl on 20/5/21.
//

import Foundation

public struct ExternalVariable: ExternalType {
    
    public var type: VariableType
    
    public var name: String
    
    public var defaultValue: String?
    
    public var comment: String?
    
    public var mode: Mode
    
    public init(type: VariableType, name: String, mode: Mode, defaultValue: String?, comment: String?) {
        self.type = type
        self.name = name
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
    }
}
