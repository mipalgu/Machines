//
//  UCFSMConverter.swift
//  
//
//  Created by Morgan McColl on 27/3/21.
//

import Foundation
import CXXBase

struct UCFSMConverter {
    
    private var ucfsmActions: [String: String] {
        [
            "OnEntry": "",
            "OnExit": "",
            "Internal": ""
        ]
    }
    
    func initialUCFSMMachine(filePath: URL) -> Machine {
        let name = filePath.lastPathComponent.components(separatedBy: ".machine")[0]
        let ucfsmMachine = CXXBase.Machine(
            name: name,
            path: filePath,
            includes: "",
            includePaths: [],
            funcRefs: "",
            states: [
                CXXBase.State(name: "Initial", variables: [], actions: ucfsmActions),
                CXXBase.State(name: "Suspended", variables: [], actions: ucfsmActions)
            ],
            transitions: [],
            machineVariables: [],
            initialState: 0,
            suspendedState: 1,
            actionDisplayOrder: ["OnEntry", "OnExit", "Internal"]
        )
        let converter = CXXBaseConverter()
        return converter.toMachine(machine: ucfsmMachine, semantics: .ucfsm)
    }
    
}
