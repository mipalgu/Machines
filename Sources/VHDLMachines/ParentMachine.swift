//
//  ParentMachine.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

public struct ParentMachine {
    
    var parent: Machine
    
    var children: [String: Machine]
    
    /// Maps variables (1 to many) to other machine parameters. Of the format: [ParentVariableName: [ChildMachineName: [ChildParameter]]]
    var links: [String: [String: [Variable]]]
    
}
