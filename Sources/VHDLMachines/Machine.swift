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
    
    public var parameters: [Parameter]
    
    public var states: [State]
    
    public var transitions: [Transition]
    
    public var initialState: Int
    
    public var suspendedState: Int?
    
    public init(
        name: MachineName,
        path: URL,
        includes: [String],
        externalSignals: [ExternalSignal],
        externalVariables: [VHDLVariable],
        clocks: [Clock],
        drivingClock: Int,
        dependentMachines: [MachineName: URL],
        machineVariables: [VHDLVariable],
        machineSignals: [MachineSignal],
        parameters: [Parameter],
        states: [State],
        transitions: [Transition],
        initialState: Int,
        suspendedState: Int?
    ) {
        self.name = name
        self.path = path
        self.includes = includes
        self.externalSignals = externalSignals
        self.externalVariables = externalVariables
        self.clocks = clocks
        self.drivingClock = drivingClock
        self.dependentMachines = dependentMachines
        self.machineVariables = machineVariables
        self.machineSignals = machineSignals
        self.parameters = parameters
        self.states = states
        self.transitions = transitions
        self.initialState = initialState
        self.suspendedState = suspendedState
    }
    
}
