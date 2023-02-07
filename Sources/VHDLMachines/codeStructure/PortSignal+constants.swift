//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

/// Add some method and computed properties to convert machines.
extension PortSignal {

    /// The external variable name for this signal.
    var externalName: VariableName {
        VariableName.name(for: self)
    }

    /// The snapshot of this signal.
    var snapshot: LocalSignal {
        LocalSignal(type: type, name: name, defaultValue: nil, comment: nil)
    }

    /// The code that updates the snapshot from the external variable.
    var read: Statement {
        Statement.assignment(name: snapshot.name, value: .variable(name: externalName))
    }

    /// The code that updates the external variable from the snapshot.
    var write: Statement {
        Statement.assignment(name: externalName, value: .variable(name: snapshot.name))
    }

    /// Create a `PortSignal` from a `Clock`.
    /// - Parameter clock: The clock to convert.
    @inlinable
    public init(clock: Clock) {
        self.init(type: .stdLogic, name: clock.name, mode: .input, defaultValue: nil, comment: nil)
    }

}
