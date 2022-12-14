//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

/// The VHDL implementation of an LLFSM.
public struct Machine: Codable, Equatable, Hashable {

    /// The name of the machine.
    public var name: MachineName

    /// The location of the machine in the file system.
    public var path: URL

    /// The includes for the machine.
    public var includes: [String]

    /// The external signals for the machine.
    public var externalSignals: [ExternalSignal]

    /// The generics for the machine.
    public var generics: [VHDLVariable]

    /// The clocks for the machine.
    public var clocks: [Clock]

    /// The index of the driving clock.
    public var drivingClock: Int

    /// The machines this machine depends on.
    public var dependentMachines: [MachineName: URL]

    /// The machine variables for the machine.
    public var machineVariables: [VHDLVariable]

    /// The machine signals for the machine.
    public var machineSignals: [MachineSignal]

    /// The parameters for the machine.
    public var parameterSignals: [Parameter]

    /// The returnable variables for the machine.
    public var returnableSignals: [ReturnableVariable]

    /// The states for the machine.
    public var states: [State]

    /// The transitions for the machine.
    public var transitions: [Transition]

    /// The index of the initial state for the machine.
    public var initialState: Int

    /// The index of the suspended state for the machine.
    public var suspendedState: Int?

    /// Extra asynchronous VHDL code to be added to the architecture.
    public var architectureHead: String?

    /// Extra synchronous VHDL code to be added to the architecture.
    public var architectureBody: String?

    /// Whether the machine is parameterised.
    private var _isParameterised: Bool

    /// Whether the machine is parameterised.
    public var isParameterised: Bool {
        _isParameterised && suspendedState != nil
    }

    /// Initialise a machine
    /// - Parameters:
    ///   - name: The name of the machine.
    ///   - path: The location of the machine in the file system.
    ///   - includes: The includes for the machine.
    ///   - externalSignals: The external signals for the machine.
    ///   - generics: The generics for the machine.
    ///   - clocks: The clocks for the machine.
    ///   - drivingClock: The index of the driving clock.
    ///   - dependentMachines: The machines this machine depends on.
    ///   - machineVariables: The machine variables for the machine.
    ///   - machineSignals: The machine signals for the machine.
    ///   - isParameterised: Whether the machine is parameterised.
    ///   - parameterSignals: The parameters for the machine.
    ///   - returnableSignals: The returnable variables for the machine.
    ///   - states: The states for the machine.
    ///   - transitions: The transitions for the machine.
    ///   - initialState: The index of the initial state for the machine.
    ///   - suspendedState: The index of the suspended state for the machine.
    ///   - architectureHead: The extra asynchronous VHDL code to be added to the architecture.
    ///   - architectureBody: The extra synchronous VHDL code to be added to the architecture.
    public init(
        name: MachineName,
        path: URL,
        includes: [String],
        externalSignals: [ExternalSignal],
        generics: [VHDLVariable],
        clocks: [Clock],
        drivingClock: Int,
        dependentMachines: [MachineName: URL],
        machineVariables: [VHDLVariable],
        machineSignals: [MachineSignal],
        isParameterised: Bool,
        parameterSignals: [Parameter],
        returnableSignals: [ReturnableVariable],
        states: [State],
        transitions: [Transition],
        initialState: Int,
        suspendedState: Int?,
        architectureHead: String? = nil,
        architectureBody: String? = nil
    ) {
        self.name = name
        self.path = path
        self.includes = includes
        self.externalSignals = externalSignals
        self.generics = generics
        self.clocks = clocks
        self.drivingClock = drivingClock
        self.dependentMachines = dependentMachines
        self.machineVariables = machineVariables
        self.machineSignals = machineSignals
        self._isParameterised = isParameterised
        self.parameterSignals = parameterSignals
        self.returnableSignals = returnableSignals
        self.states = states
        self.transitions = transitions
        self.initialState = initialState
        self.suspendedState = suspendedState
        self.architectureHead = architectureHead
        self.architectureBody = architectureBody
    }

}
