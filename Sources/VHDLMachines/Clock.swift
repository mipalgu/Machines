//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct Clock {
    
    public enum FrequencyUnit: String, CaseIterable {
        
        case Hz = "Hz"
        
        case kHz = "kHz"
        
        case MHz = "MHz"
        
        case GHz = "GHz"
        
        case THz = "THz"
    }
    
    public var name: String
    
    public var frequency: UInt
    
    public var unit: FrequencyUnit
    
}
