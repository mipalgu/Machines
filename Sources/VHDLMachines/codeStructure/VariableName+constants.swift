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

    static let clk = VariableName(rawValue: "clk")!

    static let clockPeriod = VariableName(rawValue: "clockPeriod")!

    static let initial = VariableName(rawValue: "Intiial")!

    static let suspendedState = VariableName(rawValue: "Suspended")!

    static let ringletLength = VariableName(rawValue: "ringletLength")!

    static let ringletPerPs = VariableName(rawValue: "RINGLETS_PER_PS")!

    static let ringletPerNs = VariableName(rawValue: "RINGLETS_PER_NS")!

    static let ringletPerUs = VariableName(rawValue: "RINGLETS_PER_US")!

    static let ringletPerMs = VariableName(rawValue: "RINGLETS_PER_MS")!

    static let ringletPerS = VariableName(rawValue: "RINGLETS_PER_S")!

    static let ringletCounter = VariableName(rawValue: "ringlet_counter")!

    static let suspended = VariableName(rawValue: "suspended")!

    static let command = VariableName(rawValue: "command")!

    static let currentState = VariableName(rawValue: "currentState")!

    static let targetState = VariableName(rawValue: "targetState")!

    static let previousRinglet = VariableName(rawValue: "previousRinglet")!

    static let suspendedFrom = VariableName(rawValue: "suspendedFrom")!

    static let internalState = VariableName(rawValue: "internalState")!

    static let readSnapshot = VariableName(rawValue: ReservedAction.readSnapshot.rawValue)!

    static let writeSnapshot = VariableName(rawValue: ReservedAction.writeSnapshot.rawValue)!

    static let checkTransition = VariableName(rawValue: ReservedAction.checkTransition.rawValue)!

    static let noOnEntry = VariableName(rawValue: ReservedAction.noOnEntry.rawValue)!

    static let onEntry = VariableName(rawValue: "OnEntry")!

    static let onExit = VariableName(rawValue: "OnExit")!

    static let onResume = VariableName(rawValue: "OnResume")!

    static let onSuspend = VariableName(rawValue: "OnSuspend")!

    static let `internal` = VariableName(rawValue: "Internal")!

    static let nullCommand = VariableName(rawValue: "COMMAND_NULL")!

    static let restartCommand = VariableName(rawValue: "COMMAND_RESTART")!

    static let resumeCommand = VariableName(rawValue: "COMMAND_RESUME")!

    static let suspendCommand = VariableName(rawValue: "COMMAND_SUSPEND")!

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
