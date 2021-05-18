//
//  File.swift
//  
//
//  Created by Morgan McColl on 19/5/21.
//

import Foundation
import Attributes
import VHDLMachines

extension VHDLMachinesConverter: MachineMutator {
    
    
    var dependencyLayout: [Field] {
        []
    }

    func addItem<Path, T>(_ item: T, to attribute: Path, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        print("Path: \(attribute.path)")
        print("If Path: \(Machine.path.attributes[0].attributes["clocks"].wrappedValue.tableValue.path)")
        if attribute.path == Machine.path.attributes[0].attributes["clocks"].wrappedValue.tableValue.path {
            print("Adding driving clock")
            machine[keyPath: attribute.path].append(item)
            guard
                let clock = item as? [LineAttribute],
                let currentDrivingClock = machine.attributes[0].attributes["driving_clock"]
            else {
                fatalError("Failed to add clocks")
            }
            let inserted = clock[0].lineValue
            var validValues = currentDrivingClock.enumeratedValidValues
            validValues.insert(inserted)
            machine.attributes[0].attributes["driving_clock"] = Attribute(lineAttribute: .enumerated(currentDrivingClock.enumeratedValue, validValues: validValues))
            return .success(false)
        } else {
            print(machine[keyPath: attribute.path])
        }
        machine[keyPath: attribute.path].append(item)
        return .success(false)
    }

    func moveItems<Path, T>(attribute: Path, machine: inout Machine, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        machine[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
        return .success(false)
    }
    
    func newDependency(_ dependency: MachineDependency, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        .failure(AttributeError<Machine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    private func createState(named name: String, forMachine machine: Machine) throws -> State {
        guard
            machine.attributes.count == 3,
            machine.semantics == .vhdl
        else {
            throw ValidationError(message: "Missing attributes in machine", path: Machine.path.attributes)
        }
        let actions = ["OnEntry", "OnExit", "Internal", "OnSuspend", "OnResume"]
        guard
            let variables = machine.attributes.first(where: { $0.name == "variables" }),
            let externalSignals = variables.attributes["external_signals"]?.tableValue,
            let externalVariables = variables.attributes["external_variables"]?.tableValue
        else {
            fatalError("Cannot find variables when creating new state.")
        }
        let externals = externalSignals.map { $0[2].lineValue } + externalVariables.map { $0[1].lineValue }
        let defaultActionOrder = [["OnResume", "OnEntry"], ["OnExit", "Internal"], ["OnSuspend"]]
        return State(
            name: name,
            actions: actions.map { Action(name: $0, implementation: Code(""), language: .vhdl) },
            transitions: [],
            attributes: [
                AttributeGroup(
                    name: "variables",
                    fields: [
                        Field(name: "externals", type: .table(columns: [
                            ("name", .enumerated(validValues: Set(externals)))
                        ])),
                        Field(name: "state_signals", type: .table(columns: [
                            ("type", .expression(language: .vhdl)),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ])),
                        Field(name: "state_variables", type: .table(columns: [
                            ("type", .expression(language: .vhdl)),
                            ("lower_range", .line),
                            ("upper_range", .line),
                            ("name", .line),
                            ("value", .expression(language: .vhdl)),
                            ("comment", .line)
                        ]))
                    ],
                    attributes: [
                        "externals": .table([], columns: [
                            ("name", .enumerated(validValues: Set(externals)))
                        ]),
                        "state_signals": .table(
                            [],
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        ),
                        "state_variables": .table(
                            [],
                            columns: [
                                ("type", .expression(language: .vhdl)),
                                ("lower_range", .line),
                                ("upper_range", .line),
                                ("name", .line),
                                ("value", .expression(language: .vhdl)),
                                ("comment", .line)
                            ]
                        )
                    ],
                    metaData: [:]
                ),
                AttributeGroup(
                    name: "actions",
                    fields: [
                        Field(name: "action_names", type: .table(columns: [
                            ("name", .line)
                        ])),
                        Field(name: "action_order", type: .table(columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: Set(actions)))
                        ]))
                    ],
                    attributes: [
                        "action_names": .table(actions.map { [LineAttribute.line($0)] }, columns: [
                            ("name", .line)
                        ]),
                        "action_order": .table(toLineAttribute(actionOrder: defaultActionOrder, validValues: Set(actions)), columns: [
                            ("timeslot", .integer),
                            ("action", .enumerated(validValues: Set(actions)))
                        ])
                    ],
                    metaData: [:]
                )
            ]
        )
    }

    func newState(machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        let name = "State"
        if nil == machine.states.first(where: { $0.name == name }) {
            do {
                machine.states.append(try self.createState(named: name, forMachine: machine))
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to create new state", path: Machine.path.states))
            }
            self.syncSuspendState(machine: &machine)
            return .success(true)
        }
        var num = 0
        var stateName: String
        repeat {
            stateName = name + "\(num)"
            num += 1
        } while (nil != machine.states.reversed().first(where: { $0.name == stateName }))
        do {
            try machine.states.append(self.createState(named: stateName, forMachine: machine))
        } catch let e as AttributeError<Machine> {
            return .failure(e)
        } catch {
            return .failure(AttributeError(message: "Unable to create new state", path: Machine.path.states))
        }
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }

    private func syncSuspendState(machine: inout Machine) {
        let validValues = Set(machine.states.map(\.name) + [""])
        let currentValue = machine.attributes[2].attributes["suspended_state"]?.enumeratedValue ?? ""
        let newValue = validValues.contains(currentValue) ? currentValue : ""
        machine.attributes[2].fields[1].type = .enumerated(validValues: validValues)
        machine.attributes[2].attributes["suspend_state"] = .enumerated(newValue, validValues: validValues)
    }

    func newTransition(source: StateName, target: StateName, condition: Expression?, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard
            let index = machine.states.indices.first(where: { machine.states[$0].name == source }),
            nil != machine.states.first(where: { $0.name == target })
        else {
            return .failure(ValidationError(message: "You must attach a transition to a source and target state", path: Machine.path))
        }
        machine.states[index].transitions.append(Transition(condition: condition, target: target))
        return .success(false)
    }
    
    func delete(dependencies: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        .failure(AttributeError<Machine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    func delete(states: IndexSet, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        if
            let initialIndex = machine.states.enumerated().first(where: { $0.1.name == machine.initialState })?.0,
            states.contains(initialIndex)
        {
            return .failure(ValidationError(message: "You cannot delete the initial state", path: Machine.path.states[initialIndex]))
        }
        machine.states = machine.states.enumerated().filter { !states.contains($0.0) }.map { $1 }
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }
    
    func delete(transitions: IndexSet, attachedTo sourceState: StateName, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let stateIndex = machine.states.firstIndex(where: { $0.name == sourceState }) else {
            return .failure(ValidationError(message: "Unable to find state with name \(sourceState)", path: Machine.path.states))
        }
        machine.states[stateIndex].transitions = machine.states[stateIndex].transitions.enumerated().filter { !transitions.contains($0.0) }.map { $1 }
        return .success(false)
    }
    
    func deleteDependency(atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        .failure(AttributeError<Machine>(message: "Currently not supported.", path: machine.path.dependencies))
    }

    func deleteState(atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        if machine.states.count >= index {
            return .failure(ValidationError(message: "Can't delete state that doesn't exist", path: Machine.path.states))
        }
        if machine.states[index].name == machine.initialState {
            return .failure(ValidationError(message: "Can't delete the initial state", path: Machine.path.states[index]))
        }
        machine.states.remove(at: index)
        self.syncSuspendState(machine: &machine)
        return .success(true)
    }

    func deleteTransition(atIndex index: Int, attachedTo sourceState: StateName, machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        guard let index = machine.states.indices.first(where: { machine.states[$0].name == sourceState }) else {
            return .failure(ValidationError(message: "Cannot delete a transition attached to a state that does not exist", path: Machine.path.states))
        }
        guard machine.states[index].transitions.count >= index else {
            return .failure(ValidationError(message: "Cannot delete transition that does not exist", path: Machine.path.states[index].transitions))
        }
        machine.states[index].transitions.remove(at: index)
        return .success(false)
    }

    func deleteItem<Path, T>(attribute: Path, atIndex index: Int, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine, Path.Value == [T] {
        if machine[keyPath: attribute.path].count <= index || index < 0 {
            return .failure(ValidationError(message: "Invalid index '\(index)'", path: attribute))
        }
        machine[keyPath: attribute.path].remove(at: index)
        return .success(false)
    }

    private func changeName(ofState index: Int, to stateName: StateName, machine: inout Machine) throws {
        let currentName = machine.states[index].name
        if currentName == stateName {
            return
        }
        if Set(machine.states.map(\.name)).contains(stateName) {
            throw ValidationError(message: "Cannot rename state to '\(stateName)' since a state with that name already exists", path: machine.path.states[index].name)
        }
        machine[keyPath: machine.path.states[index].name.path] = stateName
        if machine.initialState == currentName {
            machine.initialState = stateName
        }
        if machine.attributes[2].attributes["suspend_state"]!.enumeratedValue == currentName {
            machine.attributes[2].attributes["suspend_state"]!.enumeratedValue = stateName
        }
        self.syncSuspendState(machine: &machine)
    }

    private func whitelist(forMachine machine: Machine) -> [AnyPath<Machine>] {
        let machinePaths = [
            AnyPath(machine.path.filePath),
            AnyPath(machine.path.initialState),
            AnyPath(machine.path.attributes[0].attributes),
            AnyPath(machine.path.attributes[1].attributes),
            AnyPath(machine.path.attributes[2].attributes)
        ]
        let statePaths: [AnyPath<Machine>] = machine.states.indices.flatMap { (stateIndex) -> [AnyPath<Machine>] in
            let attributes = [
                AnyPath(machine.path.states[stateIndex].name),
                AnyPath(machine.path.states[stateIndex].attributes[0].attributes),
                AnyPath(machine.path.states[stateIndex].attributes[1].attributes)
            ]
            let actions = machine.states[stateIndex].actions.indices.map {
                AnyPath(machine.path.states[stateIndex].actions[$0].implementation)
            }
            let transitions = machine.states[stateIndex].transitions.indices.flatMap {
                return [
                    AnyPath(machine.path.states[stateIndex].transitions[$0].condition),
                    AnyPath(machine.path.states[stateIndex].transitions[$0].target)
                ]
            }
            return attributes + actions + transitions
        }
        return machinePaths + statePaths
    }
    
    private func changeClockName(at index: Int, value: String, machine: inout Machine) {
        let currentClocks = machine.attributes[0].attributes["driving_clock"]!
        let drivingClock = currentClocks.enumeratedValue
        let oldName = machine.attributes[0].attributes["clocks"]!.tableValue[index][0].lineValue
        var newValidValues = currentClocks.enumeratedValidValues
        newValidValues.remove(oldName)
        newValidValues.insert(value)
        machine.attributes[0].attributes["driving_clock"]!.enumeratedValidValues = newValidValues
        if drivingClock == oldName {
            machine.attributes[0].attributes["driving_clock"]!.enumeratedValue = value
        }
    }

    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine {
        if let index = machine.states.indices.first(where: { Machine.path.states[$0].name.path == attribute.path }) {
            guard let stateName = value as? StateName else {
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            do {
                try self.changeName(ofState: index, to: stateName, machine: &machine)
            } catch let e as AttributeError<Machine> {
                return .failure(e)
            } catch {
                return .failure(AttributeError(message: "Unable to change name of state", path: attribute))
            }
            machine[keyPath: attribute.path] = value
            return .success(true)
        }
        if let index = machine.attributes[0].attributes["clocks"].wrappedValue.tableValue.indices.first(where: { (index) -> Bool in
            let clocksPath = Machine.path.attributes[0].attributes["clocks"].wrappedValue.tableValue
            return clocksPath[index][0].path == attribute.path ||
                clocksPath[index][0].lineValue.path == attribute.path ||
                clocksPath[index][1].path == attribute.path ||
                clocksPath[index][1].integerValue.path == attribute.path ||
                clocksPath[index][2].path == attribute.path ||
                clocksPath[index][2].enumeratedValue.path == attribute.path
        }) {
            guard let newValue = (value as? Attribute)?.lineValue ?? (value as? LineAttribute)?.lineValue ?? (value as? String) else {
                print(value)
                return .failure(ValidationError(message: "Invalid value \(value)", path: attribute))
            }
            changeClockName(at: index, value: newValue, machine: &machine)
            machine[keyPath: attribute.path] = value
            return .success(true)
        }
        if attribute.path == machine.path.attributes[0].attributes["external_signals"].wrappedValue.path {
            
        }
        machine[keyPath: attribute.path] = value
        return .success(false)
    }

    func validate(machine: Machine) throws {
        try VHDLMachinesValidator().validate(machine: machine)
    }


}
