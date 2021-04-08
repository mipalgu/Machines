//
//  File.swift
//  
//
//  Created by Morgan McColl on 9/4/21.
//

import Foundation
import CXXBase

struct SpartanFSMConverter {
    private var actions: [String: String] {
        [
            "OnEntry": "",
            "OnExit": "",
            "Internal": "",
            "OnSuspend": "",
            "OnResume": ""
        ]
    }
    
    func intialSpartanFSMMachine(filePath: URL) -> Machine {
        let name = filePath.lastPathComponent.components(separatedBy: ".machine")[0]
        let machine = CXXBase.Machine(
            name: name,
            path: filePath,
            includes: "",
            includePaths: [],
            funcRefs: "",
            states: [
                CXXBase.State(name: "Initial", variables: [], actions: actions),
                CXXBase.State(name: "Suspended", variables: [], actions: actions)
            ],
            transitions: [],
            machineVariables: [],
            initialState: 0,
            suspendedState: 1,
            actionDisplayOrder: ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        )
        let converter = CXXBaseConverter()
        return converter.toMachine(machine: machine, semantics: .spartanfsm)
    }
    
}
