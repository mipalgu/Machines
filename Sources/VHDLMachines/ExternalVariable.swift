//
//  ExternalVariable.swift
//  VHDLMachines
//
//  Created by Morgan McColl on 3/11/20.
//

public struct ExternalVariable: VHDLExternalVariable {
    
    public var mode: VhdlMode
    
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
    
    init(mode: VhdlMode, name: String, type: VhdlType, initial: String) {
        self.mode = mode
        self.variable = Variable(signalType: "signal", name: name, type: type, initial: initial)
    }
    
}
