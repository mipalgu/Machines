//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// A variable in VHDL that represents machine and state variables in an LLFSM.
public protocol Variable {

    /// The type of the variable.
    var type: SignalType {get set}

    /// The name of the variable.
    var name: VariableName {get set}

    /// The default value of the variable.
    var defaultValue: SignalLiteral? {get set}

    /// The range of the variable.
    var comment: Comment? {get set}

}
