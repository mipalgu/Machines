//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum Declaration<TypeGeneric: TypeProtocol> {
    case constant(name: String, type: TypeGeneric)
    case mutable(name: String, type: TypeGeneric)
}
