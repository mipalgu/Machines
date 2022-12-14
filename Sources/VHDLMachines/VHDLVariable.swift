//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// A variable that is local to an architecture implementation of a VHDL entity. This variable
/// is equivalent to a LLFSM machine variable or State variable.
public struct VHDLVariable: Variable {

    /// The type of the variable.
    public var type: String

    /// The name of the variable.
    public var name: String

    /// The default value of the variable.
    public var defaultValue: String?

    /// The range of the variable.
    public var range: (Int, Int)?

    /// The comment of the variable.
    public var comment: String?

    /// Initialises a ``VHDLVariable`` with a type, name, default value, range and comment.
    /// - Parameters:
    ///   - type: The type of the variable.
    ///   - name: The name of the variable.
    ///   - defaultValue: The default value of the variable.
    ///   - range: The range of valid values for the variable.
    ///   - comment: The comment of the variable.
    @inlinable
    public init(type: String, name: String, defaultValue: String?, range: (Int, Int)?, comment: String?) {
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.range = range
        self.comment = comment
    }

}

/// Conformance to ``Codable``.
extension VHDLVariable: Codable {

    /// The keys used to encode and decode the variable.
    @usableFromInline
    enum CodingKeys: CodingKey {

        case type, name, defaultValue, range, comment

    }

    /// Initialises a ``VHDLVariable`` from a decoder.
    /// - Parameter from: The decoder to decode the variable from.
    @inlinable
    public init(from: Decoder) throws {
        let container = try from.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        defaultValue = try container.decode(String?.self, forKey: .defaultValue)
        comment = try container.decode(String?.self, forKey: .comment)
        guard let rangeRaw = try container.decode(String?.self, forKey: .range) else {
            range = nil
            return
        }
        let components = rangeRaw.split(separator: ",")
        guard
            components.count == 2,
            let minRange = Int(components[0]),
            let maxRange = Int(components[1])
        else {
            range = nil
            return
        }
        range = (minRange, maxRange)
    }

    /// Encodes the variable.
    /// - Parameter encoder: The encoder to encode the variable to.
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(defaultValue, forKey: .defaultValue)
        try container.encode(comment, forKey: .comment)
        guard let range = range else {
            try container.encode(String?(nil), forKey: .range)
            return
        }
        try container.encode(String?("\(range.0),\(range.1)"), forKey: .range)
    }

}
