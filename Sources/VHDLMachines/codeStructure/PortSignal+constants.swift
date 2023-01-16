//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

public extension PortSignal {

    var externalName: VariableName {
        VariableName.name(for: self)
    }

    var snapshot: LocalSignal {
        LocalSignal(type: type, name: name, defaultValue: nil, comment: nil)
    }

    var read: String {
        "\(name.rawValue) <= \(externalName.rawValue);"
    }

    var write: String {
        "\(externalName.rawValue) <= \(name.rawValue);"
    }

    init(clock: Clock) {
        self.init(type: .stdLogic, name: clock.name, mode: .input, defaultValue: nil, comment: nil)
    }

    static func commandSignal(type: SignalType) -> PortSignal {
        PortSignal(type: type, name: .command, mode: .input)
    }

    static func suspendedSignal(type: SignalType) -> PortSignal {
        PortSignal(type: type, name: .suspended, mode: .output)
    }

}
