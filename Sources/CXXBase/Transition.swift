//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

public struct Transition: Codable, Hashable {
    
    public var source: State
    public var target: State
    public var condition: String
    public var priority: UInt
    
    public init(source: State, target: State, condition: String, priority: UInt) {
        self.source = source
        self.target = target
        self.condition = condition
        self.priority = priority
    }
    
}
