//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import VHDLParsing

/// A variable that can be returned from a parameterised machine.
public struct ReturnableVariable: ExternalType, Codable, Equatable, Hashable {

    /// The mode is an output for a returnable variable.
    public var mode: Mode = .output

    /// The type of the variable.
    public var type: SignalType

    /// The name of the variable.
    public var name: VariableName

    /// The comment for the variable.
    public var comment: Comment?

    public var outputName: VariableName {
        VariableName.name(for: self)
    }

    public var snapshot: LocalSignal {
        LocalSignal(type: type, name: name, defaultValue: nil, comment: nil)
    }

    public var write: String {
        "\(outputName) <= \(name);"
    }

    /// Initialises a returnable variable with the given type, name and comment.
    /// - Parameters:
    ///   - type: The type of the variable.
    ///   - name: The name of the variable.
    ///   - comment: The comment for the variable.
    @inlinable
    public init(type: SignalType, name: VariableName, comment: Comment? = nil) {
        self.type = type
        self.name = name
        self.comment = comment
    }

}
