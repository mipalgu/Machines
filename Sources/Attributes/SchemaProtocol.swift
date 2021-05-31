//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol SchemaProtocol {
    
    associatedtype Root: Modifiable
    
    var groups: [AnyGroup<Root>] { get }
    
    func findProperty<Path: PathProtocol>(path: Path) -> SchemaAttribute<Root> where Path.Root == Root, Path.Value == Attribute
    
}

public extension SchemaProtocol {
    
    var groups: [AnyGroup<Root>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = $0.value as? Group<Root> {
                return val.wrappedValue
            }
            return nil
        }
    }
    
    func findProperty<Path: PathProtocol>(path: Path) -> SchemaAttribute<Root> where Path.Root == Root, Path.Value == Attribute {
        guard let property = groups.compactMap({ $0.findProperty(path: path) }).first else {
            fatalError()
        }
        switch property {
        case .property(let attribute):
            return attribute
        }
    }
    
}

//struct VHDLSettings: GroupProtocol {
//
//    var path: Path<EmptyModifiable, AttributeGroup>
//
//    typealias Root = EmptyModifiable
//
//    @GroupBoolProperty(label: "is_suspensible", trigger: .makeAvailable(\.suspendedState))
//    var isSuspensible
//    
//    @GroupProperty(label: "suspended_state", available: false, type: .line)
//    var suspendedState
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
