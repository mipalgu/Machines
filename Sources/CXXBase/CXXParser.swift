//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
#if os(Linux)
import IO
#endif

public struct CXXParser {
    
    let actions: [String]
    
    public init(actions: [String]) {
        self.actions = actions
    }
    
    public func parseMachine(_ wrapper: FileWrapper) -> Machine? {
        guard
            let files = wrapper.fileWrappers,
            let stateNames = getStateNames(files: files),
            let states = createStates(files: files, states: stateNames),
            let includePaths = getIncludePaths(files: files),
            let name = getName(wrapper: wrapper),
            let includes = getIncludes(files: files, machineName: name),
            let funcRefs = getFuncRefs(files: files, machineName: name),
            let variables = createVariables(files: files, fileName: name),
            let initialState = getInitialState(files: files, machineName: name, states: states)
        else {
            return nil
        }
        let suspendedState = getSuspendedState(files: files, machineName: name, states: states)
        let transitions = createTransitions(files: files, states: states)
        return Machine(
            name: name,
            includes: includes,
            includePaths: includePaths,
            funcRefs: funcRefs,
            states: states,
            transitions: transitions,
            machineVariables: variables,
            initialState: initialState,
            suspendedState: suspendedState,
            actionDisplayOrder: actions
        )
    }
    
    func getSuspendedState(files: [String: FileWrapper], machineName: String, states: [State]) -> Int? {
        let data = readFile(named: "\(machineName).mm", in: files)
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
    
    func getName(wrapper: FileWrapper) -> String? {
        wrapper.filename?.components(separatedBy: ".machine").first
    }
    
    func getStateNames(files: [String: FileWrapper]) -> [String]? {
        guard
            let statesFile = files["States"],
            let statesData = statesFile.regularFileContents,
            let contents = String(data: statesData, encoding: .utf8)
        else {
            return nil
        }
        return contents.components(separatedBy: "\n")
    }
    
    private func readFile(named: String, in files: [String: FileWrapper]) -> String? {
        guard
            let file = files[named],
            let data = file.regularFileContents
        else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func getAction(files: [String: FileWrapper], state: String, action: String) -> String? {
        readFile(named: "State_" + state + "_" + action + ".mm", in: files)
    }
    
    func getActions(files: [String: FileWrapper], state: String) -> [String: String]? {
        var actionCode: [String: String] = [:]
        for action in actions {
            guard let code = getAction(files: files, state: state, action: action) else {
                return nil
            }
            actionCode[action] = code
        }
        return actionCode
    }
    
    func createState(files: [String: FileWrapper], name: String) -> State? {
        guard
            let actions = getActions(files: files, state: name),
            let variables = createVariables(files: files, fileName: "State_" + name)
        else {
            return nil;
        }
        return State(name: name, variables: variables, actions: actions)
    }
    
    func createStates(files: [String: FileWrapper], states: [String]) -> [State]? {
        var stateObjs: [State] = []
        for state in states {
            guard let stateObj = createState(files: files, name: state) else {
                return nil
            }
            stateObjs.append(stateObj)
        }
        return stateObjs
    }
    
    func getIncludes(files: [String: FileWrapper], machineName: String) -> String? {
        readFile(named: machineName + "_Includes.h", in: files)
    }
    
    func getFuncRefs(files: [String: FileWrapper], machineName: String) -> String? {
        readFile(named: machineName + "_FuncRefs.mm", in: files)
    }
    
    func getVariables(files: [String: FileWrapper], fileName: String) -> [String]? {
        readFile(named: fileName + "_Variables.h", in: files)?.components(separatedBy: .newlines)
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
    
    func createVariables(files: [String: FileWrapper], fileName: String) -> [Variable]? {
        guard let data = getVariables(files: files, fileName: fileName) else {
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
    
    func readTransitionExpression(files: [String: FileWrapper], state: String, number: UInt) -> String? {
        readFile(named: "State_" + state + "_Transition_" + String(number) + ".expr", in: files)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func readStateFile(files: [String: FileWrapper], state: String) -> String? {
        readFile(named: "State_" + state + ".h", in: files)
    }
    
    fileprivate func getTransitionTarget(files: [String: FileWrapper], state: Int, number: UInt, states: [State]) -> State? {
        guard
            state < states.count,
            let contents = readStateFile(files: files, state: states[Int(state)].name)
        else {
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
    
    fileprivate func createTransitionForState(files: [String: FileWrapper], state: Int, number: UInt, states: [State]) -> Transition? {
        let source = states[state]
        guard
            let target = getTransitionTarget(files: files, state: state, number: number, states: states),
            let expression = readTransitionExpression(files: files, state: source.name, number: number)
        else {
            return nil
        }
        return Transition(source: source.name, target: target.name, condition: expression, priority: number)
    }
    
    func createTransitionsForState(files: [String: FileWrapper], state: Int, states: [State]) -> [Transition] {
        if state >= states.count || state < 0 {
            fatalError("Invalid state index")
        }
        var number: UInt = 0
        var transitions: [Transition] = []
        while true {
            guard let transition = createTransitionForState(files: files, state: state, number: number, states: states) else {
                return transitions
            }
            transitions.append(transition)
            number += 1
        }
    }
    
    func createTransitions(files: [String: FileWrapper], states: [State]) -> [Transition] {
        var allTransitions: [Transition] = []
        for i in 0..<states.count {
            allTransitions += createTransitionsForState(files: files, state: i, states: states)
        }
        return allTransitions
    }
    
    func getIncludePaths(files: [String: FileWrapper]) -> [String]? {
        readFile(named: "IncludePath", in: files)?.components(separatedBy: .newlines)
    }
    
    func getInitialState(files: [String: FileWrapper], machineName: String, states: [State]) -> Int? {
        let contents = readFile(named: "\(machineName).mm", in: files)
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
