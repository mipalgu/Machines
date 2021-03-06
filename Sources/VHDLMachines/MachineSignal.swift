//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct MachineSignal: Variable, Codable {
    
    public var type: String
    
    public var name: String
    
    public var defaultValue: String?
    
    public var comment: String?
    
    public init(type: String, name: String, defaultValue: String?, comment: String?) {
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.comment = comment
    }

}
