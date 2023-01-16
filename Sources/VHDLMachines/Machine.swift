//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

/// The VHDL implementation of an LLFSM.
public struct Machine: Codable, Equatable, Hashable {

    /// The name of the machine.
    public var name: MachineName

    /// The location of the machine in the file system.
    public var path: URL

    /// The includes for the machine.
    public var includes: [Include]

    /// The external signals for the machine.
    public var externalSignals: [PortSignal]

    /// The generics for the machine.
    public var generics: [LocalSignal]

    /// The clocks for the machine.
    public var clocks: [Clock]

    /// The index of the driving clock.
    public var drivingClock: Int

    /// The machines this machine depends on.
    public var dependentMachines: [MachineName: URL]

    /// The machine signals for the machine.
    public var machineSignals: [LocalSignal]

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
    ///   - PortSignals: The external signals for the machine.
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
        includes: [Include],
        externalSignals: [PortSignal],
        generics: [LocalSignal],
        clocks: [Clock],
        drivingClock: Int,
        dependentMachines: [MachineName: URL],
        machineSignals: [LocalSignal],
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

    /// Creates an initial machine that will be located at `path`. The initial machine contains an Initial and
    /// Suspended state with the default actions (OnEntry, OnExit, Internal, OnResume, OnSuspend). This new
    /// machine is not parameterised, but does include the suspension semantics.
    /// - Parameter path: The path the new machine will be located at.
    /// - Returns: The new machine.
    public static func initial(path: URL) -> Machine {
        let name = path.lastPathComponent.components(separatedBy: ".machine")[0]
        let defaultActions = [
            VariableName.onEntry: "",
            VariableName.onExit: "",
            VariableName.internal: "",
            VariableName.onResume: "",
            VariableName.onSuspend: ""
        ]
        let actionOrder = [
            [VariableName.onResume, VariableName.onSuspend],
            [VariableName.onEntry],
            [VariableName.onExit, VariableName.internal]
        ]
        return Machine(
            name: name,
            path: path,
            includes: [.library(value: "IEEE"), .include(value: "IEEE.std_logic_1164.All")],
            externalSignals: [],
            generics: [],
            clocks: [Clock(name: VariableName.clk, frequency: 50, unit: .MHz)],
            drivingClock: 0,
            dependentMachines: [:],
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [
                State(
                    name: VariableName.initial,
                    actions: defaultActions,
                    actionOrder: actionOrder,
                    signals: [],
                    externalVariables: []
                ),
                State(
                    name: VariableName.suspendedState,
                    actions: defaultActions,
                    actionOrder: actionOrder,
                    signals: [],
                    externalVariables: []
                )
            ],
            transitions: [],
            initialState: 0,
            suspendedState: 1
        )
    }

}
