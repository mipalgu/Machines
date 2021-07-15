//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

public struct State: Codable, Hashable {
    public var name: String
    public var variables: [Variable]
    public var actions: [String: String]
    
    public init(name: String, variables: [Variable], actions: [String: String]) {
        self.name = name
        self.variables = variables
        self.actions = actions
    }
}
