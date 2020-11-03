//
//  ReturnableVariable.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

struct ReturnableVariable: VHDLExternalVariable {
    
    var mode: String
    
    var variable: Variable
    
    var signalType: String {
        get {
            variable.signalType
        }
        set {
            variable.signalType = newValue
        }
    }
    
    var name: String {
        get {
            variable.name
        }
        set {
            variable.name = newValue
        }
    }
    
    var type: VhdlType {
        get {
            variable.type
        }
        set {
            variable.type = newValue
        }
    }
    
    var initial: String {
        get {
            variable.initial
        }
        set {
            variable.initial = newValue
        }
    }
    
    init(signalType: String, name: String, type: VhdlType, initial: String) {
        self.mode = "out"
        self.variable = Variable(signalType: signalType, name: name, type: type, initial: initial)
    }
}
