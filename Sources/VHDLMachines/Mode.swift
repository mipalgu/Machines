//
//  File.swift
//  
//
//  Created by Morgan McColl on 20/5/21.
//

import Foundation

public enum Mode: String, CaseIterable, Codable {
    
    case input = "in"
    case output = "out"
    case inputoutput = "inout"
    case buffer = "buffer"
    
}
