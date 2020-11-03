//
//  Variable.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

public struct Variable: VHDLVariable {
 
    public var signalType: VhdlSignalType
    
    public var name: String
    
    public var type: VhdlType
    
    public var initial: String
    
}
