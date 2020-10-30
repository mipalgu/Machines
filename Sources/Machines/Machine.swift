/*
 * Machine.swift
 * Machines
 *
 * Created by Callum McColl on 18/9/18.
 * Copyright © 2018 Callum McColl. All rights reserved.
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

import SwiftMachines

public struct Machine: SwiftMachinesConvertible {
    
    
    public struct TransferError: Error {
        
        public var message: String
        
    }
    
    public enum Semantics: String, Hashable, Codable {
        case other
        case swiftfsm
        case clfsm
    }
    
    public var semantics: Semantics
    
    public var initialState: StateName
    
    public var suspendState: StateName
    
    public var acceptingStates: [StateName]
    
    public var states: [State]
    
    public var transitions: [Transition]
    
    public var attributes: [AttributeGroup]
    
    public init(semantics: Semantics, initialState: StateName, suspendState: StateName, acceptingStates: [StateName] = [], states: [State], transitions: [Transition] = [], attributes: [AttributeGroup]) {
        self.semantics = semantics
        self.initialState = initialState
        self.suspendState = suspendState
        self.acceptingStates = acceptingStates
        self.states = states
        self.transitions = transitions
        self.attributes = attributes
    }
    
    public init(from swiftMachine: SwiftMachines.Machine) {
        fatalError("Not Yet Implemented")
        var attributes: [AttributeGroup] = []
        let actions: [String]
        if let model = swiftMachine.model {
            actions = model.actions
            let group = AttributeGroup(
                name: "Ringlet",
                attributes: [
                    "imports": .code(model.ringlet.imports),
                    "variables": .collection(model.ringlet.vars.map {
                        Attribute.complex([
                            "access_type": .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                            "label": .line($0.label),
                            "type": .line($0.type),
                            "initial_value": .line($0.initialValue ?? "")
                        ])
                    }),
                    "execute": .code(model.ringlet.execute)
                ]
            )
            attributes.append(group)
        } else {
            actions = ["onEntry", "main", "onExit"]
        }
        let states = swiftMachine.states.map {
            State(
                name: $0.name,
                actions: Dictionary(uniqueKeysWithValues: $0.actions.map { ($0.name, $0.implementation) }),
                attributes: [
                    "variables": .collection($0.vars.map {
                        Attribute.complex([
                            "access_type": .enumerated($0.accessType.rawValue, validValues: Set(SwiftMachines.Variable.AccessType.allCases.map { $0.rawValue })),
                            "label": .line($0.label),
                            "type": .line($0.type),
                            "initial_value": .line($0.initialValue ?? "")
                        ])
                    }),
                    "external_variables": .enumerableCollection(Set($0.externalVariables?.map { $0.label } ?? []), validValues: Set(swiftMachine.externalVariables.map { $0.label })),
                    "imports": .text($0.imports)
                ]
            )
        }
    }
    
    public func swiftMachine() throws -> SwiftMachines.Machine {
        guard self.semantics == .swiftfsm else {
            throw TransferError(message: "Machine does not follow the semantics of swiftfsm")
        }
        throw TransferError(message: "Not Yet Implemented")
    }
    
}
