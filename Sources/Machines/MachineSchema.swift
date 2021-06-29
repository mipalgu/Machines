//
//  File.swift
//  
//
//  Created by Morgan McColl on 2/6/21.
//

import Foundation
import Attributes

public protocol MachineSchema: SchemaProtocol, MachineMutatorResponder where Root == Machine {}

public extension MachineSchema {
    
    func didCreateDependency(machine: inout Machine, dependency: MachineDependency, index: Int) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didCreateNewState(machine: inout Machine, state: State, index: Int) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didCreateNewTransition(machine: inout Machine, transition: Transition, stateIndex: Int, transitionIndex: Int) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didDeleteDependency(machine: inout Machine, dependency: MachineDependency, at: Int) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didDeleteState(machine: inout Machine, state: State, at: Int) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didDeleteTransition(machine: inout Machine, transition: Transition, stateIndex: Int, at: Int) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didDeleteDependencies(machine: inout Machine, dependency: [MachineDependency], at: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didDeleteStates(machine: inout Machine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
    func didDeleteTransitions(machine: inout Machine, transition: [Transition], stateIndex: Int, at: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        return .success(false)
    }
    
}
