//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import CXXBase

struct UCFSMParser {
    
    var parser: CXXParser
    
    func parseMachine(location: URL) -> Machine? {
        parser.parseMachine(location: location)
    }
    
    init() {
        parser = CXXParser(actions: ["OnEntry", "OnExit", "Internal"])
    }
    
}
