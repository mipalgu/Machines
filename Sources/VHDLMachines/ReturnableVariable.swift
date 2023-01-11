//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation

/// A variable that can be returned from a parameterised machine.
public struct ReturnableVariable: ExternalType, Codable, Equatable, Hashable {

    /// The mode is an output for a returnable variable.
    public var mode: Mode = .output

    /// The type of the variable.
    public var type: SignalType

    /// The name of the variable.
    public var name: String

    /// The comment for the variable.
    public var comment: String?

    /// Initialises a returnable variable with the given type, name and comment.
    /// - Parameters:
    ///   - type: The type of the variable.
    ///   - name: The name of the variable.
    ///   - comment: The comment for the variable.
    @inlinable
    public init(type: SignalType, name: String, comment: String? = nil) {
        self.type = type
        self.name = name
        self.comment = comment
    }

}
