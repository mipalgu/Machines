//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct ExternalSignal: Variable {
    
    public enum Mode{
        
        case input
        case output
        case inputoutput
        case buffer
    }
    
    public var type: SignalType
    
    public var name: String
    
    public var defaultValue: String?
    
    public var comment: String?
    
    public var mode: Mode
}
