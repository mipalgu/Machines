//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct State: Codable {
    
    public var name: String
    
    public var actions: [ActionName: String]
    
    public var actionOrder: [[ActionName]]
    
    public var signals: [MachineSignal]
    
    public var variables: [VHDLVariable]
    
    public var externalVariables: [String]
    
    public init(name: String, actions: [ActionName: String], actionOrder: [[ActionName]], signals: [MachineSignal], variables: [VHDLVariable], externalVariables: [String]) {
        self.name = name
        self.actions = actions
        self.actionOrder = actionOrder
        self.signals = signals
        self.variables = variables
        self.externalVariables = externalVariables
    }
    
}
