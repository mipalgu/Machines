//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

protocol SchemaProtocol {
    
    associatedtype Root: Modifiable
    
    var groups: [AnyGroup<Root, Self>] { get }
    
}
