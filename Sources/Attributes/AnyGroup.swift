//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct AnyGroup<Root: Modifiable>: GroupProtocol {
    
    private let _path: () -> Path<Root, AttributeGroup>
    
    private let _properties: () -> [SchemaProperty]
    
    let base: Any
    
    public var path: Path<Root, AttributeGroup> {
        _path()
    }
    
    public var properties: [SchemaProperty] {
        _properties()
    }
    
    public init<Base: GroupProtocol>(_ base: Base) where Base.Root == Root {
        self._path = { base.path }
        self._properties = { base.properties }
        self.base = base
    }
    
}
