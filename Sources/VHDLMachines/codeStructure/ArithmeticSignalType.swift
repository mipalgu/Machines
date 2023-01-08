//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum ArithmeticSignalType: TypeProtocol {
    
    case unsigned(lower: UInt, upper: UInt, isDownTo: Bool) //lower and upper represent size
    case signed(lower: UInt, upper: UInt, isDownTo: Bool) //lower and upper represent size
    
}
