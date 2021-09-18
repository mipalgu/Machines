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
        let machineWrapper = FileWrapper(regularFileWithContents: data)
        machineWrapper.preferredFilename = "machine.json"
        let folderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        folderWrapper.preferredFilename = "\(machine.name).machine"
        folderWrapper.addFileWrapper(machineWrapper)
        return folderWrapper
    }
    
}
