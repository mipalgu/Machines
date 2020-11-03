//
//  Machine.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

public struct Machine {
    
    var name: String
    
    var initialState: State
    
    var suspendedState: State
    
    var otherStates: [State]
    
    /// State name is the key
    var transitions: [String: [Transition]]
    
    /// Variable name is the key
    var externalVariables: [String: ExternalVariable]
    
    /// Variable name is the key
    var parameters: [String: Parameter]
    
    /// Variable name is the key
    var returnableVariables: [String: ReturnableVariable]
    
    /// Variable name is the key
    var machineVariables: [String: Variable]
    
    var includes: String
    
}
