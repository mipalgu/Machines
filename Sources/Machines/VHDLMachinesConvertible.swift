//
//  VHDLMachinesConvertible.swift
//  Machines
//
//  Created by Morgan McColl on 3/11/20.
//

import VHDLMachines

public protocol VHDLMachinesConvertible {
    
    init(from vhdlMachine: VHDLMachines.ParentMachine)
    
    func vhdlMachine() throws -> VHDLMachines.ParentMachine
    
}
