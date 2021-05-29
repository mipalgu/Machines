//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation

public struct Parameter: ExternalType {
    
    public var mode: Mode = .input
    
    public var type: ParameterType
    
    public var name: String
    
    public var defaultValue: String?
    
    public var comment: String?
    
    public init(type: ParameterType, name: String, defaultValue: String? = nil, comment: String? = nil) {
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.comment = comment
    }
    
}
