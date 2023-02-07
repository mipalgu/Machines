//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import IO
import VHDLParsing

/// A struct that compiles a VHDL machine into a VHDL source file (vhd). The source file is located
/// within the machine folder at <machine_name>.vhd.
public struct VHDLCompiler {

    /// A file helper.
    private let helper = FileHelpers()

    /// Create a VHDL compiler.
    public init() {}

    /// Compile a machine into a VHDL source file within the machine folder specified by the machines path.
    /// - Parameter machine: The machine to compile.
    /// - Returns: Whether the compilation was successful.
    public func compile(_ machine: Machine) -> Bool {
        guard let format = generateVHDLFile(machine) else {
            return false
        }
        let fileName = "\(machine.name).vhd"
        if !helper.directoryExists(machine.path.path) {
            let manager = FileManager()
            guard (try? manager.createDirectory(
                at: machine.path, withIntermediateDirectories: true
            )) != nil else {
                return false
            }
        }
        return helper.createFile(fileName, inDirectory: machine.path, withContents: format + "\n") != nil
    }

    /// Generate the VHDL source code for a machine.
    /// - Parameter machine: The machine to compile.
    /// - Returns: The VHDL source code.
    func generateVHDLFile(_ machine: Machine) -> String? {
        guard let representation = MachineRepresentation(machine: machine) else {
            return nil
        }
        return VHDLFile(representation: representation).rawValue
    }

}
