//
//  File.swift
//  
//
//  Created by Morgan McColl on 12/6/21.
//

import Foundation
#if os(Linux)
import IO
#endif

/// A parser for VHDL machines. This struct reads the contents of a `FileWrapper` and parses the machine
/// within. The `FileWrapper` must be consistent with the structure generated using ``VHDLGenerator``.
public struct VHDLParser {

    /// Create a new parser.
    public init() {}

    /// Parse a FileWrapper and return the machine within. This structure of the `FileWrapper` must be
    /// consistent with the structure generated using ``VHDLGenerator``.
    /// - Parameter wrapper: The `FileWrapper` to parse.
    /// - Returns: The machine within the `FileWrapper` or `nil` if the `FileWrapper` is not consistent with
    /// the structure generated using ``VHDLGenerator``.
    public func parse(wrapper: FileWrapper) -> Machine? {
        let decoder = JSONDecoder()
        guard
            wrapper.isDirectory,
            let files = wrapper.fileWrappers,
            let machineWrapper = files["machine.json"],
            machineWrapper.isRegularFile,
            let data = machineWrapper.regularFileContents,
            let machine = try? decoder.decode(Machine.self, from: data)
        else {
            return nil
        }
        return machine
    }

}
