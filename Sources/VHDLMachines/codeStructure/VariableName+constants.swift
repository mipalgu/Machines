// VariableName.swift
// Machines
// 
// Created by Morgan McColl.
// Copyright © 2023 Morgan McColl. All rights reserved.
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
// General License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General License for more details.
// 
// You should have received a copy of the GNU General License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

import Foundation
import VHDLParsing

public extension VariableName {

    // swiftlint:disable force_unwrapping

    static var clk: VariableName { VariableName(rawValue: "clk")! }

    static var clockPeriod: VariableName { VariableName(rawValue: "clockPeriod")! }

    static var initial: VariableName { VariableName(rawValue: "Intiial")! }

    static var suspendedState: VariableName { VariableName(rawValue: "Suspended")! }

    static var ringletLength: VariableName { VariableName(rawValue: "ringletLength")! }

    static var ringletPerPs: VariableName { VariableName(rawValue: "RINGLETS_PER_PS")! }

    static var ringletPerNs: VariableName { VariableName(rawValue: "RINGLETS_PER_NS")! }

    static var ringletPerUs: VariableName { VariableName(rawValue: "RINGLETS_PER_US")! }

    static var ringletPerMs: VariableName { VariableName(rawValue: "RINGLETS_PER_MS")! }

    static var ringletPerS: VariableName { VariableName(rawValue: "RINGLETS_PER_S")! }

    static var ringletCounter: VariableName { VariableName(rawValue: "ringlet_counter")! }

    static var suspended: VariableName { VariableName(rawValue: "suspended")! }

    static var command: VariableName { VariableName(rawValue: "command")! }

    static var currentState: VariableName { VariableName(rawValue: "currentState")! }

    static var targetState: VariableName { VariableName(rawValue: "targetState")! }

    static var previousRinglet: VariableName { VariableName(rawValue: "previousRinglet")! }

    static var suspendedFrom: VariableName { VariableName(rawValue: "suspendedFrom")! }

    static var internalState: VariableName { VariableName(rawValue: "internalState")! }

    static var readSnapshot: VariableName { VariableName(rawValue: ReservedAction.readSnapshot.rawValue)! }

    static var writeSnapshot: VariableName {
        VariableName(rawValue: ReservedAction.writeSnapshot.rawValue)!
    }

    static var checkTransition: VariableName {
        VariableName(rawValue: ReservedAction.checkTransition.rawValue)!
    }

    static var noOnEntry: VariableName { VariableName(rawValue: ReservedAction.noOnEntry.rawValue)! }

    static var onEntry: VariableName { VariableName(rawValue: "OnEntry")! }

    static var onExit: VariableName { VariableName(rawValue: "OnExit")! }

    static var onResume: VariableName { VariableName(rawValue: "OnResume")! }

    static var onSuspend: VariableName { VariableName(rawValue: "OnSuspend")! }

    static var `internal`: VariableName { VariableName(rawValue: "Internal")! }

    static var nullCommand: VariableName { VariableName(rawValue: "COMMAND_NULL")! }

    static var restartCommand: VariableName { VariableName(rawValue: "COMMAND_RESTART")! }

    static var resumeCommand: VariableName { VariableName(rawValue: "COMMAND_RESUME")! }

    static var suspendCommand: VariableName { VariableName(rawValue: "COMMAND_SUSPEND")! }

    static var zero: VariableName { VariableName(rawValue: "ZERO")! }

    static func name(for state: State) -> VariableName {
        VariableName(rawValue: "STATE_\(state.name.rawValue)")!
    }

    static func name(for external: PortSignal) -> VariableName {
        VariableName(rawValue: "EXTERNAL_\(external.name.rawValue)")!
    }

    static func name(for parameter: Parameter) -> VariableName {
        VariableName(rawValue: "PARAMETER_\(parameter.name.rawValue)")!
    }

    static func name(for returnable: ReturnableVariable) -> VariableName {
        VariableName(rawValue: "OUTPUT_\(returnable.name.rawValue)")!
    }

    // swiftlint:enable force_unwrapping

}
