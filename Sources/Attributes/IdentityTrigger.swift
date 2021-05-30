//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

public struct IdentityTrigger<Path: PathProtocol>: TriggerProtocol {
    
    public typealias Root = Path.Root
    
    let path: Path
    
    public init(path: Path) {
        self.path = path
    }
    
    public func performTrigger(_ root: inout Path.Root) -> Result<Bool, AttributeError<Path.Root>> {
        .success(false)
    }
    
}
