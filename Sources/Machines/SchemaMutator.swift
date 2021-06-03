//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

import Foundation
import Attributes

struct SchemaMutator<Schema: MachineSchema>: MachineMutator {
    
    var dependencyLayout: [Field]

    var schema: Schema
    
    func newDependency(_ dependency: MachineDependency, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let index = machine.dependencies.firstIndex(where: { $0 == dependency }) else {
            return .failure(AttributeError(message: "Failed to find added dependency", path: Machine.path.dependencies))
        }
        return schema.didCreateDependency(machine: &machine, dependency: dependency, index: index)
    }
    
    func newState(machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let newState = machine.states.last, let index = machine.states.lastIndex(of: newState) else {
            return .failure(AttributeError(message: "Failed to find added state", path: Machine.path.states))
        }
        return schema.didCreateNewState(machine: &machine, state: newState, index: index)
    }
    
    func newTransition(source: StateName, target: StateName, condition: Expression?, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == source }) else {
            return .failure(AttributeError(message: "Failed to find state for new transition", path: Machine.path.states))
        }
        guard
            let transitionIndex = machine.states[stateIndex].transitions.lastIndex(where: {
                $0.condition == (condition ?? "") && $0.target == target
            })
        else {
            return .failure(AttributeError(message: "Failed to find added transition", path: Machine.path.states[stateIndex].transitions))
        }
        let transition = machine.states[stateIndex].transitions[transitionIndex]
        return schema.didCreateNewTransition(machine: &machine, transition: transition, stateIndex: stateIndex, transitionIndex: transitionIndex)
    }
    
    func delete(dependencies: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        let dependencyArray = machine.dependencies.indices.compactMap { (i: Int) -> MachineDependency? in
            if dependencies.contains(i) {
                return machine.dependencies[i]
            }
            return nil
        }
        return schema.didDeleteDependencies(machine: &machine, dependency: dependencyArray, at: dependencies)
    }
    
    func delete(states: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        let statesArray = machine.states.indices.compactMap { (i: Int) -> State? in
            if states.contains(i) {
                return machine.states[i]
            }
            return nil
        }
        return schema.didDeleteStates(machine: &machine, state: statesArray, at: states)
    }
    
    func delete(transitions: IndexSet, attachedTo sourceState: StateName, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == sourceState }) else {
            return .failure(AttributeError(message: "Failed to find state for deleted transitions", path: Machine.path.states))
        }
        let state = machine.states[stateIndex]
        let deletedTransitions = state.transitions.indices.compactMap { (i: Int) -> Transition? in
            if transitions.contains(i) {
                return state.transitions[i]
            }
            return nil
        }
        return schema.didDeleteTransitions(machine: &machine, transition: deletedTransitions, stateIndex: stateIndex, at: transitions)
    }
    
    func deleteDependency(atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        let dependency = machine.dependencies[index]
        return schema.didDeleteDependency(machine: &machine, dependency: dependency, at: index)
    }
    
    func deleteState(atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        let state = machine.states[index]
        return schema.didDeleteState(machine: &machine, state: state, at: index)
    }
    
    func deleteTransition(atIndex index: Int, attachedTo sourceState: StateName, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == sourceState }) else {
            return .failure(AttributeError(message: "Failed to find state for deleted transition", path: Machine.path.states))
        }
        return schema.didDeleteTransition(machine: &machine, transition: machine.states[stateIndex].transitions[index], stateIndex: stateIndex, at: index)
    }
    
    private func findTrigger<Path: PathProtocol, T>(path: Path) -> AnyTrigger<Machine> where Path.Root == Machine, Path.Value == T {
        if path.ancestors.contains(AnyPath(Machine.path.attributes)) {
            let property = schema.findProperty(path: path)
            return property.trigger
        }
        return schema.trigger
    }
    
    func addItem<Path, T>(_ item: T, to attribute: Path, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        let trigger = findTrigger(path: attribute)
        machine[keyPath: attribute.path].append(item)
        return trigger.performTrigger(&machine)
    }
    
    func deleteItems<Path: PathProtocol, T>(table attribute: Path, items: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path.Root == Machine, Path.Value == [T] {
        let indexes = Array<Int>(items).sorted(by: >)
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
