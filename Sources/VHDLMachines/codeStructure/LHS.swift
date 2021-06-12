//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum LHS<TypeGeneric: TypeProtocol> {
    
    case label(value: String)
    case declaration(value: Declaration<TypeGeneric>)
    
}
