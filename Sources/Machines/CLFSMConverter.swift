//
//  CLFSMConverter.swift
//  
//
//  Created by Morgan McColl on 27/3/21.
//

import Foundation
import CXXBase
import Attributes

struct CLFSMConverter {
    
    private var clfsmActions: [String: String] {
        [
            "OnEntry": "",
            "OnExit": "",
            "Internal": "",
            "OnSuspend": "",
            "OnResume": ""
        ]
    }
    
    func initialCLFSMMachine(filePath: URL) -> Machine {
        let name = filePath.lastPathComponent.components(separatedBy: ".machine")[0]
        let clfsmMachine = CXXBase.Machine(
            name: name,
            path: filePath,
            includes: "",
            includePaths: [],
            funcRefs: "",
            states: [
                CXXBase.State(name: "Initial", variables: [], actions: clfsmActions),
                CXXBase.State(name: "Suspended", variables: [], actions: clfsmActions)
            ],
            transitions: [],
            machineVariables: [],
            initialState: 0,
            suspendedState: 1,
            actionDisplayOrder: ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        )
        let converter = CXXBaseConverter()
        return converter.toMachine(machine: clfsmMachine, semantics: .clfsm)
    }
}
