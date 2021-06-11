//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public enum SchemaProperty<Root> {
    
    case property(SchemaAttribute<Root>)
    
    case complex(SchemaAttribute<Root>, [SchemaAttribute<Root>])
    
    func toNewRoot<Path: PathProtocol>(path: Path) -> SchemaProperty<Path.Root> where Path.Value == Root {
        switch self {
        case .property(let attribute):
            return .property(attribute.toNewRoot(path: path))
        case .complex(let complexAttribute, let attributes):
            return .complex(complexAttribute.toNewRoot(path: path), attributes.map {
                $0.toNewRoot(path: path)
            })
        }
    }
    
}
