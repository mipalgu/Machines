//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct Machine {
    
    var name: MachineName
    
    var path: URL
    
    var includes: [String]
    
    var externalSignals: [ExternalSignal]
    
    var externalGenerics: [VHDLVariable]
    
    var clocks: [Clock]
    
    var drivingClock: Int
    
    var dependentMachines: [MachineName: URL]
    
    var machineVariables: [VHDLVariable]
    
    var machineSignals: [MachineSignal]
    
    var states: [State]
    
    var transitions: [Transition]
    
    var initialState: Int
    
    var suspendedState: Int?
}
