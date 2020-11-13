//
//  VHDLMachineValidator.swift
//  Machines
//
//  Created by Morgan McColl on 3/11/20.
//

struct VHDLMachineValidator: MachineValidator {
    
    func validate(machine: Machine) throws {
        if machine.semantics != .vhdl {
            throw MachinesError.unsupportedSemantics(machine.semantics)
        }
        throw ConversionError(message: "Not Yet Implemented", path: machine.path)
    }
    
}
