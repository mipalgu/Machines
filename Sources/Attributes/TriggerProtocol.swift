//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public protocol TriggerProtocol {
    
    associatedtype Root
    
    func performTrigger(_ root: inout Root) -> Result<Bool, AttributeError<Root>>
    
}

public protocol PartialTriggerProtocol {
    
    associatedtype Trigger: TriggerProtocol
    
    associatedtype SourcePath: PathProtocol
    
    func make(source: SourcePath) -> Trigger
    
}

struct MakeAvailablePartialTrigger<TargetPath: PathProtocol, SourcePath: PathProtocol>: PartialTriggerProtocol where SourcePath.Root == TargetPath.Root, SourcePath.Value == Bool, TargetPath.Value == Bool {
    
    let targetPath: TargetPath
    
    func make(source: SourcePath) -> AnyTrigger<SourcePath.Root>  {
        AnyTrigger(MakeAvailableTrigger<SourcePath, TargetPath>(source: source, target: targetPath))
    }
    
}

struct MakeAvailableTrigger<SourcePath: PathProtocol, TargetPath: PathProtocol>: TriggerProtocol where SourcePath.Root == TargetPath.Root, SourcePath.Value == Bool, TargetPath.Value == Bool {
    
    typealias Root = SourcePath.Root
    
    let source: SourcePath
    
    let target: TargetPath
    
    func performTrigger(_ root: inout Root) -> Result<Bool, AttributeError<Root>> {
        root[keyPath: target.path] = root[keyPath: source.keyPath]
        return .success(true)
    }
    
}
