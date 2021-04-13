//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct State {
    
    public var actions: [ActionName: String]
    
    public var actionOrder: [[ActionName]]
    
    public var variables: [String]
    
    public var externalVariables: [String]
    
}
