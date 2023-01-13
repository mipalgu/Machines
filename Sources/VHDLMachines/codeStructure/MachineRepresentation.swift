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

public struct MachineRepresentation: Equatable, Hashable, Codable {

    public let statesRepresentations: [State: VectorLiteral]

    public let stateType: SignalType

    public let actionRepresentation: [ActionName: ConstantSignal]

    public let commands: [SuspensionCommand: VectorLiteral]

    public let command: SignalType

    public let externalSignals: [ExternalSignal]

    public let machine: Machine

    public let actionType: SignalType

    public let suspendedType: SignalType

    public let ringletCounterType: SignalType

    public let clockPeriod: ConstantSignal

    public init?(machine: Machine) {
        guard
            let actions = machine.states.first?.actions.keys.sorted(),
            let bitsRequired = BitLiteral.bitsRequired(for: machine.states.count),
            let bits = SuspensionCommand.bitRepresentation,
            let commandType = SuspensionCommand.bitsType,
            let actionRequiredBits = BitLiteral.bitsRequired(for: actions.count),
            machine.clocks.count > machine.drivingClock
        else {
            return nil
        }
        self.statesRepresentations = Dictionary(
            uniqueKeysWithValues: machine.states.sorted { $0.name < $1.name }.enumerated().map {
                ($1, .bits(value: BitLiteral.bitVersion(of: $0, bitsRequired: bitsRequired)))
            }
        )
        self.stateType = .ranged(type: .stdLogicVector(size: .downto(upper: bitsRequired - 1, lower: 0)))
        let actionType = SignalType.ranged(
            type: .stdLogicVector(size: .downto(upper: actionRequiredBits - 1, lower: 0))
        )
        let actionConstants: [(ActionName, ConstantSignal)] = actions.enumerated().compactMap {
            guard
                let name = VariableName(rawValue: $1),
                let constant = ConstantSignal(
                    name: name,
                    type: actionType,
                    value: .literal(value: .vector(
                        value: .bits(value: BitLiteral.bitVersion(of: $0, bitsRequired: actionRequiredBits))
                    ))
                )
            else {
                return nil
            }
            return ($1, constant)
        }
        let period = Double(machine.clocks[machine.drivingClock].period.picoseconds_d)
        guard
            actionConstants.count == actions.count,
            let clockName = VariableName(rawValue: "clockPeriod"),
            let periodConstant = ConstantSignal(
                name: clockName, type: .real, value: .literal(value: .decimal(value: period))
            )
        else {
            return nil
        }
        self.clockPeriod = periodConstant
        self.actionType = actionType
        self.actionRepresentation = Dictionary(uniqueKeysWithValues: actionConstants)
        self.commands = bits
        self.command = commandType
        self.externalSignals = machine.externalSignals
        self.suspendedType = .stdLogic
        self.ringletCounterType = .natural
        self.machine = machine
    }

}
