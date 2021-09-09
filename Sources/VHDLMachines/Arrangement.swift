//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct Arrangement {
    
    public var machines: [MachineName: URL]
    
    public var externalSignals: [ExternalSignal]
    
    public var externalVariables: [VHDLVariable]
    
    public var clocks: [Clock]
    
    public var parents: [MachineName] // Parent Machines
    
    public var path: URL
    
    public init(machines: [MachineName: URL], externalSignals: [ExternalSignal], externalVariables: [VHDLVariable], clocks: [Clock], parents: [MachineName], path: URL) {
        self.machines = machines
        self.externalSignals = externalSignals
        self.externalVariables = externalVariables
        self.clocks = clocks
        self.parents = parents
        self.path = path
    }
    
}
