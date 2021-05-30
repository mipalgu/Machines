//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

protocol SchemaProtocol {
    
    associatedtype Root: Modifiable
    
    var groups: [AnyGroup<Root>] { get }
    
}

extension SchemaProtocol {
    
    var groups: [AnyGroup<Root>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = $0.value as? Group<Root> {
                return val.wrappedValue
            }
            return nil
        }
    }
    
}
//
//struct VHDLSettings: GroupProtocol {
//
//    var path: Path<EmptyModifiable, AttributeGroup>
//
//    typealias Root = EmptyModifiable
//
//    @Property<Root>(available: true, trigger: { path.trigger { $0.when({ _ in true }, then: { IdentityTrigger(path: EmptyModifiable.path) }) } }, type: .line)
//    var initialState
//
//}
//
//struct TestSchema: SchemaProtocol {
//
//    typealias Root = EmptyModifiable
//
//    @Group(VHDLSettings(path: EmptyModifiable.path.attributes[0]))
//    var settings
//
//}
