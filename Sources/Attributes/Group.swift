//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

@propertyWrapper
struct Group<Root: Modifiable> {
    
    var projectedValue: Group<Root> { self }
    
    var wrappedValue: AnyGroup<Root>
    
    init<GroupType: GroupProtocol>(_ group: GroupType) where GroupType.Root == Root {
        self.wrappedValue = AnyGroup(group)
    }
    
}
