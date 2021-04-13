//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

protocol Signal {
    
    var type: SignalType {get set}
    
    var name: String {get set}
    
    var defaultValue: String? {get set}
}
