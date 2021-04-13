//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct Machine {
    
    public var name: MachineName
    
    public var path: URL
    
    public var includes: [String]
    
    public var externalSignals: [ExternalSignal]
    
    public var externalVariables: [VHDLVariable]
    
    public var clocks: [Clock]
    
    public var drivingClock: Int
    
    public var dependentMachines: [MachineName: URL]
    
    public var machineVariables: [VHDLVariable]
    
    public var machineSignals: [MachineSignal]
    
    public var states: [State]
    
    public var transitions: [Transition]
    
    public var initialState: Int
    
    public var suspendedState: Int?
}
