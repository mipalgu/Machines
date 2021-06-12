//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct ExternalSignal: ExternalType, Codable {
    
    public var type: String
    
    public var name: String
    
    public var defaultValue: String?
    
    public var comment: String?
    
    public var mode: Mode
    
    public init(type: String, name: String, mode: Mode, defaultValue: String?, comment: String?) {
        self.type = type
        self.name = name
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
    }
}
