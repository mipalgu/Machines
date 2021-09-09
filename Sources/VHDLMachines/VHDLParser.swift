//
//  File.swift
//  
//
//  Created by Morgan McColl on 12/6/21.
//

import Foundation

public struct VHDLParser {
    
    public func parse(filePath: URL) throws -> Machine {
        let decoder = JSONDecoder()
        let data = try Data(contentsOf: filePath)
        let machine = try decoder.decode(Machine.self, from: data)
        return machine
    }
    
    public init(){}
    
}
