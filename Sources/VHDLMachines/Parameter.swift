//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation

/// A parameter is a type of external variable that is used to parameterise a machine. It is a variable that is
/// defined within an entity block in the VHDl representation.
public struct Parameter: ExternalType, Codable, Equatable, Hashable, Sendable {

    /// The mode of the parameter.
    public var mode: Mode = .input

    /// The type of the parameter.
    public var type: ParameterType

    /// The name of the parameter.
    public var name: String

    /// The default value of the parameter.
    public var defaultValue: String?

    /// The comment of the parameter.
    public var comment: String?

    /// Initialises a new parameter with the given type, name, default value and comment.
    /// - Parameters:
    ///   - type: The type of the parameter.
    ///   - name: The name of the parameter.
    ///   - defaultValue: The default value of the parameter.
    ///   - comment: The comment of the parameter.
    @inlinable
    public init(type: ParameterType, name: String, defaultValue: String? = nil, comment: String? = nil) {
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.comment = comment
    }

}
