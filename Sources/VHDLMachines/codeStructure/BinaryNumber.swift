//
//  File.swift
//  
//
//  Created by Morgan McColl on 13/6/21.
//

import Foundation

struct BinaryNumber {
    
    var description: String
    
    var signed: Int {
        guard description.count > 0 else {
            return 0
        }
        var total = 0
        let firstBit = description[String.Index(utf16Offset: 0, in: description)]
        description.dropFirst().reversed().enumerated().forEach { (index: Int, value: Character) in
            let bit = Int(String(value)) ?? 0
            total += bit * Int(pow(2.0, Double(index)))
        }
        if firstBit == "1" {
            return -total
        }
        return total
    }
    
    var unsigned: UInt {
        var total: UInt = 0
        description.reversed().enumerated().forEach { (index: Int, value: Character) in
            let bit = UInt(String(value)) ?? 0
            total += bit * UInt(pow(2.0, Double(index)))
        }
        return total
    }
    
}
