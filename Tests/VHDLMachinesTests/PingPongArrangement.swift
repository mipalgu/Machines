// PingPongArrangement.swift
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

import Foundation
import VHDLMachines

/// A factory for creating a PingPong arrangement.
struct PingPongArrangement {

    /// The path to the package root.
    let packageRootPath = URL(fileURLWithPath: #file)
        .pathComponents.prefix { $0 != "Tests" }.joined(separator: "/").dropFirst()

    /// The path to the machines folder.
    var machinesFolder: String {
        String(packageRootPath) + "/Tests/VHDLMachinesTests/machines"
    }

    /// The path to the machines folder.
    var machinePath: URL {
        URL(fileURLWithPath: machinesFolder, isDirectory: true)
    }

    /// A JSON encoder.
    private let encoder = JSONEncoder()

    /// The path to the arrangement.
    var arrangementPath: URL {
        URL(fileURLWithPath: machinesFolder + "/PingPongArrangement.json", isDirectory: false)
    }

    /// The path to the ping machine folder.
    var pingMachinePath: URL {
        URL(fileURLWithPath: machinesFolder + "/PingMachine.machine", isDirectory: true)
    }

    /// The path to the pong machine folder.
    var pongMachinePath: URL {
        URL(fileURLWithPath: machinesFolder + "/PongMachine.machine", isDirectory: true)
    }

    /// The path to the ping machine.
    var pingPath: URL {
        URL(fileURLWithPath: machinesFolder + "/PingMachine.machine/machine.json", isDirectory: false)
    }

    /// The path to the pong machine.
    var pongPath: URL {
        URL(fileURLWithPath: machinesFolder + "/PongMachine.machine/machine.json", isDirectory: false)
    }

    /// The ping states actions.
    let pingActions: [ActionName: String] = [
        "onEntry": "",
        "onExit": "ping <= '1'",
        "internal": ""
    ]

    /// The pong states actions.
    let pongActions: [ActionName: String] = [
        "onEntry": "",
        "onExit": "pong <= '1'",
        "internal": ""
    ]

    /// The action order.
    let actionOrder: [[ActionName]] = [
        ["onEntry"], ["internal", "onExit"]
    ]

    /// The Ping state.
    var pingState: State {
        State(
            name: "Ping",
            actions: pingActions,
            actionOrder: actionOrder,
            signals: [],
            variables: [],
            externalVariables: ["ping", "pong"]
        )
    }

    /// The Pong state.
    var pongState: State {
        State(
            name: "Pong",
            actions: pongActions,
            actionOrder: actionOrder,
            signals: [],
            variables: [],
            externalVariables: ["ping", "pong"]
        )
    }

    /// The ping Signals.
    let pingSignals = [
        ExternalSignal(type: "std_logic", name: "ping", mode: .output),
        ExternalSignal(type: "std_logic", name: "pong", mode: .input)
    ]

    /// The pong Signals.
    let pongSignals = [
        ExternalSignal(type: "std_logic", name: "ping", mode: .input),
        ExternalSignal(type: "std_logic", name: "pong", mode: .output)
    ]

    /// The clocks.
    let clocks = [Clock(name: "clk", frequency: 50, unit: .MHz)]

    /// The ping states transition.
    let pingTransition = Transition(condition: "true", source: 0, target: 1)

    /// The ping wait states transition.
    let pingWaitTransition = Transition(condition: "pong = '1'", source: 1, target: 0)

    /// The pong states transition.
    let pongTransition = Transition(condition: "true", source: 1, target: 0)

    /// The pong wait states transition.
    let pongWaitTransition = Transition(condition: "ping = '1'", source: 0, target: 1)

    /// The ping machine.
    var pingMachine: Machine {
        Machine(
            name: "PingMachine",
            path: pingPath,
            includes: [],
            externalSignals: pingSignals,
            generics: [],
            clocks: clocks,
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [],
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [pingState, checkState(externalVariables: ["pong"], reset: "ping")],
            transitions: [pingTransition, pingWaitTransition],
            initialState: 0,
            suspendedState: nil
        )
    }

    /// The pong machine.
    var pongMachine: Machine {
        Machine(
            name: "PongMachine",
            path: pongPath,
            includes: [],
            externalSignals: pongSignals,
            generics: [],
            clocks: clocks,
            drivingClock: 0,
            dependentMachines: [:],
            machineVariables: [],
            machineSignals: [],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [checkState(externalVariables: ["ping"], reset: "pong"), pongState],
            transitions: [pongWaitTransition, pongTransition],
            initialState: 0,
            suspendedState: nil
        )
    }

    /// The arrangement.
    var arrangement: Arrangement {
        Arrangement(
            machines: ["PingMachine": pingPath, "PongMachine": pongPath],
            externalSignals: [],
            externalVariables: [],
            clocks: clocks,
            parents: ["PingMachine", "PongMachine"],
            path: arrangementPath
        )
    }

    /// Create a check state.
    /// - Parameters:
    ///   - externalVariables: The variables to check.
    ///   - reset: What to reset.
    /// - Returns: The check state.
    func checkState(externalVariables: [String], reset: String) -> State {
        State(
            name: "Check",
            actions: emptyActions(reset: reset),
            actionOrder: actionOrder,
            signals: [],
            variables: [],
            externalVariables: externalVariables
        )
    }

    /// Write a value to a path in JSON format.
    /// - Parameters:
    ///   - path: The path to write to.
    ///   - value: The value to write.
    func write<T>(to path: URL, _ value: T) throws where T: Encodable {
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(value)
        try data.write(to: path)
    }

    /// Actions with a reset in the onExit.
    /// - Parameter reset: The reset.
    /// - Returns: The actions.
    func emptyActions(reset: String) -> [ActionName: String] {
        [
            "onEntry": "",
            "onExit": "\(reset) <= '0';",
            "internal": ""
        ]
    }

}
