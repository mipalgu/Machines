//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/5/21.
//

import Foundation

public struct VHDLGenerator {
    
    public init() {}
    
    public func generate(machine: Machine) -> FileWrapper? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(machine) else {
            return nil
        }
        return FileWrapper(regularFileWithContents: data)
    }
    
}
