// WhenCase+machineInit.swift
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

extension WhenCase {

    init?(machine: Machine, action: VariableName) {
        switch action {
        case .readSnapshot:
            self.init(readSnapshotMachine: machine)
        case .onEntry:
            self.init(onEntryMachine: machine)
        case .onExit:
            self.init(normalAction: action, machine: machine, nextAction: .writeSnapshot)
        case .internal:
            self.init(internalMachine: machine)
        default:
            return nil
        }
    }

    private init?(state: State, action: VariableName, nextAction: VariableName) {
        guard let code = state.actions[action] else {
            return nil
        }
        self.init(condition: .expression(expression: .variable(name: .name(for: state))), code: code)
    }

    private init(onEntryMachine machine: Machine) {
        let stateCases = machine.states.compactMap {
            guard machine.hasAfter(state: $0) else {
                return WhenCase(state: $0, action: .onEntry, nextAction: .checkTransition)
            }
            let condition = WhenCondition.expression(expression: .variable(name: .name(for: $0)))
            let trailer = SynchronousBlock.statement(statement: .assignment(
                name: .ringletCounter, value: .literal(value: .integer(value: 0))
            ))
            guard let code = $0.actions[.onEntry] else {
                return WhenCase(condition: condition, code: trailer)
            }
            return WhenCase(condition: condition, code: .blocks(blocks: [code, trailer]))
        }
        let condition = WhenCondition.expression(expression: .variable(name: .onEntry))
        let trailer = SynchronousBlock.statement(statement: .assignment(
            name: .internalState, value: .variable(name: .checkTransition)
        ))
        guard !stateCases.isEmpty else {
            self.init(condition: condition, code: trailer)
            return
        }
        let statement = CaseStatement(
            condition: .variable(name: .currentState), cases: stateCases + [WhenCase.othersNull]
        )
        self.init(condition: condition, code: .blocks(blocks: [.caseStatement(block: statement), trailer]))
    }

    private init(internalMachine machine: Machine) {
        let stateCases = machine.states.compactMap {
            guard machine.hasAfter(state: $0) else {
                return WhenCase(state: $0, action: .internal, nextAction: .writeSnapshot)
            }
            let condition = WhenCondition.expression(expression: .variable(name: .name(for: $0)))
            let trailer = SynchronousBlock.statement(statement: .assignment(
                name: .ringletCounter,
                value: .binary(operation: .addition(
                    lhs: .variable(name: .ringletCounter), rhs: .literal(value: .integer(value: 1))
                ))
            ))
            guard let code = $0.actions[.internal] else {
                return WhenCase(condition: condition, code: trailer)
            }
            return WhenCase(condition: condition, code: .blocks(blocks: [code, trailer]))
        }
        let condition = WhenCondition.expression(expression: .variable(name: .internal))
        let trailer = SynchronousBlock.statement(statement: .assignment(
            name: .internalState, value: .variable(name: .writeSnapshot)
        ))
        guard !stateCases.isEmpty else {
            self.init(condition: condition, code: trailer)
            return
        }
        let statement = CaseStatement(
            condition: .variable(name: .currentState), cases: stateCases + [WhenCase.othersNull]
        )
        self.init(condition: condition, code: .blocks(blocks: [.caseStatement(block: statement), trailer]))
    }

    private init(normalAction: VariableName, machine: Machine, nextAction: VariableName) {
        let stateCases = machine.states.compactMap {
            WhenCase(state: $0, action: normalAction, nextAction: nextAction)
        }
        let condition = WhenCondition.expression(expression: .variable(name: normalAction))
        let trailer = SynchronousBlock.statement(statement: .assignment(
            name: .internalState, value: .variable(name: nextAction)
        ))
        guard !stateCases.isEmpty else {
            self.init(condition: condition, code: trailer)
            return
        }
        let statement = CaseStatement(
            condition: .variable(name: .currentState), cases: stateCases + [WhenCase.othersNull]
        )
        self.init(condition: condition, code: .blocks(blocks: [.caseStatement(block: statement), trailer]))
    }

    // swiftlint:disable function_body_length

    /// Create the `readSnapshot` case for the given machine.
    /// - Parameter machine: The machine to create the case for.
    private init?(readSnapshotMachine machine: Machine) {
        guard machine.initialState >= 0, machine.initialState < machine.states.count else {
            return nil
        }
        let whenCondition = WhenCondition.expression(expression: .variable(name: .readSnapshot))
        let initialState = machine.states[machine.initialState]
        let snapshots = machine.externalSignals.filter { $0.mode != .output }.map {
            SynchronousBlock.statement(
                statement: .assignment(name: $0.name, value: .variable(name: .name(for: $0)))
            )
        }
        // OnEntry semantics. Only perform OnEntry when previousRinglet != currentState.
        let onEntryBlock = IfBlock.ifElse(
            condition: .conditional(condition: .comparison(
                value: .notEquals(lhs: .variable(name: .previousRinglet), rhs: .variable(name: .currentState))
            )),
            ifBlock: .statement(statement: .assignment(
                name: .internalState, value: .variable(name: .onEntry)
            )),
            elseBlock: .statement(statement: .assignment(
                name: .internalState, value: .variable(name: .noOnEntry)
            ))
        )
        guard
            let suspendedIndex = machine.suspendedState,
            suspendedIndex >= 0,
            suspendedIndex < machine.states.count
        else {
            self.init(
                condition: whenCondition,
                code: .blocks(blocks: snapshots + [.ifStatement(block: onEntryBlock)])
            )
            return
        }
        var blocks: [SynchronousBlock] = snapshots
        let suspendedState = machine.states[suspendedIndex]
        /// Parameterised snapshot semantics.
        if machine.isParameterised {
            let parameterSnapshots = machine.parameterSignals.map {
                SynchronousBlock.statement(
                    statement: .assignment(name: $0.name, value: .variable(name: .name(for: $0)))
                )
            }
            blocks.append(SynchronousBlock.ifStatement(block: .ifStatement(
                // Perform snapshot of parameters on restart command.
                condition: .conditional(condition: .comparison(value: .equality(
                    lhs: .variable(name: .command),
                    rhs: .variable(name: .restartCommand)
                ))),
                ifBlock: .blocks(blocks: parameterSnapshots)
            )))
        }
        // Suspension semantics.
        blocks += [
            .ifStatement(
                block: .ifElse(
                    // Restart semantics.
                    condition: .logical(operation: .and(
                        lhs: .precedence(value: .conditional(condition: .comparison(value: .equality(
                            lhs: .variable(name: .command), rhs: .variable(name: .restartCommand)
                        )))),
                        rhs: .precedence(value: .conditional(condition: .comparison(value: .notEquals(
                            lhs: .variable(name: .currentState),
                            rhs: .variable(name: .name(for: initialState))
                        ))))
                    )),
                    ifBlock: .blocks(blocks: [
                        // Set current state to the initial state.
                        .statement(statement: .assignment(
                            name: .currentState, value: .variable(name: .name(for: initialState))
                        )),
                        .statement(statement: .assignment(
                            name: .suspended, value: .literal(value: .bit(value: .low))
                        )),
                        .statement(statement: .assignment(
                            name: .suspendedFrom, value: .variable(name: .name(for: initialState))
                        )),
                        .statement(statement: .assignment(
                            name: .targetState, value: .variable(name: .name(for: initialState))
                        )),
                        // If previously suspended perform OnResume, else perform OnEntry.
                        .ifStatement(block: .ifElse(
                            condition: .conditional(condition: .comparison(value: .equality(
                                lhs: .variable(name: .previousRinglet),
                                rhs: .variable(name: .name(for: suspendedState))
                            ))),
                            ifBlock: .statement(statement: .assignment(
                                name: .internalState, value: .variable(name: .onResume)
                            )),
                            elseBlock: .ifStatement(block: .ifElse(
                                condition: .conditional(condition: .comparison(value: .equality(
                                    lhs: .variable(name: .previousRinglet),
                                    rhs: .variable(name: .name(for: initialState))
                                ))),
                                ifBlock: .statement(statement: .assignment(
                                    name: .internalState, value: .variable(name: .noOnEntry)
                                )),
                                elseBlock: .statement(statement: .assignment(
                                    name: .internalState, value: .variable(name: .onEntry)
                                ))
                            ))
                        ))
                    ]),
                    elseBlock: .ifStatement(block: .ifElse(
                        // Resume semantics.
                        condition: .logical(operation: .and(
                            lhs: .precedence(value: .conditional(condition: .comparison(value: .equality(
                                lhs: .variable(name: .command), rhs: .variable(name: .resumeCommand)
                            )))),
                            rhs: .precedence(value: .logical(operation: .and(
                                lhs: .precedence(value: .conditional(condition: .comparison(value: .equality(
                                    lhs: .variable(name: .currentState),
                                    rhs: .variable(name: .name(for: suspendedState))
                                )))),
                                rhs: .precedence(value: .conditional(condition: .comparison(value: .notEquals(
                                    lhs: .variable(name: .suspendedFrom),
                                    rhs: .variable(name: .name(for: suspendedState))
                                ))))
                            )))
                        )),
                        // Set current state to the state the machine was suspended from.
                        ifBlock: .blocks(blocks: [
                            .statement(statement: .assignment(
                                name: .suspended, value: .literal(value: .bit(value: .low))
                            )),
                            .statement(statement: .assignment(
                                name: .currentState, value: .variable(name: .suspendedFrom)
                            )),
                            .statement(statement: .assignment(
                                name: .targetState, value: .variable(name: .suspendedFrom)
                            )),
                            // If previous state was suspended perform OnResume, else perform NoOnEntry.
                            .ifStatement(block: .ifElse(
                                condition: .conditional(condition: .comparison(value: .equality(
                                    lhs: .variable(name: .previousRinglet),
                                    rhs: .variable(name: .suspendedFrom)
                                ))),
                                ifBlock: .statement(statement: .assignment(
                                    name: .internalState, value: .variable(name: .noOnEntry)
                                )),
                                elseBlock: .statement(statement: .assignment(
                                    name: .internalState, value: .variable(name: .onResume)
                                ))
                            ))
                        ]),
                        elseBlock: .ifStatement(block: .ifElse(
                            // Suspend semantics.
                            condition: .logical(operation: .and(
                                lhs: .precedence(value: .conditional(condition: .comparison(value: .equality(
                                    lhs: .variable(name: .command), rhs: .variable(name: .suspendCommand)
                                )))),
                                rhs: .precedence(value: .conditional(condition: .comparison(value: .notEquals(
                                    lhs: .variable(name: .currentState),
                                    rhs: .variable(name: .name(for: suspendedState))
                                ))))
                            )),
                            ifBlock: .blocks(blocks: [
                                // Set current state to the suspended state.
                                .statement(statement: .assignment(
                                    name: .suspendedFrom, value: .variable(name: .currentState)
                                )),
                                .statement(statement: .assignment(
                                    name: .suspended, value: .literal(value: .bit(value: .high))
                                )),
                                .statement(statement: .assignment(
                                    name: .currentState, value: .variable(name: .name(for: suspendedState))
                                )),
                                .statement(statement: .assignment(
                                    name: .targetState, value: .variable(name: .name(for: suspendedState))
                                )),
                                // Perform OnSuspend if not in the suspended state previously.
                                .ifStatement(block: .ifElse(
                                    condition: .conditional(condition: .comparison(value: .equality(
                                        lhs: .variable(name: .previousRinglet),
                                        rhs: .variable(name: .name(for: suspendedState))
                                    ))),
                                    ifBlock: .statement(statement: .assignment(
                                        name: .internalState, value: .variable(name: .noOnEntry)
                                    )),
                                    elseBlock: .statement(statement: .assignment(
                                        name: .internalState, value: .variable(name: .onSuspend)
                                    ))
                                ))
                            ]),
                            // Suspended state execution.
                            elseBlock: .ifStatement(block: .ifElse(
                                condition: .conditional(condition: .comparison(value: .equality(
                                    lhs: .variable(name: .currentState),
                                    rhs: .variable(name: .name(for: suspendedState))
                                ))),
                                // Set suspended flag to logic high.
                                ifBlock: .blocks(blocks: [
                                    .statement(statement: .assignment(
                                        name: .suspended, value: .literal(value: .bit(value: .high))
                                    )),
                                    // Execute OnSuspend if not in the suspended state previously.
                                    .ifStatement(block: .ifElse(
                                        condition: .conditional(condition: .comparison(value: .notEquals(
                                            lhs: .variable(name: .previousRinglet),
                                            rhs: .variable(name: .name(for: suspendedState))
                                        ))),
                                        ifBlock: .statement(statement: .assignment(
                                            name: .internalState, value: .variable(name: .onSuspend)
                                        )),
                                        elseBlock: .statement(statement: .assignment(
                                            name: .internalState, value: .variable(name: .noOnEntry)
                                        ))
                                    ))
                                ]),
                                // Transition from Suspended.
                                elseBlock: .ifStatement(block: .ifElse(
                                    condition: .conditional(condition: .comparison(value: .equality(
                                        lhs: .variable(name: .previousRinglet),
                                        rhs: .variable(name: .name(for: suspendedState))
                                    ))),
                                    // Execute onResume.
                                    ifBlock: .blocks(blocks: [
                                        .statement(statement: .assignment(
                                            name: .internalState, value: .variable(name: .onResume)
                                        )),
                                        .statement(statement: .assignment(
                                            name: .suspended, value: .literal(value: .bit(value: .low))
                                        )),
                                        .statement(statement: .assignment(
                                            name: .suspendedFrom, value: .variable(name: .currentState)
                                        ))
                                    ]),
                                    // Normal execution.
                                    elseBlock: .blocks(blocks: [
                                        .statement(statement: .assignment(
                                            name: .suspended, value: .literal(value: .bit(value: .low))
                                        )),
                                        .statement(statement: .assignment(
                                            name: .suspendedFrom, value: .variable(name: .currentState)
                                        )),
                                        // Decide whether to perform OnEntry.
                                        .ifStatement(block: onEntryBlock)
                                    ])
                                ))
                            ))
                        ))
                    ))
                )
            )
        ]
        self.init(condition: whenCondition, code: .blocks(blocks: blocks))
    }

    // swiftlint:enable function_body_length

}

/// Add `hasAfter` function.
private extension Machine {

    /// Check whether a state contains a transition with an after condition.
    /// - Parameter state: The state to check.
    /// - Returns: Whether this state contains a transition with an after condition.
    func hasAfter(state: State) -> Bool {
        guard let index = self.states.firstIndex(of: state) else {
            return false
        }
        return self.transitions.lazy
            .filter { $0.source == index }
            .contains { $0.condition.hasAfter }
    }

}
