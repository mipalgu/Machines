//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation

public struct Variable: Codable, Hashable {
    
    public var type: String
    public var name: String
    public var value: String?
    public var comment: String
    
    public init(type: String, name: String, value: String?, comment: String) {
        self.type = type
        self.name = name
        self.value = value
        self.comment = comment
    }
    
}
