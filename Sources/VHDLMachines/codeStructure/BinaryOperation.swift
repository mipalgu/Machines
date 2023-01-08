//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum BinaryOperation {
    
    case plus(lhs: AnyExpression, rhs: AnyExpression)
    case minus(lhs: AnyExpression, rhs: AnyExpression)
    case multiply(lhs: AnyExpression, rhs: AnyExpression)
    case divide(lhs: AnyExpression, rhs: AnyExpression)
    case exponentiate(lhs: AnyExpression, rhs: AnyExpression)
    case and(lhs: AnyExpression, rhs: AnyExpression)
    case or(lhs: AnyExpression, rhs: AnyExpression)
    case xor(lhs: AnyExpression, rhs: AnyExpression)
    case shiftLeft(lhs: AnyExpression, rhs: AnyExpression)
    case shiftRight(lhs: AnyExpression, rhs: AnyExpression)
    case condition(condition: Conditional)
    
}
