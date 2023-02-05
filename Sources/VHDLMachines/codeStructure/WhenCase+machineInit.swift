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
            guard let me = WhenCase.readSnapshot(machine: machine) else {
                return nil
            }
            self = me
        default:
            return nil
        }
    }

    private static func readSnapshot(machine: Machine) -> WhenCase? {
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
        var blocks: [SynchronousBlock] = snapshots
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
            return WhenCase(
                condition: whenCondition, code: .blocks(blocks: blocks + [.ifStatement(block: onEntryBlock)])
            )
        }
        let suspendedState = machine.states[suspendedIndex]
        if machine.isParameterised {
            let parameterSnapshots = machine.parameterSignals.map {
                SynchronousBlock.statement(
                    statement: .assignment(name: $0.name, value: .variable(name: .name(for: $0)))
                )
            }
            blocks.append(SynchronousBlock.ifStatement(block: .ifStatement(
                condition: .conditional(condition: .comparison(value: .equality(
                    lhs: .variable(name: .command),
                    rhs: .variable(name: .restartCommand)
                ))),
                ifBlock: .blocks(blocks: parameterSnapshots)
            )))
        }
        blocks += [
            .ifStatement(
                block: .ifElse(
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
                            elseBlock: .ifStatement(block: .ifElse(
                                condition: .conditional(condition: .comparison(value: .equality(
                                    lhs: .variable(name: .currentState),
                                    rhs: .variable(name: .name(for: suspendedState))
                                ))),
                                ifBlock: .blocks(blocks: [
                                    .statement(statement: .assignment(
                                        name: .suspended, value: .literal(value: .bit(value: .high))
                                    )),
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
                                elseBlock: .ifStatement(block: .ifElse(
                                    condition: .conditional(condition: .comparison(value: .equality(
                                        lhs: .variable(name: .previousRinglet),
                                        rhs: .variable(name: .name(for: suspendedState))
                                    ))),
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
                                    elseBlock: .blocks(blocks: [
                                        .statement(statement: .assignment(
                                            name: .suspended, value: .literal(value: .bit(value: .low))
                                        )),
                                        .statement(statement: .assignment(
                                            name: .suspendedFrom, value: .variable(name: .currentState)
                                        )),
                                        .ifStatement(block: onEntryBlock)
                                    ])
                                ))
                            ))
                        ))
                    ))
                )
            )
        ]
        return WhenCase(
            condition: whenCondition, code: .blocks(blocks: blocks)
        )
    }

}
