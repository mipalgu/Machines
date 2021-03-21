//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

public struct State: Codable, Hashable {
    var name: String
    var actions: [String: String]
}
