//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

import Foundation
import Attributes

struct SchemaMutator<Schema: MachineSchema>: MachineMutator, MachineModifier, MachineAttributesMutator {
    
    var dependencyLayout: [Field]

    var schema: Schema
    
    func didCreateDependency(machine: inout Machine, dependency: MachineDependency, index: Int) -> Result<Bool, AttributeError<Machine>> {
        schema.didCreateDependency(machine: &machine, dependency: dependency, index: index)
    }
    
    func didCreateNewState(machine: inout Machine, state: State, index: Int) -> Result<Bool, AttributeError<Machine>> {
        schema.didCreateNewState(machine: &machine, state: state, index: index)
    }
    
    func didCreateNewTransition(machine: inout Machine, transition: Transition, stateIndex: Int, transitionIndex: Int) -> Result<Bool, AttributeError<Machine>> {
        schema.didCreateNewTransition(machine: &machine, transition: transition, stateIndex: stateIndex, transitionIndex: transitionIndex)
    }
    
    func didDeleteDependencies(machine: inout Machine, dependency: [MachineDependency], at: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        schema.didDeleteDependencies(machine: &machine, dependency: dependency, at: at)
    }
    
    func didDeleteStates(machine: inout Machine, state: [State], at: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        schema.didDeleteStates(machine: &machine, state: state, at: at)
    }
    
    func didDeleteTransitions(machine: inout Machine, transition: [Transition], stateIndex: Int, at: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        schema.didDeleteTransitions(machine: &machine, transition: transition, stateIndex: stateIndex, at: at)
    }
    
    func didDeleteDependency(machine: inout Machine, dependency: MachineDependency, at: Int) -> Result<Bool, AttributeError<Machine>> {
        schema.didDeleteDependency(machine: &machine, dependency: dependency, at: at)
    }
    
    func didDeleteState(machine: inout Machine, state: State, at: Int) -> Result<Bool, AttributeError<Machine>> {
        schema.didDeleteState(machine: &machine, state: state, at: at)
    }
    
    func didDeleteTransition(machine: inout Machine, transition: Transition, stateIndex: Int, at: Int) -> Result<Bool, AttributeError<Machine>> {
        schema.didDeleteTransition(machine: &machine, transition: transition, stateIndex: stateIndex, at: at)
    }
    
    private func findTrigger<Path: PathProtocol, T>(path: Path) -> AnyTrigger<Machine> where Path.Root == Machine, Path.Value == T {
        if path.ancestors.contains(AnyPath(Machine.path.attributes)) {
            let property = schema.findProperty(path: path)
            return property.trigger
        }
        return schema.trigger
    }
    
    func didAddItem<Path, T>(_ item: T, to attribute: Path, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        let trigger = findTrigger(path: attribute)
        return trigger.performTrigger(&machine)
    }
    
    func didDeleteItems<Path: PathProtocol, T>(table attribute: Path, indices: IndexSet, machine: inout Machine, items: [T]) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T] {
        let indexes = Array<Int>(indices).sorted(by: >)
        let trigger = AnyTrigger<Machine>(indexes.map { findTrigger(path: attribute[$0]) })
        indexes.forEach {
            machine[keyPath: attribute.path].remove(at: $0)
        }
        return trigger.performTrigger(&machine)
    }
    
    func deleteItem<Path: PathProtocol, T>(attribute: Path, atIndex: Int, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T] {
        let trigger: AnyTrigger<Machine> = findTrigger(path: attribute)
        machine[keyPath: attribute.path].remove(at: atIndex)
        return trigger.performTrigger(&machine)
    }
    
    func moveItems<Path: PathProtocol, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T] {
        let trigger = findTrigger(path: attribute)
        machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
        return trigger.performTrigger(&machine)
    }
    
    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine {
        let trigger = findTrigger(path: attribute)
        machine[keyPath: attribute.path] = value
        return trigger.performTrigger(&machine)
    }
    
    func validate(machine: Machine) throws {
        try schema.validator.performValidation(machine)
    }

}
