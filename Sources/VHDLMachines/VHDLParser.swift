//
//  File.swift
//  
//
//  Created by Morgan McColl on 12/6/21.
//

import Foundation

public struct VHDLParser {
    
    public func parse(wrapper: FileWrapper) -> Machine? {
        let decoder = JSONDecoder()
        guard
            let data = wrapper.regularFileContents,
            let machine = try? decoder.decode(Machine.self, from: data)
        else {
            return nil
        }
        return machine
    }
    
    public init(){}
    
}
