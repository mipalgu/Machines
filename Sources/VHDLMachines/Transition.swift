//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// A transition in a state machine. This transitions acts as a guard for a transition from one state to another.
/// The condition is restricted to be a boolean expression.
public struct Transition: Codable {

    /// The condition that must be met for the transition to occur. This condition must be a VHDL boolean
    /// expression.
    public var condition: String

    /// The index of the source state of the transition.
    public var source: Int

    /// The index of the target state of the transition.
    public var target: Int

    /// Initialises a ``Transition`` with a condition, source and target.
    /// - Parameters:
    ///   - condition: The condition that must be met for the transition to occur.
    ///   - source: The index of the source state of the transition.
    ///   - target: The index of the target state of the transition.
    public init(condition: String, source: Int, target: Int) {
        self.condition = condition
        self.source = source
        self.target = target
    }

}
