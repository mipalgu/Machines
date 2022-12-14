//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// An external signal is equivalent to an external variable (or parameter) in an LLFSM. The external signal
/// is a signal that exists above a VHDL entities scope. It is a signal that is not defined within the entity.
public struct ExternalSignal: ExternalType, Codable, Hashable, Sendable {

    /// The type of the signal.
    public var type: String

    /// The name of the signal.
    public var name: String

    /// The default value of the signal.
    public var defaultValue: String?

    /// The comment of the signal.
    public var comment: String?

    /// The mode of the signal.
    public var mode: Mode

    /// Initialises a new external signal with the given type, name, mode, default value and comment.
    /// - Parameters:
    ///   - type: The type of the signal.
    ///   - name: The name of the signal.
    ///   - mode: The mode of the signal.
    ///   - defaultValue: The default value of the signal.
    ///   - comment: The comment of the signal.
    @inlinable
    public init(type: String, name: String, mode: Mode, defaultValue: String?, comment: String?) {
        self.type = type
        self.name = name
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
    }

}
