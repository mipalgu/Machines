//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

extension LocalSignal {

    // static var ringletCounter: LocalSignal {
    //     LocalSignal(
    //         type: .natural,
    //         name: .ringletCounter,
    //         defaultValue: .literal(value: .integer(value: 0)),
    //         comment: nil
    //     )
    // }

    // static func internalState(actionType: SignalType) -> LocalSignal {
    //     LocalSignal(
    //         type: actionType,
    //         name: .internalState,
    //         defaultValue: .variable(name: .readSnapshot),
    //         comment: nil
    //     )
    // }

    static func stateTrackers(machine: Machine) -> [LocalSignal]? {
        let states = machine.states
        guard
            let bitsRequired = BitLiteral.bitsRequired(for: states.count),
            bitsRequired > 0,
            machine.initialState > 0,
            machine.initialState < states.count,
            let suspendedStateIndex = machine.suspendedState,
            suspendedStateIndex > 0,
            suspendedStateIndex < states.count
        else {
            return nil
        }
        let range = VectorSize.downto(upper: bitsRequired - 1, lower: 0)
        let stateType = SignalType.ranged(type: .stdLogicVector(size: range))
        let suspendedState = Expression.variable(name: VariableName.name(for: states[suspendedStateIndex]))
        let initialState = Expression.variable(name: VariableName.name(for: states[machine.initialState]))
        return [
            LocalSignal(
                type: stateType,
                name: .currentState,
                defaultValue: suspendedState,
                comment: nil
            ),
            LocalSignal(
                type: stateType,
                name: .targetState,
                defaultValue: suspendedState,
                comment: nil
            ),
            LocalSignal(
                type: stateType,
                name: .previousRinglet,
                defaultValue: .literal(
                    value: .vector(
                        value: .logics(value: LogicVector(
                            values: [LogicLiteral](repeating: .highImpedance, count: range.size)
                        ))
                    )
                ),
                comment: nil
            ),
            LocalSignal(
                type: stateType,
                name: .suspendedFrom,
                defaultValue: initialState,
                comment: nil
            )
        ]
    }

}
