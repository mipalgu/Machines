//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// An external signal is equivalent to an external variable (or parameter) in an LLFSM. The external signal
/// is a signal that exists above a VHDL entities scope. It is a signal that is not defined within the entity.
public struct ExternalSignal: ExternalType, RawRepresentable, Codable, Hashable, Variable, Sendable {

    /// The type of the signal.
    public var type: SignalType

    /// The name of the signal.
    public var name: String

    /// The default value of the signal.
    public var defaultValue: SignalLiteral?

    /// The comment of the signal.
    public var comment: String?

    /// The mode of the signal.
    public var mode: Mode

    public var rawValue: String {
        let declaration = "\(name): \(mode.rawValue) \(type.rawValue)"
        let comment = self.comment.map { " -- \($0)" } ?? ""
        guard let defaultValue = defaultValue else {
            return declaration + ";\(comment)"
        }
        return declaration + " := \(defaultValue.rawValue);\(comment)"
    }

    /// Initialises a new external signal with the given type, name, mode, default value and comment.
    /// - Parameters:
    ///   - type: The type of the signal.
    ///   - name: The name of the signal.
    ///   - mode: The mode of the signal.
    ///   - defaultValue: The default value of the signal.
    ///   - comment: The comment of the signal.
    @inlinable
    public init(
        type: SignalType, name: String, mode: Mode, defaultValue: SignalLiteral? = nil, comment: String? = nil
    ) {
        self.type = type
        self.name = name
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
    }

    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        let components = trimmedString.components(separatedBy: ";")
        guard components.count <= 2, !components.isEmpty else {
            return nil
        }
        let comment = components.count == 2 ? String(comment: components.last ?? "") : nil
        let declaration = trimmedString.uptoSemicolon
        let assignmentComponents = declaration.components(separatedBy: ":=")
        guard assignmentComponents.count <= 2, let typeDeclaration = assignmentComponents.first else {
            return nil
        }
        let typeComponents = typeDeclaration.components(separatedBy: .whitespaces)
        guard typeComponents.count >= 3 else {
            return nil
        }
        let nameComponents = typeComponents[0]
        let modeComponents = typeComponents[1]
        let typeString = typeComponents[2...].joined(separator: " ")
        guard let mode = Mode(rawValue: modeComponents), nameComponents.hasSuffix(":") else {
            return nil
        }
        let nameString = String(nameComponents.dropLast())
        guard let name = String(name: nameString), let type = SignalType(rawValue: typeString) else {
            return nil
        }
        let defaultValue = assignmentComponents.count == 2 ? SignalLiteral(rawValue: assignmentComponents[1])
            : nil
        self.name = name
        self.type = type
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
    }

}
