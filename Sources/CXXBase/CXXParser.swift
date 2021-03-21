//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation

public struct CXXParser {
    
    let actions: [String]
    
    public init(actions: [String]) {
        self.actions = actions
    }
    
    public func parseMachine(location: URL) -> Machine? {
        guard let stateNames = getStateNames(location: location),
              let states = createStates(root: location, states: stateNames),
              let name = getName(location: location),
              let includes = getIncludes(root: location, machineName: name),
              let funcRefs = getFuncRefs(root: location, machineName: name),
              let variables = createVariables(root: location, machineName: name) else {
            return nil
        }
        let transitions = createTransitions(root: location, states: states)
        return Machine(name: name, path: location, includes: includes, funcRefs: funcRefs, states: states, transitions: transitions, machineVariables: variables)
    }
    
    func getName(location: URL) -> String? {
        return location.lastPathComponent.components(separatedBy: ".machine").first
    }
    
    func getStateNames(location: URL) -> [String]? {
        let statesFile = location.appendingPathComponent("States")
        let contents = try? String(contentsOf: statesFile)
        return contents?.components(separatedBy: "\n")
    }
    
    func getAction(root: URL, state: String, action: String) -> String? {
        try? String(contentsOf: root.appendingPathComponent("State_" + state + "_" + action + ".mm"))
    }
    
    func getActions(root: URL, state: String) -> [String: String]? {
        var actionCode: [String: String] = [:]
        for action in actions {
            guard let code = getAction(root: root, state: state, action: action) else {
                return nil
            }
            actionCode[action] = code
        }
        return actionCode
    }
    
    func createState(root: URL, name: String) -> State? {
        guard let actions = getActions(root: root, state: name) else {
            return nil;
        }
        return State(name: name, actions: actions)
    }
    
    func createStates(root: URL, states: [String]) -> [State]? {
        var stateObjs: [State] = []
        for state in states {
            guard let stateObj = createState(root: root, name: state) else {
                return nil
            }
            stateObjs.append(stateObj)
        }
        return stateObjs
    }
    
    func getIncludes(root: URL, machineName: String) -> String? {
        try? String(contentsOf: root.appendingPathComponent(machineName + "_Includes.h"))
    }
    
    func getFuncRefs(root: URL, machineName: String) -> String? {
        try? String(contentsOf: root.appendingPathComponent(machineName + "_FuncRefs.mm"))
    }
    
    func getVariables(root: URL, machineName: String) -> [String]? {
        (try? String(contentsOf: root.appendingPathComponent(machineName + "_Variables.h")))?.components(separatedBy: "\n")
    }
    
    func createVariable(variable: String) -> Variable? {
        let components = variable.components(separatedBy: "\t")
        let name = components[1]
        guard components.count != 3,
              let type = components.first,
              let comment = getComment(commentStr: components.last ?? "") else {
            return nil
        }
        return Variable(type: type, name: name, comment: comment)
    }
    
    func getComment(commentStr: String) -> String? {
        commentStr.components(separatedBy: "///<").last?.trimmingCharacters(in: .whitespaces)
    }
    
    func createVariables(root: URL, machineName: String) -> [Variable]? {
        guard let variableStrings = getVariables(root: root, machineName: machineName) else {
            return nil
        }
        var variables: [Variable] = []
        for variable in variableStrings {
            guard let variableObj = createVariable(variable: variable) else {
                return nil
            }
            variables.append(variableObj)
        }
        return variables
    }
    
    func readTransitionExpression(root: URL, state: String, number: UInt) -> String? {
        try? String(contentsOf: root.appendingPathComponent("State_" + state + "_Transition_" + String(number) + ".expr"))
    }
    
    func readStateFile(root: URL, state: String) -> String? {
        try? String(contentsOf: root.appendingPathComponent(state + ".h"))
    }
    
    fileprivate func getTransitionTarget(root: URL, state: Int, number: UInt, states: [State]) -> State? {
        guard state >= states.count,
              let contents = readStateFile(root: root, state: states[Int(state)].name) else {
            return nil
        }
        let components = contents.components(separatedBy: "Transition_" + String(number) + "(int toState = ")
        guard
            components.count > 1,
            let targetNumber = components.last?.components(separatedBy: ")").first,
            let intTargetNumber = Int(targetNumber)
        else {
            return nil
        }
        return states[intTargetNumber]
    }
    
    fileprivate func createTransitionForState(root: URL, state: Int, number: UInt, states: [State]) -> Transition? {
        let source = states[state]
        guard let target = getTransitionTarget(root: root, state: state, number: number, states: states),
              let expression = readTransitionExpression(root: root, state: source.name, number: number) else {
            return nil
        }
        return Transition(source: source, target: target, condition: expression)
    }
    
    func createTransitionsForState(root: URL, state: Int, states: [State]) -> [Transition] {
        if state >= states.count || state < 0 {
            fatalError("Invalid state index")
        }
        var number: UInt = 0
        var transitions: [Transition] = []
        while true {
            guard let transition = createTransitionForState(root: root, state: state, number: number, states: states) else {
                return transitions
            }
            transitions.append(transition)
            number += 1
        }
    }
    
    func createTransitions(root: URL, states: [State]) -> [Transition] {
        var allTransitions: [Transition] = []
        for i in 0..<states.count {
            allTransitions += createTransitionsForState(root: root, state: i, states: states)
        }
        return allTransitions
    }
    
}
