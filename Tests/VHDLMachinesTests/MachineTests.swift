// MachineTests.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

@testable import VHDLMachines
import XCTest

/// Tests the ``Machine`` type.
final class MachineTests: XCTestCase {

    /// The machines name.
    var machineName: String {
        "M0"
    }

    /// The path to the machine.
    var path: URL {
        URL(fileURLWithPath: "/path/to/M0")
    }

    /// The includes for the machine.
    var includes: [String] {
        [
            "use IEEE.STD_LOGIC_1164.ALL;",
            "use IEEE.NUMERIC_STD.ALL;"
        ]
    }

    /// The external signals for the machine.
    var externalSignals: [ExternalSignal] {
        [
            ExternalSignal(
                type: "std_logic", name: "A", mode: .input, defaultValue: "'0'", comment: "A comment"
            )
        ]
    }

    /// The generics for the machine.
    var generics: [VHDLVariable] {
        [
            VHDLVariable(type: "integer", name: "g", defaultValue: "0", range: (0, 512), comment: "Generic g")
        ]
    }

    /// The clocks for the machine.
    var clocks: [Clock] {
        [
            Clock(name: "clk", frequency: 50, unit: .MHz)
        ]
    }

    /// The driving clock for the machine.
    var drivingClock: Int {
        0
    }

    /// The paths to the dependent machines.
    var dependentMachines: [MachineName: URL] {
        [
            "M1": URL(fileURLWithPath: "/path/to/M1"),
            "M2": URL(fileURLWithPath: "/path/to/M2")
        ]
    }

    /// The variables for the machine.
    var machineVariables: [VHDLVariable] {
        [
            VHDLVariable(
                type: "integer", name: "x", defaultValue: "1", range: (0, 65535), comment: "Variable x"
            )
        ]
    }

    /// The signals for the machine.
    var machineSignals: [LocalSignal] {
        [
            LocalSignal(type: "std_logic", name: "s", defaultValue: "'0'", comment: "Signal s")
        ]
    }

    /// The parameters for the machine.
    var parameterSignals: [Parameter] {
        [
            Parameter(type: "std_logic", name: "p", defaultValue: "'0'", comment: "Parameter p")
        ]
    }

    /// The returnable signals for the machine.
    var returnableSignals: [ReturnableVariable] {
        [
            ReturnableVariable(type: "std_logic", name: "r", comment: "Returnable r")
        ]
    }

    /// The states in the machine.
    var states: [State] {
        [
            State(
                name: "S0", actions: [:], actionOrder: [], signals: [], variables: [], externalVariables: []
            ),
            State(
                name: "S1", actions: [:], actionOrder: [], signals: [], variables: [], externalVariables: []
            )
        ]
    }

    /// The transitions in the machine.
    var transitions: [Transition] {
        [
            Transition(condition: "true", source: 0, target: 1),
            Transition(condition: "true", source: 1, target: 0)
        ]
    }

    /// The index of the initial state.
    var initialState: Int {
        0
    }

    /// The index of the suspended state.
    var suspendedState: Int {
        1
    }

    /// The architecture head for the machine.
    var architectureHead: String {
        "abcd"
    }

    /// The architecture body for the machine.
    var architectureBody: String {
        "efgh"
    }

    /// The machine to test.
    lazy var machine = Machine(
        name: machineName,
        path: path,
        includes: includes,
        externalSignals: externalSignals,
        generics: generics,
        clocks: clocks,
        drivingClock: drivingClock,
        dependentMachines: dependentMachines,
        machineVariables: machineVariables,
        machineSignals: machineSignals,
        isParameterised: true,
        parameterSignals: parameterSignals,
        returnableSignals: returnableSignals,
        states: states,
        transitions: transitions,
        initialState: initialState,
        suspendedState: suspendedState,
        architectureHead: architectureHead,
        architectureBody: architectureBody
    )

    /// Initialises the test.
    override func setUp() {
        self.machine = Machine(
            name: machineName,
            path: path,
            includes: includes,
            externalSignals: externalSignals,
            generics: generics,
            clocks: clocks,
            drivingClock: drivingClock,
            dependentMachines: dependentMachines,
            machineVariables: machineVariables,
            machineSignals: machineSignals,
            isParameterised: true,
            parameterSignals: parameterSignals,
            returnableSignals: returnableSignals,
            states: states,
            transitions: transitions,
            initialState: initialState,
            suspendedState: suspendedState,
            architectureHead: architectureHead,
            architectureBody: architectureBody
        )
    }

    /// Test init sets the correct values.
    func testInit() {
        XCTAssertEqual(machine.name, machineName)
        XCTAssertEqual(machine.path, path)
        XCTAssertEqual(machine.includes, includes)
        XCTAssertEqual(machine.externalSignals, externalSignals)
        XCTAssertEqual(machine.generics, generics)
        XCTAssertEqual(machine.clocks, clocks)
        XCTAssertEqual(machine.drivingClock, drivingClock)
        XCTAssertEqual(machine.dependentMachines, dependentMachines)
        XCTAssertEqual(machine.machineVariables, machineVariables)
        XCTAssertEqual(machine.machineSignals, machineSignals)
        XCTAssertTrue(machine.isParameterised)
        XCTAssertEqual(machine.parameterSignals, parameterSignals)
        XCTAssertEqual(machine.returnableSignals, returnableSignals)
        XCTAssertEqual(machine.states, states)
        XCTAssertEqual(machine.transitions, transitions)
        XCTAssertEqual(machine.initialState, initialState)
        XCTAssertEqual(machine.suspendedState, suspendedState)
        XCTAssertEqual(machine.architectureHead, architectureHead)
        XCTAssertEqual(machine.architectureBody, architectureBody)
    }

    // swiftlint:disable function_body_length

    /// Test getters and setters work.
    func testGettersAndSetters() {
        let newMachineName = "M3"
        let newPath = URL(fileURLWithPath: "/path/to/M3")
        let newIncludes = ["use IEEE.STD_LOGIC_1164.ALL;"]
        let newExternalSignals = [
            ExternalSignal(
                type: "std_logic", name: "B", mode: .input, defaultValue: "'0'", comment: "A comment"
            )
        ]
        let newGenerics = [
            VHDLVariable(
                type: "integer", name: "g2", defaultValue: "0", range: (0, 512), comment: "Generic g2"
            )
        ]
        let newClocks = [
            Clock(name: "clk", frequency: 50, unit: .MHz), Clock(name: "clk2", frequency: 100, unit: .MHz)
        ]
        let newDrivingClock = 1
        let newDependentMachines = ["M1": URL(fileURLWithPath: "/path/to/M1")]
        let newMachineVariables = [
            VHDLVariable(
                type: "integer", name: "x2", defaultValue: "1", range: (0, 65535), comment: "Variable x2"
            )
        ]
        let newMachineSignals = [
            LocalSignal(type: "std_logic", name: "s2", defaultValue: "'0'", comment: "Signal s2")
        ]
        let newParameterSignals = [
            Parameter(type: "std_logic", name: "p2", defaultValue: "'0'", comment: "Parameter p2")
        ]
        let newReturnableSignals = [
            ReturnableVariable(type: "std_logic", name: "r2", comment: "Returnable r2")
        ]
        let newStates = [
            State(
                name: "S0", actions: [:], actionOrder: [], signals: [], variables: [], externalVariables: []
            )
        ]
        let newTransitions = [Transition(condition: "true", source: 0, target: 1)]
        let newInitialState = 1
        let newSuspendedState = 0
        let newArchitectureHead = "abcd3"
        let newArchitectureBody = "fghi"
        machine.name = newMachineName
        machine.path = newPath
        machine.includes = newIncludes
        machine.externalSignals = newExternalSignals
        machine.generics = newGenerics
        machine.clocks = newClocks
        machine.drivingClock = newDrivingClock
        machine.dependentMachines = newDependentMachines
        machine.machineVariables = newMachineVariables
        machine.machineSignals = newMachineSignals
        machine.parameterSignals = newParameterSignals
        machine.returnableSignals = newReturnableSignals
        machine.states = newStates
        machine.transitions = newTransitions
        machine.initialState = newInitialState
        machine.suspendedState = newSuspendedState
        machine.architectureHead = newArchitectureHead
        machine.architectureBody = newArchitectureBody
        XCTAssertEqual(machine.name, newMachineName)
        XCTAssertEqual(machine.path, newPath)
        XCTAssertEqual(machine.includes, newIncludes)
        XCTAssertEqual(machine.externalSignals, newExternalSignals)
        XCTAssertEqual(machine.generics, newGenerics)
        XCTAssertEqual(machine.clocks, newClocks)
        XCTAssertEqual(machine.drivingClock, newDrivingClock)
        XCTAssertEqual(machine.dependentMachines, newDependentMachines)
        XCTAssertEqual(machine.machineVariables, newMachineVariables)
        XCTAssertEqual(machine.machineSignals, newMachineSignals)
        XCTAssertEqual(machine.parameterSignals, newParameterSignals)
        XCTAssertEqual(machine.returnableSignals, newReturnableSignals)
        XCTAssertEqual(machine.states, newStates)
        XCTAssertEqual(machine.transitions, newTransitions)
        XCTAssertEqual(machine.initialState, newInitialState)
        XCTAssertEqual(machine.suspendedState, newSuspendedState)
        XCTAssertEqual(machine.architectureHead, newArchitectureHead)
        XCTAssertEqual(machine.architectureBody, newArchitectureBody)
    }

    /// Test initial machine is setup correctly.
    func testInitial() {
        let path = URL(fileURLWithPath: "NewMachine.machine", isDirectory: true)
        let defaultActions = [
            "OnEntry": "",
            "OnExit": "",
            "Internal": "",
            "OnResume": "",
            "OnSuspend": ""
        ]
        let actionOrder = [["OnResume", "OnSuspend"], ["OnEntry"], ["OnExit", "Internal"]]
        let machine = Machine.initial(path: path)
        let expected = Machine(
            name: "NewMachine",
            path: path,
            includes: ["library IEEE;", "use IEEE.std_logic_1164.All;"],
            externalSignals: [],
            generics: [],
            clocks: [Clock(name: "clk", frequency: 50, unit: .MHz)],
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [],
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [
                State(
                    name: "Initial",
                    actions: defaultActions,
                    actionOrder: actionOrder,
                    signals: [],
                    variables: [],
                    externalVariables: []
                ),
                State(
                    name: "Suspended",
                    actions: defaultActions,
                    actionOrder: actionOrder,
                    signals: [],
                    variables: [],
                    externalVariables: []
                )
            ],
            transitions: [],
            initialState: 0,
            suspendedState: 1
        )
        XCTAssertEqual(machine, expected)
    }

    // swiftlint:enable function_body_length

}