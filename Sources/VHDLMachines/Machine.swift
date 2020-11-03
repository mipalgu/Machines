//
//  Machine.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

import Foundation

public struct Machine {
    
    public var name: String
    
    public var path: URL
    
    public var initialState: State
    
    public var suspendedState: State
    
    public var otherStates: [State]
    
    /// State name is the key
    public var transitions: [String: [Transition]]
    
    /// Variable name is the key
    public var externalVariables: [String: VHDLExternalVariable]
    
    /// Variable name is the key
    public var parameters: [String: Parameter]
    
    /// Variable name is the key
    public var returnableVariables: [String: ReturnableVariable]
    
    /// Variable name is the key
    public var machineVariables: [String: VHDLVariable]
    
    public var includes: String
    
}
