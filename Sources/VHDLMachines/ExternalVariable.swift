//
//  File.swift
//  
//
//  Created by Morgan McColl on 20/5/21.
//

import Foundation

public struct ExternalVariable: ExternalType {
    
    public var type: String
    
    public var name: String
    
    public var range: (Int, Int)?
    
    public var defaultValue: String?
    
    public var comment: String?
    
    public var mode: Mode
    
    public init(type: String, name: String, mode: Mode, range: (Int, Int)? = nil, defaultValue: String?, comment: String?) {
        self.type = type
        self.name = name
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
        self.range = range
    }
}
