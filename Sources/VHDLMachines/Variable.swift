//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// A variable in VHDL that represents machine and state variables in an LLFSM.
public protocol Variable {

    /// The type of the type of the variable.
    associatedtype VariableType: StringProtocol

    /// The type of the variable.
    var type: VariableType {get set}

    /// The name of the variable.
    var name: String {get set}

    /// The default value of the variable.
    var defaultValue: String? {get set}

    /// The range of the variable.
    var comment: String? {get set}

}
