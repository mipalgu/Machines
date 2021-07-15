//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/5/21.
//

import Foundation

public struct VHDLGenerator {
    
    public init() {}
    
    public func generate(machine: Machine) -> Bool {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(machine) else {
            return false
        }
        let isSuccess: ()? = try? data.write(to: machine.path)
        return isSuccess != nil
    }
    
}
