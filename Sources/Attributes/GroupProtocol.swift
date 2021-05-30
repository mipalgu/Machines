//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

protocol GroupProtocol {
    
    associatedtype Root: Modifiable
    associatedtype Schema: SchemaProtocol
    
    var path: Path<Root, AttributeGroup> { get }
    
    var properties: [Property<Root, Schema>] { get }
    
    var validate: AnyValidator<Root> { get }
    
}
