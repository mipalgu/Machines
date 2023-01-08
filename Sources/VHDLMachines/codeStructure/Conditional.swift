//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

enum Conditional {
    
    case lessThan(lhs: AnyExpression, rhs: AnyExpression)
    case greaterThan(lhs: AnyExpression, rhs: AnyExpression)
    case isEqual(lhs: AnyExpression, rhs: AnyExpression)
    case lessThanOrEqual(lhs: AnyExpression, rhs: AnyExpression)
    case greaterThanOrEqual(lhs: AnyExpression, rhs: AnyExpression)
    case notEqual(lhs: AnyExpression, rhs: AnyExpression)
    
}
