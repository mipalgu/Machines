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
    
    public func parseMachine(wrapper: FileWrapper) -> Machine? {
        parser.parseMachine(wrapper)
    }
    
    public init() {
        parser = CXXParser(actions: ["OnEntry", "OnExit", "Internal"])
    }
    
}
