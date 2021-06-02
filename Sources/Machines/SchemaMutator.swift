//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

import Attributes

struct SchemaMutator<Schema: SchemaProtocol>: MachineMutator where Schema.Root == Machine {

    var schema: Schema
    
    func modify<Path>(attribute: Path, value: Path.Value, machine: inout Machine) -> Result<Bool, AttributeError<Path.Root>> where Path : PathProtocol, Path.Root == Machine {
        let trigger: AnyTrigger<Machine>
        if attribute.ancestors.contains(AnyPath(Machine.path.attributes)) {
            let property = schema.findProperty(path: attribute)
            trigger = property.trigger
        } else {
            trigger = schema.trigger
        }
        machine[keyPath: attribute.path] = value
        return trigger.performTrigger(&machine)
    }
    
    func newState(machine: inout Machine) -> Result<Bool, AttributeError<Machine>> {
        
    }
    
    func validate(machine: Machine) throws {
        try schema.validator.performValidation(machine)
    }

}
