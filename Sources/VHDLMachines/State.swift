//
//  State.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

struct State {
    
    var name: String
    
    /// List of timeslots with a list of actions in each time slot.
    var ringlet: [[Action]]
    
    var variables: [Variable]
    
}
