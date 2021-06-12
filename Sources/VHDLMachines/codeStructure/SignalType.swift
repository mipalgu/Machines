//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum SignalType: TypeProtocol {
    case std_logic
    case std_logic_vector(lower: UInt, upper: UInt, isDownTo: Bool) //lower and upper represent size
}
