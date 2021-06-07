//
//  File.swift
//  
//
//  Created by Morgan McColl on 4/6/21.
//

import Foundation
import Attributes

public protocol MachineModifier {
    
    func didModify<Path: PathProtocol>(attribute: Path, oldValue: Path.Value, newValue: Path.Value, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine
    
    func validate(machine: Machine) throws
    
}
