//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum Type<TypeGeneric: TypeProtocol> {
    case type(type: TypeGeneric)
}
