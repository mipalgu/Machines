//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation

public struct Machine: Codable, Hashable {
    
    public var name: String
//    public var path: URL
    public var includes: String
    public var includePaths: [String]
    public var funcRefs: String
    public var states: [State]
    public var transitions: [Transition]
    public var machineVariables: [Variable]
    public var initialState: Int
    public var suspendedState: Int?
    public var actionDisplayOrder: [String]
    
    public init(name: String, includes: String, includePaths: [String], funcRefs: String, states: [State], transitions: [Transition], machineVariables: [Variable], initialState: Int, suspendedState: Int?, actionDisplayOrder: [String]) {
        self.name = name
//        self.path = path
        self.includes = includes
        self.includePaths = includePaths
        self.funcRefs = funcRefs
        self.states = states
        self.transitions = transitions
        self.machineVariables = machineVariables
        self.initialState = initialState
        self.suspendedState = suspendedState
        self.actionDisplayOrder = actionDisplayOrder
    }
    
    public func write() -> CXXFileWrapper? {
        let generator = CXXGenerator()
        return generator.generate(machine: self)
    }
    
}
