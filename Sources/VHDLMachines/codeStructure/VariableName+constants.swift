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

    static var clockPeriod: VariableName { VariableName(text: "clockPeriod") }

    static var ringletLength: VariableName { VariableName(text: "ringletLength") }

    static var ringletPerPs: VariableName { VariableName(text: "RINGLETS_PER_PS") }

    static var ringletPerNs: VariableName { VariableName(text: "RINGLETS_PER_NS") }

    static var ringletPerUs: VariableName { VariableName(text: "RINGLETS_PER_US") }

    static var ringletPerMs: VariableName { VariableName(text: "RINGLETS_PER_MS") }

    static var ringletPerS: VariableName { VariableName(text: "RINGLETS_PER_S") }

    static var ringletCounter: VariableName { VariableName(text: "ringletCounter") }

    static var suspended: VariableName { VariableName(text: "suspended") }

    static var command: VariableName { VariableName(text: "command") }

    static var currentState: VariableName { VariableName(text: "currentState") }

    static var targetState: VariableName { VariableName(text: "targetState") }

    static var previousRinglet: VariableName { VariableName(text: "previousRinglet") }

    static var suspendedFrom: VariableName { VariableName(text: "suspendedFrom") }

    static var internalState: VariableName { VariableName(text: "internalState") }

    static var readSnapshot: VariableName { VariableName(text: ReservedAction.readSnapshot.rawValue) }

    static var writeSnapshot: VariableName {
        VariableName(text: ReservedAction.writeSnapshot.rawValue)
    }

    static var checkTransition: VariableName {
        VariableName(text: ReservedAction.checkTransition.rawValue)
    }

    static var noOnEntry: VariableName { VariableName(text: ReservedAction.noOnEntry.rawValue) }

    static var onEntry: VariableName { VariableName(text: "OnEntry") }

    static var onExit: VariableName { VariableName(text: "OnExit") }

    static var onResume: VariableName { VariableName(text: "OnResume") }

    static var onSuspend: VariableName { VariableName(text: "OnSuspend") }

    static var `internal`: VariableName { VariableName(text: "Internal") }

    static var nullCommand: VariableName { VariableName(text: "COMMAND_NULL") }

    static var restartCommand: VariableName { VariableName(text: "COMMAND_RESTART") }

    static var resumeCommand: VariableName { VariableName(text: "COMMAND_RESUME") }

    static var suspendCommand: VariableName { VariableName(text: "COMMAND_SUSPEND") }

    static func name(for state: State) -> VariableName {
        VariableName(text: "STATE_\(state.name.rawValue)")
    }

    static func name(for external: PortSignal) -> VariableName {
        VariableName(text: "EXTERNAL_\(external.name.rawValue)")
    }

    static func name(for parameter: Parameter) -> VariableName {
        VariableName(text: "PARAMETER_\(parameter.name.rawValue)")
    }

    static func name(for returnable: ReturnableVariable) -> VariableName {
        VariableName(text: "OUTPUT_\(returnable.name.rawValue)")
    }

}
