//
//  File.swift
//  
//
//  Created by Morgan McColl on 17/5/21.
//

import Foundation
#if os(Linux)
import IO
#endif

/// A generator that can generate a `FileWrapper` from a ``Machine``.
public struct VHDLGenerator {

    /// Create a new generator.
    public init() {}

    /// Generate a `FileWrapper` from a ``Machine``.
    /// - Parameter machine: The machine to generate a `FileWrapper` from.
    /// - Returns: The `FileWrapper` that represents the machine or nil if the machine could not be encoded.
    public func generate(machine: Machine) -> FileWrapper? {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(machine) else {
            return nil
        }
        let machineWrapper = FileWrapper(regularFileWithContents: data)
        machineWrapper.preferredFilename = "machine.json"
        let folderWrapper = FileWrapper(directoryWithFileWrappers: [:])
        folderWrapper.preferredFilename = "\(machine.name).machine"
        _ = folderWrapper.addFileWrapper(machineWrapper)
        return folderWrapper
    }

}
