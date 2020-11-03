//
//  Parameter.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

public struct Parameter: VHDLExternalVariable {
    
    public var mode: String
    
    var variable: Variable

    public var signalType: String {
        get {
            variable.signalType
        }
        set {
            variable.signalType = newValue
        }
    }
    
    public var name: String {
        get {
            variable.name
        }
        set {
            variable.name = newValue
        }
    }
    
    public var type: VhdlType {
        get {
            variable.type
        }
        set {
            variable.type = newValue
        }
    }
    
    public var initial: String {
        get {
            variable.initial
        }
        set {
            variable.initial = newValue
        }
    }
    
    init(signalType: String, name: String, type: VhdlType, initial: String) {
        self.mode = "in"
        self.variable = Variable(signalType: signalType, name: name, type: type, initial: initial)
    }
    
}
