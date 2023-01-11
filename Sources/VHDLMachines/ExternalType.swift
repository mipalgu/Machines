//
//  File.swift
//  
//
//  Created by Morgan McColl on 20/5/21.
//

import Foundation

/// An external type is a type that exists outside of the scope of a VHDL entity.
public protocol ExternalType {

    /// The mode of the external type.
    var mode: Mode {get set}

}
