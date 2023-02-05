//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation
import VHDLParsing

public extension LocalSignal {

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

    // static func stateTrackers<T>(representation: T) -> [LocalSignal] where T: MachineVHDLRepresentable {
    //     let stateType = representation.stateType
    //     let machine = representation.machine
    //     guard case .ranged(let vector) = stateType else {
    //         fatalError("Incorrect type for states.")
    //     }
    //     let range = vector.size
    //     let targetState: Expression?
    //     let firstState: Expression?
    //     if machine.states.count > machine.initialState {
    //         firstState = .variable(name: VariableName.name(for: machine.states[machine.initialState]))
    //     } else {
    //         if machine.suspendedState != 0, let state = machine.states.first {
    //             firstState = .variable(name: VariableName.name(for: state))
    //         } else {
    //             firstState = nil
    //         }
    //     }
    //     if let suspendedState = machine.suspendedState {
    //         targetState = .variable(name: VariableName.name(for: machine.states[suspendedState]))
    //     } else {
    //         targetState = firstState
    //     }
    //     return [
    //         LocalSignal(
    //             type: stateType,
    //             name: .currentState,
    //             defaultValue: targetState,
    //             comment: nil
    //         ),
    //         LocalSignal(
    //             type: stateType,
    //             name: .targetState,
    //             defaultValue: targetState,
    //             comment: nil
    //         ),
    //         LocalSignal(
    //             type: stateType,
    //             name: .previousRinglet,
    //             defaultValue: .literal(
    //                 value: .vector(
    //                     value: .logics(value:  LogicVector(
    //                         values: [LogicLiteral](repeating: .highImpedance, count: range.size)
    //                     ))
    //                 )
    //             ),
    //             comment: nil
    //         ),
    //         LocalSignal(
    //             type: stateType,
    //             name: .suspendedFrom,
    //             defaultValue: firstState,
    //             comment: nil
    //         )
    //     ]
    // }

}
