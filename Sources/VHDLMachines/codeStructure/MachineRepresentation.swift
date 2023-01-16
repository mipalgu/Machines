// MachineRepresentation.swift
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

import VHDLParsing

public struct MachineRepresentation: RawRepresentable,
    Equatable, Hashable, Codable, MachineVHDLRepresentable {

    public let statesRepresentations: [State: VectorLiteral]

    public let stateType: SignalType

    public let actionRepresentation: [ActionName: ConstantSignal]

    public let commands: [SuspensionCommand: VectorLiteral]

    public let command: SignalType

    public let externalSignals: [PortSignal]

    public let machine: Machine

    public let actionType: SignalType

    public let suspendedType: SignalType

    public let ringletCounterType: SignalType

    public let clockPeriod: ConstantSignal

    public let ringletConstants: [ConstantSignal]

    public var rawValue: String {
        """
        \(includeStrings)

        \(entity)

        \(architecture)

        """
    }

    public init?(machine: Machine) {
        guard
            let actions = machine.states.first?.actions,
            let actionConstants = ConstantSignal.constants(for: actions),
            let bits = SuspensionCommand.bitRepresentation,
            let commandType = SuspensionCommand.bitsType,
            let actionType = actionConstants.first?.type,
            machine.clocks.count > machine.drivingClock,
            let stateType = SignalType.type(for: machine.states),
            let stateRepresentation = VectorLiteral.representation(for: machine.states)
        else {
            return nil
        }
        self.statesRepresentations = stateRepresentation
        self.stateType = stateType
        self.clockPeriod = ConstantSignal.clockPeriod(period: machine.clocks[machine.drivingClock].period)
        self.actionType = actionType
        self.actionRepresentation = Dictionary(
            uniqueKeysWithValues: actionConstants.map { ($0.name, $0) }
        )
        self.commands = bits
        self.command = commandType
        self.externalSignals = machine.externalSignals
        self.suspendedType = .stdLogic
        self.ringletCounterType = .natural
        self.machine = machine
        self.ringletConstants = ConstantSignal.ringletConstants
    }

    public init?(rawValue: String) {
        fatalError("Not yet supported!")
    }

}
