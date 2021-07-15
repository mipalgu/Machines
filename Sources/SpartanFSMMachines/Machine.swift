//
//  File.swift
//  
//
//  Created by Morgan McColl on 9/4/21.
//

import Foundation
import CXXBase

extension Machine {
    
    public init?(spartanfsmMachineAtPath path: URL) {
        let parser = SpartanFSMParser()
        guard let temp = parser.parseMachine(location: path) else {
            return nil
        }
        self = temp
    }
    
}
