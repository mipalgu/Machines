//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation

public struct Machine: Codable, Hashable {
    
    var name: String
    var path: URL
    var includes: String
    var funcRefs: String
    var states: [State]
    var transitions: [Transition]
    var machineVariables: [Variable]
    
}
