//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol GroupProtocol {
    
    associatedtype Root: Modifiable
    
    var path: Path<Root, AttributeGroup> { get }
    
    var properties: [SchemaProperty<AttributeGroup>] { get }
    
}

extension GroupProtocol {
    
    var properties: [SchemaProperty<AttributeGroup>] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap {
            if let val = $0.value as? GroupProperty {
                return .property(val.wrappedValue)
            }
            return nil
        }
    }
    
    func findProperty<Path: PathProtocol>(path: Path) -> SchemaProperty<Path.Root>? where Path.Root == Root {
        guard let index = path.fullPath.firstIndex(where: { $0.partialKeyPath == self.path.keyPath }) else {
            return nil
        }
        let subpath = path.fullPath[index..<path.fullPath.count]
        if subpath.count > 2 {
            //complex?
            return nil
        }
        if subpath.count == 2 {
            //property of me
            return properties.first {
                switch $0 {
                case .property(let attribute):
                    return self.path.keyPath.appending(path: \AttributeGroup.attributes[attribute.label]) == path.keyPath
                default:
                    return false
                }
            }?.toNewRoot(path: self.path)
        }
        //itsa me
        return nil
    }
    
}
