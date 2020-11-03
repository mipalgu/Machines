//
//  State.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

public struct State {
    
    public var name: String
    
    /// List of timeslots with a list of actions in each time slot.
    public var ringlet: [[Action]]
    
    public var variables: [Variable]
    
}
