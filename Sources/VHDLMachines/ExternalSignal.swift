//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

struct ExternalSignal: Signal {
    
    enum Mode{
        
        case input
        case output
        case inputoutput
        case buffer
    }
    
    var type: SignalType
    
    var name: String
    
    var defaultValue: String?
    
    var mode: Mode
}
