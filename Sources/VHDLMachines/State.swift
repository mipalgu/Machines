//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct State {
    
    var actions: [ActionName: String]
    
    var actionOrder: [[ActionName]]
    
    var variables: [String]
    
    var externalVariables: [String]
    
}
