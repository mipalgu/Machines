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
    public var name: VariableName

    /// The default value of the signal.
    public var defaultValue: Expression?

    /// The comment of the signal.
    public var comment: Comment?

    /// The VHDL code that represents this signals definition.
    @inlinable public var rawValue: String {
        let declaration = "signal \(name): \(type.rawValue)"
        let comment = self.comment.map { " " + $0.rawValue } ?? ""
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
    /// - Warning: Make sure the `defaultValue` is valid for the given signal `type`. The program will crash
    /// if this is not the case.
    @inlinable
    public init(type: SignalType, name: VariableName, defaultValue: Expression?, comment: Comment?) {
        if let defaultValue = defaultValue, case .literal(let literal) = defaultValue {
            guard literal.isValid(for: type) else {
                fatalError("Invalid literal \(defaultValue) for signal type \(type).")
            }
        }
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
        let comment = components.last.flatMap { Comment(rawValue: $0) }
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
    private init?(declaration: String, defaultValue: String? = nil, comment: Comment? = nil) {
        let signalComponents = declaration.components(separatedBy: .whitespacesAndNewlines)
        let value = Expression(rawValue: defaultValue ?? "")
        guard signalComponents.count >= 2 else {
            return nil
        }
        let hasColonSuffix = signalComponents[1].hasSuffix(":")
        let colonComponents = signalComponents.filter { $0.contains(":") }
        guard
            signalComponents.count >= 3,
            hasColonSuffix || signalComponents[2] == ":",
            colonComponents.count == 1,
            colonComponents[0].filter({ $0 == ":" }).count == 1
        else {
            return nil
        }
        let typeIndex = hasColonSuffix ? 2 : 3
        guard
            signalComponents.first == "signal",
            signalComponents.count >= typeIndex,
            let type = SignalType(rawValue: signalComponents[typeIndex...].joined(separator: " "))
        else {
            return nil
        }
        let name = hasColonSuffix ? String(signalComponents[1].dropLast()) : signalComponents[1]
        guard let varName = VariableName(rawValue: name) else {
            return nil
        }
        if let val = value, case .literal(let literal) = val {
            guard literal.isValid(for: type) else {
                return nil
            }
        }
        self.name = varName
        self.type = type
        self.comment = comment
        self.defaultValue = value
    }

}

public extension LocalSignal {

    static var ringletCounter: LocalSignal {
        LocalSignal(
            type: .natural,
            name: .ringletCounter,
            defaultValue: .literal(value: .integer(value: 0)),
            comment: nil
        )
    }

    static func internalState(actionType: SignalType) -> LocalSignal {
        LocalSignal(
            type: actionType,
            name: .internalState,
            defaultValue: .variable(name: .readSnapshot),
            comment: nil
        )
    }

    static func stateTrackers<T>(representation: T) -> [LocalSignal] where T: MachineVHDLRepresentable {
        let stateType = representation.stateType
        let machine = representation.machine
        guard case .ranged(let vector) = stateType else {
            fatalError("Incorrect type for states.")
        }
        let range = vector.size
        let targetState: Expression?
        let firstState: Expression?
        if machine.states.count > machine.initialState {
            firstState = .variable(name: VariableName.name(for: machine.states[machine.initialState]))
        } else {
            if machine.suspendedState != 0, let state = machine.states.first {
                firstState = .variable(name: VariableName.name(for: state))
            } else {
                firstState = nil
            }
        }
        if let suspendedState = machine.suspendedState {
            targetState = .variable(name: VariableName.name(for: machine.states[suspendedState]))
        } else {
            targetState = firstState
        }
        return [
            LocalSignal(
                type: stateType,
                name: .currentState,
                defaultValue: targetState,
                comment: nil
            ),
            LocalSignal(
                type: stateType,
                name: .targetState,
                defaultValue: targetState,
                comment: nil
            ),
            LocalSignal(
                type: stateType,
                name: .previousRinglet,
                defaultValue: .literal(
                    value: .vector(
                        value: .logics(value: [LogicLiteral](repeating: .highImpedance, count: range.size))
                    )
                ),
                comment: nil
            ),
            LocalSignal(
                type: stateType,
                name: .suspendedFrom,
                defaultValue: firstState,
                comment: nil
            )
        ]
    }

}
