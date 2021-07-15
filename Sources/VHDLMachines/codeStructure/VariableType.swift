//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum VariableType: TypeProtocol {
    case integer
    case boundedInteger(lower: Int, upper: Int) //lower and upper represent valid values
    case real
    case natural
    case boolean
}
