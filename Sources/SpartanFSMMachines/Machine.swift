//
//  File.swift
//  
//
//  Created by Morgan McColl on 9/4/21.
//

import Foundation
import CXXBase
#if os(Linux)
import IO
#endif

extension Machine {
    
    public init?(spartanfsmMachine wrapper: FileWrapper) {
        let parser = SpartanFSMParser()
        guard let temp = parser.parseMachine(wrapper: wrapper) else {
            return nil
        }
        self = temp
    }
    
}
