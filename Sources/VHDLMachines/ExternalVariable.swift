//
//  File.swift
//  
//
//  Created by Morgan McColl on 20/5/21.
//

import Foundation

/// An external variable is equivalent to a non-signal type top-level entity parameter. The external variable
/// may be an LLFSM external variable or a parameter in a parameterised machine.
public struct ExternalVariable: ExternalType {

    /// The VHDL type of the variable.
    public var type: String

    /// The name of the variable.
    public var name: VariableName

    /// The range of valid values.
    public var range: (Int, Int)?

    /// The default value of the variable.
    public var defaultValue: String?

    /// The comment associated with the variable.
    public var comment: Comment?

    /// The mode of the variable.
    public var mode: Mode

    /// Initialise an external variable with the type, name, mode, range, default value and comment.
    /// - Parameters:
    ///   - type: The VHDL type of the variable.
    ///   - name: The name of the variable.
    ///   - mode: The mode of the variable.
    ///   - range: The range of valid values.
    ///   - defaultValue: The default value of the variable.
    ///   - comment: The comment associated with the variable.
    @inlinable
    public init(
        type: String,
        name: VariableName,
        mode: Mode,
        range: (Int, Int)? = nil,
        defaultValue: String?,
        comment: Comment?
    ) {
        self.type = type
        self.name = name
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
        self.range = range
    }
}
