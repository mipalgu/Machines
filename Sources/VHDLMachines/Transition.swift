//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct Transition: Codable {
    
    public var condition: String
    
    public var source: Int
    
    public var target: Int
    
    public init(condition: String, source: Int, target: Int) {
        self.condition = condition
        self.source = source
        self.target = target
    }
    
}
