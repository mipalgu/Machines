//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

protocol SchemaProtocol {
    
    associatedtype Root: Modifiable
    
    var groups: [AnyGroup<Root>] { get }
    
}

extension SchemaProtocol {
    
    var groups: [AnyGroup<Root>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = $0.value as? Group<Root> {
                return val.wrappedValue
            }
            return nil
        }
    }
    
}
