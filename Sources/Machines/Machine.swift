/*
 * Machine.swift
 * Machines
 *
 * Created by Callum McColl on 18/9/18.
 * Copyright © 2018 Callum McColl. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * 3. All advertising materials mentioning features or use of this
 *    software must display the following acknowledgement:
 *
 *        This product includes software developed by Callum McColl.
 *
 * 4. Neither the name of the author nor the names of contributors
 *    may be used to endorse or promote products derived from this
 *    software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * -----------------------------------------------------------------------
 * This program is free software; you can redistribute it and/or
 * modify it under the above terms or under the terms of the GNU
 * General Public License as published by the Free Software Foundation;
 * either version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see http://www.gnu.org/licenses/
 * or write to the Free Software Foundation, Inc., 51 Franklin Street,
 * Fifth Floor, Boston, MA  02110-1301, USA.
 *
 */

import Foundation
import Attributes

/// A general meta model machine.
///
/// This type is responsible for representing all possible supported semantics
/// provided by an LLFSM scheduler (swiftfsm, clfsm for example). Because the
/// meta model needs to be able to represent a wide array of semantics, this
/// data structures --- as well as other general data structures this type
/// depends on --- take a minimalistic view of LLFSM semantics. The idea here
/// is to establish a semantics within the meta model which all schedulers
/// share. Any additional data that is required for custom semantics of a
/// particular scheduler is enabled through the use of `Attribute`s and
/// `AttributeGroup`s which provide a type agnostic interface for specifying
/// such data.
///
/// Importantly, the meta model needs to be convertible to the underlying data
/// structures for specific concrete implementations --- `SwiftMachines.Machine`
/// for swiftfsm machines for example.
///
/// - SeeAlso: `SwiftMachinesConvertible`.
public struct Machine: PathContainer, Modifiable, MutatorContainer, DependenciesContainer {
    
    public typealias Mutator = MachineMutatorResponder & MachineAttributesMutator & MachineModifier
    
    public enum Semantics: String, Hashable, Codable, CaseIterable {
        case other
        case swiftfsm
        case clfsm
        case vhdl
        case ucfsm
        case spartanfsm
    }
    
    /// The semantics that are fully supported by this module.
    ///
    /// This means that it is possible to create a machine using the
    /// helper functions such as `initialMachine(forSemantics:)` or call
    /// the semantics initialiser.
    ///
    /// If you are implementing an editor, this could be used when creating a
    /// new machine to display a list of options to asking inquiring which
    /// semantics they would like to use.
    ///
    /// This array generally contains all semantics except for the `other` case.
    public static var supportedSemantics: [Machine.Semantics] {
        return Machine.Semantics.allCases.filter { $0 != .other }
    }
    
    public let mutator: Mutator
    
    public private(set) var errorBag: ErrorBag<Machine> = ErrorBag()
    
    public private(set) var id: UUID = UUID()
    
    /// The underlying semantics which this meta machine follows.
    public var semantics: Semantics
    
    /// The name of the machine.
    public var name: String {
        return self.filePath.lastPathComponent.components(separatedBy: ".")[0]
    }
    
    /// The path to the .machine directory on the file system.
    public var filePath: URL
    
    /// The name of the initial state.
    ///
    /// The name should represent the name of a state within the `states` array.
    public var initialState: StateName
    
    /// The accepting states of the machine.
    ///
    /// An accepting state is a state without any transitions.
    ///
    /// - Complexity: O(n * m) where n is the length of the `states` array and
    /// m is the length of the `transitions` array.
    public var acceptingStates: [State] {
        return self.states.filter { $0.transitions.isEmpty }
    }
    
    /// All states within the machine.
    public var states: [State]
    
    /// All machines that this machine depends on
    public var dependencies: [MachineDependency]
    
    public var dependencyAttributeType: AttributeType {
        return .complex(layout: [
            "name": .line,
            "filePath": .line,
            "attributes": .complex(layout: mutator.dependencyLayout)
        ])
    }
    
    public var dependencyAttributes: [Attribute] {
        get {
            self.dependencies.map(\.complexAttribute)
        } set {
            self.dependencies = zip(self.dependencies, newValue).map {
                var dep = $0
                dep.complexAttribute = $1
                return dep
            }
        }
    }
    
    /// A list of attributes specifying additional fields that can change.
    ///
    /// The attribute list usually details extra fields necessary for additional
    /// semantics not covered in the general meta machine model. The meta
    /// machine model takes a minimalistic point of view where the meta model
    /// represents the common semantics between different schedulers
    /// (swiftfsm, clfsm for example). Obviously each scheduler has a different
    /// feature set. The features which are not common between schedulers
    /// should be facilitated through this attributes field.
    public var attributes: [AttributeGroup]
    
    /// A list of attributes specifying additional fields that do not change.
    ///
    /// This metaData property is similar to the `attributes` property, however;
    /// the values within this field are under the control of the parsers and
    /// generators for the specific scheduler. This allows the parsers and
    /// generators to parse/generate machines which require data that the user
    /// doesn't necessarily need to know about. These fields are therefore
    /// hidden.
    ///
    /// - Attention: If you were to make a GUI using the meta model machines,
    /// then you should simply keep these values the same between modifications.
    public var metaData: [AttributeGroup]
    
    /// Fetches a keypath like structure for use when modifying and validating
    /// properties of machines.
    public var path: Path<Machine, Machine> {
        return Path(path: \.self, ancestors: [])
    }
    
    /// Fetches a keypath like structure for use when modifying and validating
    /// properties of machines.
    public static var path: Path<Machine, Machine> {
        return Path(path: \Machine.self, ancestors: [])
    }
    
    /// Create a new `Machine`.
    ///
    /// Creates a new meta machine model.
    ///
    /// - Parameter semantics: The semantics this meta machine model implements.
    ///
    /// - Parameter initialState: The name of the starting state of the machine
    /// within the `states` array.
    ///
    /// - Parameter states: All states within the machine.
    ///
    /// - Parameter attributes: All attributes of the meta machine that detail
    /// additional fields for custom semantics provided by a particular
    /// scheduler.
    ///
    /// - Parameter metaData: Attributes which should be hidden from the user,
    /// but detail additional field for custom semantics provided by a
    /// particular scheduler.
    public init(
        semantics: Semantics,
        filePath: URL,
        initialState: StateName,
        states: [State] = [],
        dependencies: [MachineDependency] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = semantics
        switch semantics {
//        case .clfsm:
//            self.mutator = CXXBaseConverter()
//        case .swiftfsm:
//            self.mutator = SwiftfsmConverter()
//        case .ucfsm:
//            self.mutator = CXXBaseConverter()
//        case .spartanfsm:
//            self.mutator = CXXBaseConverter()
//        case .vhdl:
//            self.mutator = VHDLMachinesConverter()
        case .other:
            fatalError("Use the mutator constructor if you wish to use an undefined semantics")
        default:
            fatalError("Semantics not supported")
        }
        self.filePath = filePath
        self.initialState = initialState
        self.states = states
        self.dependencies = dependencies
        self.attributes = attributes
        self.metaData = metaData
    }
    
    /// Create a new `Machine`.
    ///
    /// Creates a new meta machine model.
    ///
    /// - Parameter semantics: A `MachineMutator` responsible for performing
    /// mutating operations on the machine.
    ///
    /// - Parameter initialState: The name of the starting state of the machine
    /// within the `states` array.
    ///
    /// - Parameter states: All states within the machine.
    ///
    /// - Parameter attributes: All attributes of the meta machine that detail
    /// additional fields for custom semantics provided by a particular
    /// scheduler.
    ///
    /// - Parameter metaData: Attributes which should be hidden from the user,
    /// but detail additional field for custom semantics provided by a
    /// particular scheduler.
    public init(
        mutator: Mutator,
        filePath: URL,
        initialState: StateName,
        states: [State] = [],
        dependencies: [MachineDependency] = [],
        attributes: [AttributeGroup],
        metaData: [AttributeGroup]
    ) {
        self.semantics = .other
        self.mutator = mutator
        self.filePath = filePath
        self.initialState = initialState
        self.states = states
        self.dependencies = dependencies
        self.attributes = attributes
        self.metaData = metaData
    }
    
    /// Setup an initial machine for a specific semantics.
    ///
    /// - Parameter semantics: The semantics which the machine should follow.
    ///
    /// - Warning: The value of `semantics` should exist in the
    /// `supportedSemantics` array.
    public static func initialMachine(forSemantics semantics: Machine.Semantics, filePath: URL = URL(fileURLWithPath: "/tmp/Untitled.machine", isDirectory: true)) -> Machine {
        switch semantics {
        case .clfsm:
            return CLFSMConverter().initialCLFSMMachine(filePath: filePath)
        case .ucfsm:
            return UCFSMConverter().initialUCFSMMachine(filePath: filePath)
        case .spartanfsm:
            return SpartanFSMConverter().intialSpartanFSMMachine(filePath: filePath)
        case .swiftfsm:
            return SwiftfsmConverter().initial(filePath: filePath)
        case .vhdl:
            return VHDLMachinesConverter().initialVHDLMachine(filePath: filePath)
        case .other:
            fatalError("You cannot create an initial machine for an unknown semantics")
        }
    }
    
    /// Add a new item to a table attribute.
    public mutating func addItem<Path: PathProtocol, T>(_ item: T, to attribute: Path) -> Result<Bool, AttributeError<Machine>> where Path.Root == Machine, Path.Value == [T] {
        self[keyPath: attribute.path].append(item)
        return perform { [mutator] machine in
            mutator.didAddItem(item, to: path, machine: &machine)
        }
    }
    
    public mutating func moveItems<Path: PathProtocol, T>(table attribute: Path, from source: IndexSet, to destination: Int) -> Result<Bool, AttributeError<Machine>> where Path.Root == Machine, Path.Value == [T]  {
        let indices = Array(source)
        let items = indices.map { self[keyPath: attribute.keyPath][$0] }
        self[keyPath: attribute.path].move(fromOffsets: source, toOffset: destination)
        return perform { [mutator] machine in
            mutator.didMoveItems(attribute: attribute, machine: &machine, from: source, to: destination, items: items)
        }
    }
    
    public mutating func newDependency(_ dependency: MachineDependency) -> Result<Bool, AttributeError<Machine>> {
        if self.dependencies.contains(where: { $0.name == dependency.name }) {
            return .failure(AttributeError<Machine>(message: "The dependency '\(dependency.name)' already exists.", path: self.path.dependencies[self.dependencies.count]))
        }
        self.dependencies.append(dependency)
        guard let index = self.dependencies.firstIndex(where: { $0 == dependency }) else {
            return .failure(AttributeError(message: "Failed to find added dependency", path: Machine.path.dependencies))
        }
        return perform { [mutator] machine in
            mutator.didCreateDependency(machine: &machine, dependency: dependency, index: index)
        }
    }
    
    /// Add a new empty state to the machine.
    public mutating func newState() -> Result<Bool, AttributeError<Machine>> {
        // NEED TO CREATE STATE HERE
        guard let newState = self.states.last, let index = self.states.lastIndex(of: newState) else {
            return .failure(AttributeError(message: "Failed to find added state", path: Machine.path.states))
        }
        return perform { [mutator] machine in
            mutator.didCreateNewState(machine: &machine, state: newState, index: index)
        }
    }
    
    /// Add a new empty transition to the machine.
    public mutating func newTransition(source: StateName, target: StateName, condition: Expression? = nil) -> Result<Bool, AttributeError<Machine>> {
        guard
            let index = self.states.indices.first(where: { self.states[$0].name == source }),
            nil != self.states.first(where: { $0.name == target })
        else {
            return .failure(ValidationError(message: "You must attach a transition to a source and target state", path: Machine.path))
        }
        let transition = Transition(condition: condition, target: target)
        self.states[index].transitions.append(transition)
        guard
            let transitionIndex = self.states[index].transitions.lastIndex(where: {
                $0 == transition
            })
        else {
            return .failure(AttributeError(message: "Failed to find added transition", path: Machine.path.states[index].transitions))
        }
        return perform { [mutator] machine in
            mutator.didCreateNewTransition(machine: &machine, transition: transition, stateIndex: index, transitionIndex: transitionIndex)
        }
    }
    
    /// Delete a specific item in a table attribute.
    public mutating func deleteItem<Path: PathProtocol, T>(table attribute: Path, atIndex index: Int) -> Result<Bool, AttributeError<Machine>> where Path.Root == Machine, Path.Value == [T] {
        if self[keyPath: attribute.path].count <= index || index < 0 {
            return .failure(ValidationError(message: "Invalid index '\(index)'", path: attribute))
        }
        self[keyPath: attribute.path].remove(at: index)
        return perform { [mutator] machine in
            mutator.deleteItem(attribute: attribute, atIndex: index, machine: &machine)
        }
    }
    
    public mutating func deleteItems<Path: PathProtocol, T>(table attribute: Path, items: IndexSet) -> Result<Bool, AttributeError<Machine>> where Path.Root == Machine, Path.Value == [T] {
        perform { [mutator] machine in
            mutator.deleteItems(table: attribute, items: items, machine: &machine)
        }
    }
    
    public mutating func delete(dependencies: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        let deletedDependencies = self.dependencies.enumerated().filter { dependencies.contains($0.0) }.map(\.element)
        self.dependencies = self.dependencies.enumerated().filter { !dependencies.contains($0.0) }.map(\.element)
        return perform { [mutator] machine in
            mutator.didDeleteDependencies(machine: &machine, dependency: deletedDependencies, at: dependencies)
        }
    }
    
    /// Delete a set of states and transitions.
    public mutating func delete(states: IndexSet) -> Result<Bool, AttributeError<Machine>> {
        if
            let initialIndex = self.states.enumerated().first(where: { $0.1.name == self.initialState })?.0,
            states.contains(initialIndex)
        {
            return .failure(ValidationError(message: "You cannot delete the initial state", path: Machine.path.states[initialIndex]))
        }
        let deletedStatesArray = self.states.enumerated().filter { states.contains($0.0)  }.map(\.element)
        let deletedStates = Set(deletedStatesArray.map(\.name))
        self.states = self.states.enumerated().filter { !states.contains($0.0) }.map(\.element)
        self.states = self.states.map {
            var state = $0
            state.transitions.removeAll(where: { deletedStates.contains($0.target) })
            return state
        }
        return perform { [mutator] machine in
            mutator.didDeleteStates(machine: &machine, state: deletedStatesArray, at: states)
        }
    }
    
    public mutating func delete(transitions: IndexSet, attachedTo sourceState: StateName) -> Result<Bool, AttributeError<Machine>> {
        guard let stateIndex = self.states.firstIndex(where: { $0.name == sourceState }) else {
            return .failure(ValidationError(message: "Unable to find state with name \(sourceState)", path: Machine.path.states))
        }
        let deletedTransitions = self.states[stateIndex].transitions.enumerated().filter { transitions.contains($0.0) }.map { $1 }
        self.states[stateIndex].transitions = self.states[stateIndex].transitions.enumerated().filter { !transitions.contains($0.0) }.map { $1 }
        return perform { [mutator] machine in
            mutator.didDeleteTransitions(machine: &machine, transition: deletedTransitions, stateIndex: stateIndex, at: transitions)
        }
    }
    
    public mutating func deleteDependency(atIndex index: Int) -> Result<Bool, AttributeError<Machine>> {
        if index < 0 || index >= self.dependencies.count {
            return .failure(AttributeError<Machine>(message: "Invalid index \(index) for deleting a dependency.", path: self.path.dependencies))
        }
        let dependency = self.dependencies[index]
        self.dependencies.remove(at: index)
        return perform { [mutator] machine in
            mutator.didDeleteDependency(machine: &machine, dependency: dependency, at: index)
        }
    }
    
    /// Delete a state at a specific index.
    public mutating func deleteState(atIndex index: Int) -> Result<Bool, AttributeError<Machine>> {
        if index >= self.states.count  {
            return .failure(ValidationError(message: "Can't delete state that doesn't exist", path: Machine.path.states))
        }
        let name = self.states[index].name
        if name == self.initialState {
            return .failure(ValidationError(message: "Can't delete the initial state", path: Machine.path.states[index]))
        }
        let state = self.states[index]
        self.states.remove(at: index)
        self.states = self.states.map {
            var state = $0
            state.transitions.removeAll(where: { $0.target == name })
            return state
        }
        return perform { [mutator] machine in
            mutator.didDeleteState(machine: &machine, state: state, at: index)
        }
    }
    
    /// Delete a transition at a specific index.
    public mutating func deleteTransition(atIndex index: Int, attachedTo sourceState: StateName) -> Result<Bool, AttributeError<Machine>> {
        guard let stateIndex = self.states.indices.first(where: { self.states[$0].name == sourceState }) else {
            return .failure(ValidationError(message: "Cannot delete a transition attached to a state that does not exist", path: Machine.path.states))
        }
        guard self.states[stateIndex].transitions.count >= index else {
            return .failure(ValidationError(message: "Cannot delete transition that does not exist", path: Machine.path.states[stateIndex].transitions))
        }
        let transition = self.states[stateIndex].transitions[index]
        self.states[stateIndex].transitions.remove(at: index)
        return perform { [mutator] machine in
            mutator.didDeleteTransition(machine: &machine, transition: transition, stateIndex: stateIndex, at: index)
        }
    }
    
    /// Modify a specific attributes value.
    public mutating func modify<Path: PathProtocol>(attribute: Path, value: Path.Value) -> Result<Bool, AttributeError<Machine>> where Path.Root == Machine {
        self[keyPath: attribute.path] = value
        perform { [mutator] machine in
            mutator.modify(attribute: attribute, value: value, machine: &machine)
        }
    }
    
    /// Are there any errors with the machine?
    public func validate() throws {
        try perform { machine in
            try self.mutator.validate(machine: machine)
        }
    }
    
    private func perform(_ f: (Machine) throws -> Void) throws {
        do {
            try f(self)
        } catch let e as AttributeError<Machine> {
            throw e
        } catch let e {
            fatalError("Unsupported error: \(e)")
        }
    }
    
    private mutating func perform(_ f: (inout Machine) throws -> Void) throws {
        let backup = self
        do {
            try f(&self)
            self.errorBag.empty()
        } catch let e as AttributeError<Machine> {
            self = backup
            self.errorBag.remove(includingDescendantsForPath: e.path)
            self.errorBag.insert(e)
            throw e
        } catch let e {
            fatalError("Unsupported error: \(e)")
        }
    }
    
    private func perform(_ f: (Machine) -> Result<Bool, AttributeError<Machine>>) -> Result<Bool, AttributeError<Machine>> {
        return f(self)
    }
    
    private mutating func perform(_ f: (inout Machine) -> Result<Bool, AttributeError<Machine>>) -> Result<Bool, AttributeError<Machine>> {
        let backup = self
        let result = f(&self)
        switch result {
        case .failure(let e):
            self = backup
            self.errorBag.remove(includingDescendantsForPath: e.path)
            self.errorBag.insert(e)
            return result
        case .success:
            self.errorBag.empty()
            return result
        }
    }
    
}

extension Machine {
    
    public init(filePath: URL) throws {
        let parser = MachineParser()
        guard let machine = parser.parseMachine(atPath: filePath.path) else {
            throw ConversionError(message: parser.lastError ?? "Unable to load machine at path \(filePath.path)", path: Machine.path)
        }
        self = machine
    }
    
    public func save() throws {
        try self.validate()
        let generator = MachineGenerator()
        guard nil != generator.generate(self) else {
            throw ConversionError(message: generator.lastError ?? "Unable to save machine", path: Machine.path)
        }
    }
    
}

extension Machine: Equatable {
    
    public static func == (lhs: Machine, rhs: Machine) -> Bool {
        return lhs.semantics == rhs.semantics
            && lhs.filePath == rhs.filePath
            && lhs.initialState == rhs.initialState
            && lhs.states == rhs.states
            && lhs.attributes == rhs.attributes
            && lhs.metaData == rhs.metaData
    }
    
}

extension Machine: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.semantics)
        hasher.combine(self.filePath)
        hasher.combine(self.initialState)
        hasher.combine(self.states)
        hasher.combine(self.attributes)
        hasher.combine(self.metaData)
    }
    
}

extension Machine: Codable {
    
    public enum CodingKeys: CodingKey {
        
        case semantics
        case filePath
        case initialState
        case states
        case transitions
        case attributes
        case metaData
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let semantics = try container.decode(Semantics.self, forKey: .semantics)
        let filePath = try container.decode(URL.self, forKey: .filePath)
        let initialState = try container.decode(StateName.self, forKey: .initialState)
        let states = try container.decode([State].self, forKey: .states)
        let attributes = try container.decode([AttributeGroup].self, forKey: .attributes)
        let metaData = try container.decode([AttributeGroup].self, forKey: .metaData)
        self.init(
            semantics: semantics,
            filePath: filePath,
            initialState: initialState,
            states: states,
            attributes: attributes,
            metaData: metaData
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.semantics, forKey: .semantics)
        try container.encode(self.filePath, forKey: .filePath)
        try container.encode(self.initialState, forKey: .initialState)
        try container.encode(self.states, forKey: .states)
        try container.encode(self.attributes, forKey: .attributes)
        try container.encode(self.metaData, forKey: .metaData)
    }
    
}
