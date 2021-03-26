//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import CXXBase

public struct UCFSMParser {
    
    var parser: CXXParser
    
    public func parseMachine(location: URL) -> Machine? {
        parser.parseMachine(location: location)
    }
    
    public init() {
        parser = CXXParser(actions: ["OnEntry", "OnExit", "Internal"])
    }
    
}
