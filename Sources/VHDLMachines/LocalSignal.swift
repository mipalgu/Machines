//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// A local signal is a signal that exists within the scope of a VHDL entity. It is a signal that is defined
/// within a machine/arrangement and can be though of as a type of machine variable in VHDL.
public struct LocalSignal: Codable, Equatable, Hashable, Variable {

    /// The type of the signal.
    public var type: SignalType

    /// The name of the signal.
    public var name: String

    /// The default value of the signal.
    public var defaultValue: SignalLiteral?

    /// The comment of the signal.
    public var comment: String?

    /// Initialises a new machine signal with the given type, name, default value and comment.
    /// - Parameters:
    ///   - type: The type of the signal.
    ///   - name: The name of the signal.
    ///   - defaultValue: The default value of the signal.
    ///   - comment: The comment of the signal.
    @inlinable
    public init(type: SignalType, name: String, defaultValue: SignalLiteral?, comment: String?) {
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.comment = comment
    }

}
