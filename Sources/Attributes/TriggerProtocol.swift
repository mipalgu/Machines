//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol TriggerProtocol {
    
    associatedtype Root
    
    func performTrigger(_ root: inout Root, for path: AnyPath<Root>) -> Result<Bool, AttributeError<Root>>
    
    func isTriggerForPath(_ path: AnyPath<Root>) -> Bool
    
}
