//
//  Machine+VHDLMachinesConvertible.swift
//  Machines
//
//  Created by Morgan McColl on 3/11/20.
//

import VHDLMachines

extension Machine: VHDLMachinesConvertible {
    
    public init(from vhdlMachine: VHDLMachines.ParentMachine) {
        self = createMachine(vhdlMachine: vhdlMachine)
    }
    
    fileprivate func createMachine(vhdlMachine: VHDLMachines.ParentMachine) -> Machine {
        Machine(
            semantics: .vhdl,
            name: vhdlMachine.parent.name,
            filePath: vhdlMachine.parent.path,
            initialState: vhdlMachine.parent.initialState.name,
            suspendState: vhdlMachine.parent.suspendedState.name,
            states: [vhdlStateToState(vhdl: vhdlMachine.parent.initialState), vhdlStateToState(vhdl: vhdlMachine.parent.suspendedState)] + vhdlMachine.parent.otherStates.map{vhdlStateToState(vhdl:$0)},
            transitions: vhdlTransitionsToTransition(vhdl: vhdlMachine.parent.transitions),
            variables: [
                VariableList(name: "External Variables", enabled: true, variables: vhdlMachine.parent.externalVariables.values.map {  vhdlExternalVariableToVariable(vhdl: $0)}),
                VariableList(name: "Parameters", enabled: true, variables: vhdlMachine.parent.parameters.values.map { vhdlVariableToVariable(vhdl: $0) }),
                VariableList(name: "Returned Variables", enabled: true, variables: vhdlMachine.parent.returnableVariables.values.map { vhdlVariableToVariable(vhdl: $0) }),
                VariableList(name: "Machine Variables", enabled: true, variables: vhdlMachine.parent.machineVariables.values.map { vhdlVariableToVariable(vhdl: $0) })
            ],
            attributes: [],
            metaData: []
        )
    }
    
    public func vhdlMachine() throws -> VHDLMachines.ParentMachine {
        VHDLMachines.ParentMachine(
            parent: VHDLMachines.Machine(
                name: self.name,
                path: self.filePath,
                initialState: VHDLMachines.State(ringlet: [[Action]], variables: [Variable]),
                suspendedState: <#State#>,
                otherStates: <#[State]#>,
                transitions: <#[String : [Transition]]#>,
                externalVariables: <#[String : VHDLExternalVariable]#>,
                parameters: <#[String : Parameter]#>,
                returnableVariables: <#[String : ReturnableVariable]#>,
                machineVariables: <#[String : VHDLVariable]#>,
                includes: <#String#>
            ),
            children: <#[String : Machine]#>,
            links: <#[String : [String : [Variable]]]#>
        )
    }
    
    fileprivate func vhdlStateToState(vhdl: VHDLMachines.State) -> State {
        let actionList: [VHDLMachines.Action] = vhdl.ringlet.flatMap {$0}
        var actionDict: [String: String] = [:]
        actionList.forEach { actionDict[$0.name] = $0.code }
        return State(
            name: vhdl.name,
            actions: actionDict,
            variables: [VariableList(
                name: "State Variables",
                enabled: vhdl.variables.count > 0,
                variables: vhdl.variables.map { vhdlVariableToVariable(vhdl: $0) }
            )],
            attributes: [
                AttributeGroup(
                    name: "Action Execution Order",
                    variables: VariableList(
                        name: "Actions",
                        enabled: true,
                        variables: vhdl.ringlet.map {
                            Variable(
                                label: $0.reduce("") { joinStrings(lhs: $0, rhs: $1.name) },
                                type: ""
                            )
                        }),
                    fields: ["Action Execution Order": .block],
                    attributes: <#T##[String : Attribute]#>,
                    metaData: <#T##[String : Attribute]#>
                )
            ],
            metaData: []
        )
    }
    
    fileprivate func vhdlTransitionsToTransition(vhdl: [String: [VHDLMachines.Transition]]) -> [Transition] {
        vhdl.flatMap { (fromState, transitions) in
            transitions.map {
                Transition(condition: $0.expression, source: fromState, target: $0.to.name, attributes: [], metaData: [])
            }
        }
    }
    
    
    
    fileprivate func vhdlVariableToVariable(vhdl: VHDLMachines.VHDLVariable) -> Variable {
        Variable(label: joinStrings(lhs: vhdl.signalType, rhs: vhdl.name), type: vhdl.type, extraFields: ["Default Value": .line(vhdl.initial)])
    }
    
    fileprivate func vhdlExternalVariableToVariable(vhdl: VHDLMachines.VHDLExternalVariable) -> Variable {
        Variable(
            label: joinStrings(lhs: vhdl.signalType, rhs: vhdl.name),
            type: vhdl.type,
            extraFields: [
                "Default Value": .line(vhdl.initial),
                "Mode": .line(vhdl.mode)
            ]
        )
    }
    
    fileprivate func joinStrings(lhs: String, rhs: String) -> String {
        if lhs == "" {
            return rhs
        }
        if rhs == "" {
            return lhs
        }
        return lhs + " " + rhs
    }
    
}
