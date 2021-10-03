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

struct SpartanFSMParser {
    
    var parser: CXXParser
    
    init() {
        parser = CXXParser(actions: ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"])
    }
    
    public func parseMachine(wrapper: FileWrapper) -> Machine? {
        parser.parseMachine(wrapper)
    }
    
}
