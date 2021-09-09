//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public protocol Variable {
    
    associatedtype T: StringProtocol
    
    var type: T {get set}
    
    var name: String {get set}
    
    var defaultValue: String? {get set}
    
    var comment: String? {get set}
}
