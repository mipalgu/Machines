//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation

/// A parameter is a type of external variable that is used to parameterise a machine. It
/// is a variable that is defined within an entity block in the VHDl representation.
public struct Parameter: ExternalType, Codable, Equatable, Hashable, Variable {

    /// The mode of the parameter.
    public var mode: Mode = .input

    /// The type of the parameter.
    public var type: SignalType

    /// The name of the parameter.
    public var name: String

    /// The default value of the parameter.
    public var defaultValue: SignalLiteral?

    /// The comment of the parameter.
    public var comment: String?

    /// Initialises a new parameter with the given type, name, default value and comment.
    /// - Parameters:
    ///   - type: The type of the parameter.
    ///   - name: The name of the parameter.
    ///   - defaultValue: The default value of the parameter.
    ///   - comment: The comment of the parameter.
    @inlinable
    public init(type: SignalType, name: String, defaultValue: SignalLiteral? = nil, comment: String? = nil) {
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.comment = comment
    }

}
