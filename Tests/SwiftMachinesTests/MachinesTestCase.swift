/*
 * MachinesTestCase.swift 
 * MachinesTests 
 *
 * Created by Callum McColl on 19/02/2017.
 * Copyright © 2017 Callum McColl. All rights reserved.
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
import Machines
@testable import SwiftMachines
import XCTest

public class MachinesTestCase: XCTestCase {

    public var pingPongBuildDir: URL {
        return URL(fileURLWithPath: "machines/PingPong.machine/.build/PingPongMachine", isDirectory: true)
    } 

    public let pingPongFiles: [URL] = [
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Package.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/CallbackSleepingState.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/EmptySleepingState.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/factory.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/main.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/PingPongRinglet.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/PingPongVars.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/PingState.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/PongState.swift"),
        URL(fileURLWithPath: "machines/PingPong/.build/PingPongMachine/Sources/SleepingState.swift")
    ]

    public let pingPongMachine = Machine(
        name: "PingPong",
        filePath: URL(fileURLWithPath: NSString(string: "machines/PingPong.machine").standardizingPath, isDirectory: true).resolvingSymlinksInPath(),
        externalVariables: [],
        swiftIncludeSearchPaths: [
            "/usr/local/include/swiftfsm"
        ],
        includeSearchPaths: [
            "/usr/local/include",
            "../../../../..",
            "../../../../../../Common"
        ],
        libSearchPaths: [
            "/usr/local/lib",
            "/usr/local/lib/swiftfsm"
        ],
        imports: "",
        includes: nil,
        vars: [],
        model: Model(
            actions: ["onEntry"],
            stateType: "SleepingState",
            ringlet: Ringlet(
                imports: "",
                vars: [
                    Variable(
                        constant: false,
                        label: "previousState",
                        type: "SleepingState",
                        initialValue: "EmptySleepingState(\"_previous\")"
                    )
                ],
                execute: "// Call onEntry if we have just transitioned into this state.\nif (state != previousState) {\n    state.onEntry()\n}\npreviousState = state\n// Can we transition to another state?\nif let target = checkTransitions(forState: state) {\n    // Yes - Return the next state to execute.\n    return target\n}\nreturn state"
            )
        ),
        initialState: State(
            name: "Ping",
            imports: "",
            vars: [],
            actions: [
                Action(name: "onEntry", implementation: "print(\"Ping\")")
            ],
            transitions: [Transition(target: "Pong", condition: nil)],
            submachines: []
        ),
        suspendState: nil,
        states: [
            State(
                name: "Ping",
                imports: "",
                vars: [],
                actions: [
                    Action(name: "onEntry", implementation: "print(\"Ping\")")
                ],
                transitions: [Transition(target: "Pong", condition: nil)],
                submachines: []
            ),
            State(
                name: "Pong",
                imports: "",
                vars: [],
                actions: [
                    Action(name: "onEntry", implementation: "print(\"Pong\")")
                ],
                transitions: [Transition(target: "Ping", condition: nil)],
                submachines: []
            )
        ],
        submachines: []
    )

    public var controllerBuildDir: URL {
        return URL(fileURLWithPath: "machines/Controller.machine/.build/ControllerMachine", isDirectory: true)
    } 

    public let controllerFiles: [URL] = [
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachineBridging/Package.swift"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachineBridging/Controller-Bridging-Header.h"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachineBridging/module.modulemap"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachine/Package.swift"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachine/Sources/ControllerState.swift"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachine/Sources/ControllerVars.swift"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachine/Sources/ExitState.swift"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachine/Sources/wb_count.swift"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachine/Sources/factory.swift"),
        URL(fileURLWithPath: "machines/Controller/.build/ControllerMachine/Sources/main.swift")
    ]

    public var controllerMachine: Machine {
        return Machine(
            name: "Controller",
            filePath: URL(fileURLWithPath: NSString(string: "machines/Controller.machine").standardizingPath, isDirectory: true).resolvingSymlinksInPath(),
            externalVariables: [
                ExternalVariables(
                    label: "wbcount",
                    wbName: "privateWhiteboard",
                    messageType: "kCount_v",
                    messageClass: "wb_count",
                    atomic: true,
                    shouldNotifySubscribers: true
                )
            ],
            swiftIncludeSearchPaths: [
                "/usr/local/include/swiftfsm"
            ],
            includeSearchPaths: [
                "/usr/local/include",
                "../../../../..",
                "../../../../../../Common"
            ],
            libSearchPaths: [
                "/usr/local/lib",
                "/usr/local/lib/swiftfsm"
            ],
            imports: "",
            includes: "#include <gu_util.h>",
            vars: [],
            model: nil,
            initialState: State(
                name: "Controller",
                imports: "",
                vars: [
                    Variable(
                        constant: false,
                        label: "count",
                        type: "UInt8",
                        initialValue: "0"
                    )
                ],
                actions: [
                    Action(name: "onEntry", implementation: "PingPongMachine.restart()\ncount = 0"),
                    Action(name: "main", implementation: "count += 1"),
                    Action(name: "onExit", implementation: "PingPongMachine.exit()")
                ],
                transitions: [Transition(target: "Exit", condition: "state.count >= 100")],
                submachines: [self.pingPongMachine]
            ),
            suspendState: nil,
            states: [
                State(
                    name: "Controller",
                    imports: "",
                    vars: [
                        Variable(
                            constant: false,
                            label: "count",
                            type: "UInt8",
                            initialValue: "0"
                        )
                    ],
                    actions: [
                        Action(name: "onEntry", implementation: "PingPongMachine.restart()\ncount = 0"),
                        Action(name: "main", implementation: "count += 1"),
                        Action(name: "onExit", implementation: "PingPongMachine.exit()")
                    ],
                    transitions: [Transition(target: "Exit", condition: "state.count >= 100")],
                    submachines: [self.pingPongMachine]
                ),
                State(
                    name: "Exit",
                    imports: "",
                    vars: [],
                    actions: [
                        Action(name: "onEntry", implementation: ""),
                        Action(name: "main", implementation: ""),
                        Action(name: "onExit", implementation: "")
                    ],
                    transitions: [],
                    submachines: []
                )
            ],
            submachines: [self.pingPongMachine]
        )
    }

}
