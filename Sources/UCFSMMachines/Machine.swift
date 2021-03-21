//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import CXXBase

extension Machine {
    
    public init?(ucfsmMachineAtPath path: URL) {
        let parser = UCFSMParser()
        guard let temp = parser.parseMachine(location: path) else {
            return nil
        }
        self = temp
    }
    
}
