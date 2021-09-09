//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct Clock: Codable {
    
    public enum FrequencyUnit: String, CaseIterable, Codable {
        
        case Hz = "Hz"
        
        case kHz = "kHz"
        
        case MHz = "MHz"
        
        case GHz = "GHz"
        
        case THz = "THz"
    }
    
    public var name: String
    
    public var frequency: UInt
    
    public var unit: FrequencyUnit
    
    public var period: Double {
        let f = Double(frequency)
        switch unit {
        case .Hz:
            return 1.0 / f
        case .kHz:
            return 1.0 / (f * 1000)
        case .MHz:
            return 1.0 / (f * 1_000_000)
        case .GHz:
            return 1.0 / (f * 1_000_000_000)
        case .THz:
            return 1.0 / (f * 1_000_000_000_000)
        }
    }
    
    public init(name: String, frequency: UInt, unit: FrequencyUnit) {
        self.name = name
        self.frequency = frequency
        self.unit = unit
    }
    
}
