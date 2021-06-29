//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

@propertyWrapper
public struct Group<Root: Modifiable> {
    
    public var projectedValue: Group<Root> { self }
    
    public var wrappedValue: AnyGroup<Root>
    
    public init<GroupType: GroupProtocol>(wrappedValue group: GroupType) where GroupType.Root == Root {
        self.wrappedValue = AnyGroup(group)
    }
    
}
