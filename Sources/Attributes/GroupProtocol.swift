//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

protocol GroupProtocol {
    
    associatedtype Root: Modifiable
    
    var path: Path<Root, AttributeGroup> { get }
    
    var properties: [SchemaProperty<Root>] { get }
    
}

extension GroupProtocol {
    
    var properties: [SchemaProperty<Root>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = $0.value as? Property<Root> {
                return .property(val.wrappedValue)
            }
            return nil
        }
    }
    
}
