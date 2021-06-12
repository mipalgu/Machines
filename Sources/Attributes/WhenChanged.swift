//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

public struct WhenChanged<Path: PathProtocol>: TriggerProtocol {
    
    public typealias Root = Path.Root
    
    let path: Path
    
    public init(_ path: Path) {
        self.path = path
    }
    
    public func when(_ condition: @escaping (Root) -> Bool, @TriggerBuilder<Root> then builder: (WhenChanged<Path>) -> [AnyTrigger<Root>]) -> ConditionalTrigger<AnyTrigger<Path.Root>> {
        ConditionalTrigger(condition: condition, trigger: AnyTrigger(builder(self)))
    }
    
    public func sync<TargetPath: PathProtocol>(target: TargetPath) -> SyncTrigger<Path, TargetPath> where TargetPath.Root == Root, TargetPath.Value == Path.Value {
        SyncTrigger(source: path, target: target)
    }
    
    public func performTrigger(_ root: inout Path.Root) -> Result<Bool, AttributeError<Path.Root>> {
        .success(false)
    }
    
}

public struct ConditionalTrigger<Trigger: TriggerProtocol>: TriggerProtocol {
    
    public typealias Root = Trigger.Root
    
    let condition: (Root) -> Bool
    
    let trigger: Trigger
    
    public init(condition: @escaping (Root) -> Bool, trigger: Trigger) {
        self.condition = condition
        self.trigger = trigger
    }
    
    public func performTrigger(_ root: inout Root) -> Result<Bool, AttributeError<Root>> {
        if condition(root) {
            return trigger.performTrigger(&root)
        }
        return .success(false)
    }
    
}

public struct SyncTrigger<Source: PathProtocol, Target: PathProtocol>: TriggerProtocol where Source.Root == Target.Root, Source.Value == Target.Value {
    
    public typealias Root = Source.Root
    
    let source: Source
    
    let target: Target
    
    public init(source: Source, target: Target) {
        self.source = source
        self.target = target
    }
    
    public func performTrigger(_ root: inout Source.Root) -> Result<Bool, AttributeError<Source.Root>> {
        root[keyPath: target.path] = root[keyPath: source.keyPath]
        return .success(true)
    }
    
}
