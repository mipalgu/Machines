//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum SignalValue: ValueProtocol {
    
    typealias TypeGeneric = SignalType
    
    case bit(value: BinaryNumber)
    case bitvector(value: BinaryNumber)
    case hex(value: BinaryNumber)
    case octal(value: BinaryNumber)
}
