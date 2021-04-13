//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct ExternalSignal: Variable {
    
    public enum Mode: String, CaseIterable {
        
        case input = "in"
        case output = "out"
        case inputoutput = "inout"
        case buffer = "buffer"
    }
    
    public var type: SignalType
    
    public var name: String
    
    public var defaultValue: String?
    
    public var comment: String?
    
    public var mode: Mode
}
