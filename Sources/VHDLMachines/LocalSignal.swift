//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// A local signal is a signal that exists within the scope of a VHDL entity. It is a signal that is defined
/// within a machine/arrangement and can be though of as a type of machine variable in VHDL.
public struct LocalSignal: RawRepresentable, Codable, Equatable, Hashable, Variable, Sendable {

    /// The type of the signal.
    public var type: SignalType

    /// The name of the signal.
    public var name: String

    /// The default value of the signal.
    public var defaultValue: SignalLiteral?

    /// The comment of the signal.
    public var comment: String?

    /// The VHDL code that represents this signals definition.
    @inlinable public var rawValue: String {
        let declaration = "signal \(name): \(type.rawValue)"
        let comment = self.comment.map { " -- \($0)" } ?? ""
        guard let defaultValue = defaultValue else {
            return declaration + ";\(comment)"
        }
        return declaration + " := \(defaultValue.rawValue);\(comment)"
    }

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

    /// Initialises a new local signal from the VHDL code that defines it.
    /// - Parameter rawValue: The VHDL code that defines this signal.
    public init?(rawValue: String) {
        let trimmedString = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedString.count < 256, trimmedString.hasPrefix("signal ") else {
            return nil
        }
        let components = trimmedString.components(separatedBy: ";")
        guard components.count <= 2, !components.isEmpty else {
            return nil
        }
        let comment = String(comment: components.last ?? "")?.trimmingCharacters(in: .whitespaces)
        let declaration = trimmedString.uptoSemicolon
        guard !declaration.contains(":=") else {
            let declComponents = declaration.components(separatedBy: ":=")
            guard declComponents.count == 2 else {
                return nil
            }
            self.init(
                declaration: declComponents[0].trimmingCharacters(in: .whitespaces),
                defaultValue: declComponents[1].trimmingCharacters(in: .whitespaces),
                comment: comment
            )
            return
        }
        self.init(declaration: declaration, comment: comment)
    }

    /// Initialises a new local signal from the given declaration, default value and comment VHDL components.
    /// - Parameters:
    ///   - declaration: The declaration string consisting of the signal name and type definition.
    ///   - defaultValue: The default value of the signal. This value appears on the rhs of the `:=` operator.
    ///   - comment: The comment that appears on the rhs of the `--` operator.
    private init?(declaration: String, defaultValue: String? = nil, comment: String? = nil) {
        let signalComponents = declaration.components(separatedBy: .whitespacesAndNewlines)
        let value = SignalLiteral(rawValue: defaultValue ?? "")
        let typeIndex = signalComponents.count == 3 ? 2 : 3
        guard
            signalComponents.first == "signal",
            signalComponents.count >= 3,
            (!signalComponents[1].hasSuffix(":") && signalComponents.count == 4 && signalComponents[2] == ":")
                || signalComponents[1].hasSuffix(":") && signalComponents.count == 3,
            let type = SignalType(rawValue: signalComponents[typeIndex])
        else {
            return nil
        }
        let name = signalComponents.count == 3 ? String(signalComponents[1].dropLast()) : signalComponents[1]
        guard !name.isEmpty, !CharacterSet.whitespacesAndNewlines.within(string: name) else {
            return nil
        }
        self.name = name
        self.type = type
        self.comment = comment
        self.defaultValue = value
    }

}
