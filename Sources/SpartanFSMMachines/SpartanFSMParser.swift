//
//  File.swift
//  
//
//  Created by Morgan McColl on 9/4/21.
//

import Foundation
import CXXBase

struct SpartanFSMParser {
    
    var parser: CXXParser
    
    init() {
        parser = CXXParser(actions: ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"])
    }
    
    public func parseMachine(location: URL) -> Machine? {
        parser.parseMachine(location: location)
    }
    
}
