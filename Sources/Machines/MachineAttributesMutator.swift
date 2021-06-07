//
//  File.swift
//  
//
//  Created by Morgan McColl on 4/6/21.
//

import Foundation
import Attributes

public protocol MachineAttributesMutator {
    
    func didAddItem<Path: PathProtocol, T>(_ item: T, to attribute: Path, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T]
    
    func didMoveItems<Path: PathProtocol, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T]
    
    func didDeleteItems<Path: PathProtocol, T>(table attribute: Path, indices: IndexSet, machine: inout Machine, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T]
    
    func didDeleteItem<Path: PathProtocol, T>(attribute: Path, atIndex: Int, machine: inout Machine, item: T) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T]
}
