//
//  VHDLVariable.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

protocol VHDLVariable {
    
    var signalType: String {get set}
    
    var name: String {get set}
    
    var type: VhdlType {get set}
    
    var initial: String {get set}
    
}
