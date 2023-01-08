//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum Statement<TypeGeneric, ValueGeneric: ValueProtocol> where ValueGeneric.TypeGeneric == TypeGeneric {
    
    case instantiation(declaration: Declaration<TypeGeneric>, value: ValueGeneric)
    case assignment(lhs: LHS<TypeGeneric>, rhs: AnyExpression)
    
}
