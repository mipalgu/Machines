//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import CXXBase

extension Machine {
    
    public init?(clfsmMachine wrapper: FileWrapper) {
        let parser = CLFSMParser()
        guard let temp = parser.parseMachine(wrapper: wrapper) else {
            return nil
        }
        self = temp
    }
    
}
