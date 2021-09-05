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
              let includePaths = getIncludePaths(root: location),
              let name = getName(location: location),
              let includes = getIncludes(root: location, machineName: name),
              let funcRefs = getFuncRefs(root: location, machineName: name),
              let variables = createVariables(root: location, fileName: name),
              let initialState = getInitialState(root: location, machineName: name, states: states)
        else {
            return nil
        }
        let suspendedState = getSuspendedState(location: location, machineName: name, states: states)
        let transitions = createTransitions(root: location, states: states)
        return Machine(name: name, path: location, includes: includes, includePaths: includePaths, funcRefs: funcRefs, states: states, transitions: transitions, machineVariables: variables, initialState: initialState, suspendedState: suspendedState, actionDisplayOrder: actions)
    }
    
    func getSuspendedState(location: URL, machineName: String, states: [State]) -> Int? {
        let data = try? String(contentsOf: location.appendingPathComponent("\(machineName).mm"))
        guard let components = data?.components(separatedBy: "setSuspendState(_states["),
              components.count > 1
        else {
            return nil //states.firstIndex(where: { $0.name.lowercased() == "suspended" || $0.name.lowercased() == "suspend" })
        }
        let rhs = components[1]
        let rhsComponents = rhs.components(separatedBy: "]")
        guard rhsComponents.count > 1 else {
            return nil
        }
        return Int(rhsComponents[0])
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
        guard
            let actions = getActions(root: root, state: name),
            let variables = createVariables(root: root, fileName: "State_" + name)
        else {
            return nil;
        }
        return State(name: name, variables: variables, actions: actions)
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
    
    func getVariables(root: URL, fileName: String) -> [String]? {
        (try? String(contentsOf: root.appendingPathComponent(fileName + "_Variables.h")))?.components(separatedBy: "\n")
    }
    
    func createVariable(variable: String) -> Variable? {
        let components = variable.components(separatedBy: "\t")
        if components.count != 3 {
            return nil
        }
        let nameAndValue = components[1].components(separatedBy: "=")
        let name = nameAndValue[0]
        let value = nameAndValue.count == 2 ? nameAndValue[1] : nil
        let type = components[0]
        guard let comment = getComment(commentStr: components.last ?? "") else {
            return nil
        }
        return Variable(type: type, name: name, value: value, comment: comment)
    }
    
    func getComment(commentStr: String) -> String? {
        commentStr.components(separatedBy: "///<").last?.trimmingCharacters(in: .whitespaces)
    }
    
    func createVariables(root: URL, fileName: String) -> [Variable]? {
        guard let data = getVariables(root: root, fileName: fileName) else {
            return nil
        }
        let variableStrings = data.filter {
            if $0.hasPrefix("//") {
                return false
                
            }
            return $0.trimmingCharacters(in: .whitespacesAndNewlines) != ""
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
        (try? String(contentsOf: root.appendingPathComponent("State_" + state + "_Transition_" + String(number) + ".expr")))?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func readStateFile(root: URL, state: String) -> String? {
        try? String(contentsOf: root.appendingPathComponent("State_" + state + ".h"))
    }
    
    fileprivate func getTransitionTarget(root: URL, state: Int, number: UInt, states: [State]) -> State? {
        guard state < states.count,
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
        return Transition(source: source.name, target: target.name, condition: expression, priority: number)
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
    
    func getIncludePaths(root: URL) -> [String]? {
        guard let contents = try? String(contentsOf: root.appendingPathComponent("IncludePath")) else {
            return nil
        }
        return contents.components(separatedBy: "\n")
    }
    
    func getInitialState(root: URL, machineName: String, states: [State]) -> Int? {
        let contents = try? String(contentsOf: root.appendingPathComponent("\(machineName).mm"))
        guard
            let components = contents?.components(separatedBy: "setInitialState(_states["),
            components.count == 2,
            let indexStr = components[1].components(separatedBy: "]").first,
            let index = Int(indexStr),
            index < states.count && index >= 0
        else {
            return nil
        }
        return index
    }
    
}