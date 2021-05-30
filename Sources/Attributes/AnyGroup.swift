//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

struct AnyGroup<Root: Modifiable, Schema: SchemaProtocol>: GroupProtocol {
    
    private let _path: () -> Path<Root, AttributeGroup>
    
    private let _properties: () -> [Property<Root, Schema>]
    
    private let _validate: () -> AnyValidator<Root>
    
    let base: Any
    
    var path: Path<Root, AttributeGroup> {
        _path()
    }
    
    var properties: [Property<Root, Schema>] {
        _properties()
    }
    
    var validate: AnyValidator<Root> {
        _validate()
    }
    
    init<Base: GroupProtocol>(_ base: Base) where Base.Root == Root, Base.Schema == Schema {
        self._path = { base.path }
        self._properties = { base.properties }
        self._validate = { base.validate }
        self.base = base
    }
    
}
