//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct State {
    
    public var name: String
    
    public var actions: [ActionName: String]
    
    public var signals: [MachineSignal]
    
    public var variables: [VHDLVariable]
    
    public var externalVariables: [String]
    
}
