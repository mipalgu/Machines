//
//  File.swift
//  
//
//  Created by Morgan McColl on 4/6/21.
//

import Foundation
import Attributes

protocol MachineModifier {
    
    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine
    
    func validate(machine: Machine) throws
    
}
