// ArchitectureHead+machineInit.swift
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

/// Add init for default machine representation.
extension ArchitectureHead {

    // swiftlint:disable function_body_length

    /// Create an architecture head for a machine.
    /// - Parameter machine: The machine to create the head for.
    @usableFromInline
    init?(machine: Machine) {
        guard
            let firstState = machine.states.first,
            let actions = ConstantSignal.constants(for: firstState.actions),
            let internalStateComment = Comment(rawValue: "-- Internal State Representation Bits"),
            let internalStateBits = BitLiteral.bitsRequired(for: actions.count),
            internalStateBits > 0,
            let stateRepresentationComment = Comment(rawValue: "-- State Representation Bits"),
            let commandsComment = Comment(rawValue: "-- Suspension Commands"),
            let externalSnapshotComment = Comment(rawValue: "-- Snapshot of External Signals and Variables"),
            let machineSignalComment = Comment(rawValue: "-- Machine Signals"),
            let userCodeComment = Comment(rawValue: "-- User-Specific Code for Architecture Head"),
            let stateBitsRequired = BitLiteral.bitsRequired(for: machine.states.count - 1),
            let stateTrackers = LocalSignal.stateTrackers(machine: machine)
        else {
            return nil
        }
        let actionStatements = actions.map { Statement.constant(value: $0) }
        let internalState = LocalSignal(
            type: .ranged(type: .stdLogicVector(size: .downto(upper: internalStateBits - 1, lower: 0))),
            name: .internalState,
            defaultValue: .variable(name: .readSnapshot),
            comment: nil
        )
        let stateRepresentation = machine.states.enumerated()
        .compactMap {
            ConstantSignal(state: $0.1, bitsRequired: stateBitsRequired, index: $0.0)
        }
        .map { Statement.constant(value: $0) }
        guard stateRepresentation.count == machine.states.count else {
            return nil
        }
        let stateTrackerStatements = stateTrackers.map { Statement.definition(signal: $0) }
        let commandStatements = ConstantSignal.commands.map { Statement.constant(value: $0) }
        var statements: [Statement] = [.comment(value: internalStateComment)] + actionStatements + [
            .definition(signal: internalState),
            .comment(value: stateRepresentationComment)
        ] + stateRepresentation + stateTrackerStatements + [.comment(value: commandsComment)] +
        commandStatements
        if machine.transitions.contains(where: { $0.condition.hasAfter }) {
            guard
                let afterComment = Comment(rawValue: "-- After Variables"),
                machine.drivingClock >= 0,
                machine.drivingClock < machine.clocks.count,
                let period = ConstantSignal.clockPeriod(period: machine.clocks[machine.drivingClock].period)
            else {
                return nil
            }
            let ringletConstants = ConstantSignal.ringletConstants.map { Statement.constant(value: $0) }
            statements += [
                .comment(value: afterComment), .definition(signal: .ringletCounter), .constant(value: period)
            ] + ringletConstants
        }
        statements += [.comment(value: externalSnapshotComment)] + machine.externalSignals.map {
            Statement.definition(signal: LocalSignal(snapshot: $0))
        }
        if machine.isParameterised {
            guard
                let parameterSnapshotComment = Comment(
                    rawValue: "-- Snapshot of Parameter Signals and Variables"
                ),
                let outputSnapshotComment = Comment(rawValue: "-- Snapshot of Output Signals and Variables")
            else {
                return nil
            }
            statements += [.comment(value: parameterSnapshotComment)] + machine.parameterSignals.map {
                Statement.definition(signal: LocalSignal(snapshot: $0))
            } + [.comment(value: outputSnapshotComment)] + machine.returnableSignals.map {
                Statement.definition(signal: LocalSignal(snapshot: $0))
            }
        }
        let machineSignals = machine.machineSignals.map { Statement.definition(signal: $0) }
        statements += [.comment(value: machineSignalComment)] + machineSignals +
            [.comment(value: userCodeComment)]
        self.init(statements: statements)
    }

    // swiftlint:enable function_body_length

}