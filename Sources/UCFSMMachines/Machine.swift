//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import CXXBase
#if os(Linux)
import IO
#endif

extension Machine {
    
    public init?(ucfsmMachine wrapper: FileWrapper) {
        let parser = UCFSMParser()
        guard let temp = parser.parseMachine(wrapper: wrapper) else {
            return nil
        }
        self = temp
    }
    
}
