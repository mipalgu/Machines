//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation

public struct Machine: Codable, Hashable {
    
    var name: String
    public var path: URL
    var includes: String
    var includePaths: [String]
    var funcRefs: String
    var states: [State]
    var transitions: [Transition]
    var machineVariables: [Variable]
    var initialState: Int
    
//    public init(name: String, path: URL, includes: String, includePaths: [String], funcRefs: String, states: [State], transitions: [Transition], machineVariables: [Variable], initialState: Int) {
//        self.name = name
//        self.path = path
//        self.includes = includes
//        self.includePaths = includePaths
//        self.funcRefs = funcRefs
//        self.states = states
//        self.transitions = transitions
//        self.machineVariables = machineVariables
//        self.initialState = initialState
//    }
    
}
