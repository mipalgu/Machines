//
//  ExternalVariable.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

struct ExternalVariable: VHDLExternalVariable {
    
    var mode: VhdlMode
    
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
    
    init(mode: VhdlMode, name: String, type: VhdlType, initial: String) {
        self.mode = mode
        self.variable = Variable(signalType: "signal", name: name, type: type, initial: initial)
    }
    
}
