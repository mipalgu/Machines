//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import CXXBase

extension Machine {
    
    public init?(clfsmMachineAtPath path: URL) {
        let parser = CLFSMParser()
        guard let temp = parser.parseMachine(location: path) else {
            return nil
        }
        self = temp
    }
    
}
