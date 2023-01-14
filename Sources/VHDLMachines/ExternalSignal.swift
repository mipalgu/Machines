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
    public var name: VariableName

    /// The default value of the signal.
    public var defaultValue: Expression?

    /// The comment of the signal.
    public var comment: Comment?

    /// The mode of the signal.
    public var mode: Mode

    /// The `VHDL` code that represents this signal definition.
    @inlinable public var rawValue: String {
        let declaration = "\(name): \(mode.rawValue) \(type.rawValue)"
        let comment = self.comment.map { " " + $0.rawValue } ?? ""
        guard let defaultValue = defaultValue else {
            return declaration + ";\(comment)"
        }
        return declaration + " := \(defaultValue.rawValue);\(comment)"
    }

    var externalName: VariableName {
        VariableName.name(for: self)
    }

    public var snapshot: LocalSignal {
        LocalSignal(type: type, name: name, defaultValue: nil, comment: nil)
    }

    public var read: String {
        "\(name.rawValue) <= \(externalName.rawValue);"
    }

    public var write: String {
        "\(externalName.rawValue) <= \(name.rawValue);"
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
        type: SignalType,
        name: VariableName,
        mode: Mode,
        defaultValue: Expression? = nil,
        comment: Comment? = nil
    ) {
        self.type = type
        self.name = name
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
    }

    /// Initialise the external signal from the VHDL code that defines it.
    /// - Parameter rawValue: The VHDL code that defines this signal. This code is the statement found within
    /// the port declaration of an entity block.
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256 else {
            return nil
        }
        let components = trimmedString.components(separatedBy: ";")
        guard components.count <= 2, !components.isEmpty else {
            return nil
        }
        let comment = components.count == 2 ? components.last.flatMap { Comment(rawValue: $0) } : nil
        let declaration = trimmedString.uptoSemicolon
        let assignmentComponents = declaration.components(separatedBy: ":=")
        guard assignmentComponents.count <= 2, let typeDeclaration = assignmentComponents.first else {
            return nil
        }
        let typeComponents = typeDeclaration.components(separatedBy: .whitespaces)
        guard typeComponents.count >= 2 else {
            return nil
        }
        let hasColonComponents = typeComponents[1].trimmingCharacters(in: .whitespaces) == ":"
        let nameComponents = typeComponents[0]
        let minCount = hasColonComponents ? 4 : 3
        guard typeComponents.count >= minCount else {
            return nil
        }
        let modeComponents = hasColonComponents ? typeComponents[2] : typeComponents[1]
        let typeString = typeComponents[(minCount - 1)...].joined(separator: " ")
        guard
            let mode = Mode(rawValue: modeComponents), hasColonComponents || nameComponents.hasSuffix(":")
        else {
            return nil
        }
        let nameString = hasColonComponents ? nameComponents : String(nameComponents.dropLast())
        guard
            let name = VariableName(rawValue: nameString), let type = SignalType(rawValue: typeString)
        else {
            return nil
        }
        let defaultValue = assignmentComponents.count == 2 ? Expression(rawValue: assignmentComponents[1])
            : nil
        self.name = name
        self.type = type
        self.mode = mode
        self.defaultValue = defaultValue
        self.comment = comment
    }

}
