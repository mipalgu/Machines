// MachineRepresentation+VHDLCompilation.swift
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

public protocol MachineVHDLRepresentable {

    var actionRepresentation: [ActionName: ConstantSignal] { get }

    var actionType: SignalType { get }

    var clockPeriod: ConstantSignal { get }

    var command: SignalType { get }

    var machine: Machine { get }

    var ringletConstants: [ConstantSignal] { get }

    var statesRepresentations: [State: VectorLiteral] { get }

    var stateType: SignalType { get }

    var suspendedType: SignalType { get }

}

public extension MachineVHDLRepresentable {

    var afterVariables: String {
        let variables = (
            [LocalSignal.ringletCounter.rawValue] + ([clockPeriod] + ringletConstants).map(\.rawValue)
        ).joined(separator: "\n")
        return """
        -- After Variables
        \(variables)
        """
    }

    var architecture: String {
        """
        architecture Behavioral of \(machine.name) is
        \(architectureHead.indent(amount: 1))
        begin
        \(architectureBody.indent(amount: 1))
        end Behavioral;
        """
    }

    var architectureBody: String {
        guard let body = machine.architectureBody else {
            return """
            \(processBody)
            """
        }
        return """
        -- User-Specific Code for Architecture Body
        \(body)

        \(processBody)
        """
    }

    var architectureHead: String {
        guard let parameters = parameterSnapshots, let returnables = returnableSnapshots else {
            return """
            \(internalStateDefinition)
            \(stateRepresentation)
            \(suspensionString)
            \(afterVariables)
            \(snapshots)
            \(machineSignals)
            \(userHead)
            """.components(separatedBy: .newlines)
            .filter {
                !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            .joined(separator: "\n")
        }
        return """
        \(internalStateDefinition)
        \(stateRepresentation)
        \(suspensionString)
        \(afterVariables)
        \(snapshots)
        \(parameters)
        \(returnables)
        \(machineSignals)
        \(userHead)
        """.components(separatedBy: .newlines)
        .filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        .joined(separator: "\n")
    }

    var entity: String {
        guard let generics = generics else {
            return """
            entity \(machine.name) is
            \(port.indent(amount: 1))
            end \(machine.name);
            """
        }
        return """
        entity \(machine.name) is
        \(generics.indent(amount: 1))
        \(port.indent(amount: 1))
        end \(machine.name);
        """
    }

    var generics: String? {
        guard !machine.generics.isEmpty else {
            return nil
        }
        var signals = machine.generics.map(\.rawValue).joined(separator: "\n")
        signals.removeLast(character: ";")
        return """
        generic(
        \(signals.indent(amount: 1))
        );
        """
    }

    var internalState: LocalSignal {
        LocalSignal.internalState(actionType: actionType)
    }

    var internalStateDefinition: String {
        let actions = (actionRepresentation.values
            .sorted { $0.name.rawValue < $1.name.rawValue }
            .map(\.rawValue) + [internalState.rawValue])
            .joined(separator: "\n")
        return """
        -- Internal State Representation Bits
        \(actions)
        """
    }

    var includeStrings: String {
        machine.includes.map { $0.rawValue + ";" }.joined(separator: "\n")
    }

    var machineSignals: String {
        """
        -- Machine Signals
        \(machine.machineSignals.map(\.rawValue).joined(separator: "\n"))
        """
    }

    var parameterSnapshots: String? {
        guard machine.isParameterised else {
            return nil
        }
        return """
        -- Snapshot of Parameters
        \(machine.parameterSignals.map(\.snapshot.rawValue).joined(separator: "\n"))
        """
    }

    var port: String {
        let suspended = PortSignal.suspendedSignal(type: suspendedType)
        let commandSignal = PortSignal.commandSignal(type: command)
        let clocks = machine.clocks.map { PortSignal(clock: $0) }
        var externalSignals = (clocks + machine.externalSignals + [suspended, commandSignal])
            .map(\.rawValue)
            .joined(separator: "\n")
        externalSignals.removeLast(character: ";")
        return """
        port(
        \(externalSignals.indent(amount: 1))
        );
        """
    }

    var process: String {
        let drivingClock = machine.clocks[machine.drivingClock]
        return """
        process(\(drivingClock.name.rawValue))
        begin
        \(processBody.indent(amount: 1))
        end process;
        """
    }

    var processBody: String {
        let drivingClock = machine.clocks[machine.drivingClock]
        let actionCases = actionRepresentation.keys.compactMap { actionCase(action: $0) } + [String.nullBlock]
        let internalStateCase = "case \(VariableName.internalState.rawValue) is"
        let endCase = "end case;"
        return """
        if rising_edge(\(drivingClock.name.rawValue)) then
        \(internalStateCase.indent(amount: 1))
        \(actionCases.joined(separator: "\n").indent(amount: 2))
        \(endCase.indent(amount: 1))
        end if;
        """
    }

    var returnableSnapshots: String? {
        guard machine.isParameterised else {
            return nil
        }
        return """
        -- Snapshot of Output Signals
        \(machine.returnableSignals.map(\.snapshot.rawValue).joined(separator: "\n"))
        """
    }

    var snapshots: String {
        """
        -- Snapshot of External Signals and Variables
        \(machine.externalSignals.map(\.snapshot.rawValue).joined(separator: "\n"))
        """
    }

    var stateRepresentation: String {
        let states = statesRepresentations.compactMap {
            ConstantSignal(
                name: VariableName.name(for: $0),
                type: stateType,
                value: .literal(value: .vector(value: $1)),
                comment: nil
            )
        }
        guard states.count == statesRepresentations.count else {
            fatalError("Failed to convert states to constants.")
        }
        let statesString = states.map(\.rawValue).joined(separator: "\n")
        let trackers = LocalSignal.stateTrackers(representation: self).map(\.rawValue).joined(separator: "\n")
        return """
        -- State Representation Bits
        \(statesString)
        \(trackers)
        """
    }

    var suspensionString: String {
        """
        -- Suspension Commands
        \(SuspensionCommand.suspensionConstants.map(\.rawValue).joined(separator: "\n"))
        """
    }

    var userHead: String {
        guard let head = machine.architectureHead else {
            return ""
        }
        return """
        -- User-Specific Code for Architecture Head
        \(head)
        """
    }

    func actionCase(action: ActionName) -> String? {
        let stateImplementations: [(State, String)] = machine.states.compactMap {
            guard let implementation = $0.actions[action] else {
                return nil
            }
            return ($0, implementation.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        .filter { !$0.1.isEmpty }
        .sorted {
            $0.0.name < $1.0.name
        }
        guard !stateImplementations.isEmpty else {
            return nil
        }
        let caseStatements = stateImplementations.map { state, implementation in
            """
            when \(VariableName.name(for: state).rawValue) =>
            \(implementation.indent(amount: 1))
            """
        } + [String.nullBlock]
        let currentStateCase = "case \(VariableName.currentState.rawValue) is"
        let endCase = "end case;"
        return """
        when \(action.rawValue) =>
        \(currentStateCase.indent(amount: 1))
        \(caseStatements.joined(separator: "\n").indent(amount: 2))
        \(endCase.indent(amount: 1))
        """
    }

}
