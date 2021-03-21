//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

public struct Transition: Codable, Hashable {
    
    var source: State
    var target: State
    var condition: String
    
}
