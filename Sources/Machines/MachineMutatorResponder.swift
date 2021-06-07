//
//  File.swift
//  
//
//  Created by Morgan McColl on 7/6/21.
//

import Attributes
import Foundation

public protocol MachineMutatorResponder: DependencyLayoutContainer {
    
    func didCreateDependency(machine: inout Machine, dependency: MachineDependency, index: Int) -> Result<Bool, AttributeError<Machine>>
    
    func didCreateNewState(machine: inout Machine, state: State, index: Int) -> Result<Bool, AttributeError<Machine>>
    
    func didCreateNewTransition(machine: inout Machine, transition: Transition, stateIndex: Int, transitionIndex: Int) -> Result<Bool, AttributeError<Machine>>
    
    func didDeleteDependency(machine: inout Machine, dependency: MachineDependency, at: Int) -> Result<Bool, AttributeError<Machine>>
    
    func didDeleteState(machine: inout Machine, state: State, at: Int) -> Result<Bool, AttributeError<Machine>>
    
    func didDeleteTransition(machine: inout Machine, transition: Transition, stateIndex: Int, at: Int) -> Result<Bool, AttributeError<Machine>>
    
    func didDeleteDependencies(machine: inout Machine, dependency: [MachineDependency], at: IndexSet) -> Result<Bool, AttributeError<Machine>>
    
    func didDeleteStates(machine: inout Machine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<Machine>>
    
    func didDeleteTransitions(machine: inout Machine, transition: [Transition], stateIndex: Int, at: IndexSet) -> Result<Bool, AttributeError<Machine>>
    
}
