//
//  Variable.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

struct Variable: VHDLVariable {
 
    var signalType: VhdlSignalType
    
    var name: String
    
    var type: VhdlType
    
    var initial: String
    
}
