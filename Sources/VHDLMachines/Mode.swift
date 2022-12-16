//
//  File.swift
//  
//
//  Created by Morgan McColl on 20/5/21.
//

import Foundation

/// A mode represents the direction a signal is travelling (input or output).
public enum Mode: String, CaseIterable, Codable, Sendable {

    /// Input mode.
    case input = "in"

    /// Output mode.
    case output = "out"

    /// Input and Output mode.
    case inputoutput = "inout"

    /// Buffered mode.
    case buffer = "buffer"

}
