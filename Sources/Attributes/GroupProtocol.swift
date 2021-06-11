//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol GroupProtocol: Attributable where AttributeRoot == AttributeGroup {}

public extension GroupProtocol {
    
    var pathToAttributes: KeyPath<AttributeGroup, [String : Attribute]> {
        \.attributes
    }
    
}
