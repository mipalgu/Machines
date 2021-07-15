//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

indirect enum AnyExpression {
    
    case variable(value: Literal<VariableValue>)
    case signal(value: Literal<SignalValue>)
    case arithmeticSignal(value: Literal<ArithmeticSignalValue>)
    case prefixOperation(value: PrefixOperation)
    case precedence(value: AnyExpression)
    case binaryOperation(value: BinaryOperation)
    
}

enum Literal<ValueGeneric: ValueProtocol> {
    
    case literal(value: ValueGeneric)
    
}
