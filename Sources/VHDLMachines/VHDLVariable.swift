//
//  File.swift
//  
//
//  Created by Morgan McColl on 14/4/21.
//

import Foundation

public struct VHDLVariable: Variable {
    
    public var type: String
    
    public var name: String
    
    public var defaultValue: String?
    
    public var range: (Int, Int)?
    
    public var comment: String?
    
    public init(type: String, name: String, defaultValue: String?, range: (Int, Int)?, comment: String?) {
        self.type = type
        self.name = name
        self.defaultValue = defaultValue
        self.range = range
        self.comment = comment
    }
    
}

extension VHDLVariable: Codable {
    
    enum CodingKeys: CodingKey {
        case type, name, defaultValue, range, comment
    }
    
    public init(from: Decoder) throws {
        let container = try from.container(keyedBy: CodingKeys.self)
        type = try container.decode(String.self, forKey: .type)
        name = try container.decode(String.self, forKey: .name)
        defaultValue = try container.decode(String?.self, forKey: .defaultValue)
        comment = try container.decode(String?.self, forKey: .comment)
        guard let rangeRaw = try container.decode(String?.self, forKey: .range) else {
            range = nil
            return
        }
        let components = rangeRaw.split(separator: ",")
        guard
            components.count == 2,
            let minRange = Int(components[0]),
            let maxRange = Int(components[1])
        else {
            range = nil
            return
        }
        range = (minRange, maxRange)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(name, forKey: .name)
        try container.encode(defaultValue, forKey: .defaultValue)
        try container.encode(comment, forKey: .comment)
        guard let range = range else {
            try container.encode(Optional<String>(nil), forKey: .range)
            return
        }
        try container.encode(Optional<String>("\(range.0),\(range.1)"), forKey: .range)
    }
    
}
