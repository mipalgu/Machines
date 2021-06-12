//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum VariableValue: ValueProtocol {
    
    typealias TypeGeneric = VariableType
    
    case integer(value: Int)
    case unsignedInteger(value: UInt)
    case boolean(value: Bool)
}
