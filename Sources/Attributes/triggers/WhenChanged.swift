//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

public struct WhenChanged<Path: PathProtocol, Trigger: TriggerProtocol>: TriggerProtocol where Path.Root == Trigger.Root {

    public typealias Root = Path.Root
    
    private let actualPath: Path
    
    private let trigger: Trigger
    
    public var path: AnyPath<Root> {
        AnyPath(actualPath)
    }
    
    private init(actualPath: Path, trigger: Trigger) {
        self.actualPath = actualPath
        self.trigger = trigger
    }
    
    public func performTrigger(_ root: inout Path.Root, for path: AnyPath<Root>) -> Result<Bool, AttributeError<Path.Root>> {
        if isTriggerForPath(path) {
            return trigger.performTrigger(&root, for: path)
        }
        return .success(false)
    }
    
    public func isTriggerForPath(_ path: AnyPath<Path.Root>) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }
    
}

extension WhenChanged where Trigger == IdentityTrigger<Path.Root> {
    
    public init(_ path: Path) {
        self.init(actualPath: path, trigger: IdentityTrigger())
    }
    
    public func when(_ condition: @escaping (Root) -> Bool, @TriggerBuilder<Root> then builder: (WhenChanged<Path, Trigger>) -> [AnyTrigger<Root>]) -> WhenChanged<Path, ConditionalTrigger<AnyTrigger<Path.Root>>> {
        WhenChanged<Path, ConditionalTrigger<AnyTrigger<Path.Root>>>(
            actualPath: actualPath,
            trigger: ConditionalTrigger(condition: condition, trigger: AnyTrigger(builder(self)))
        )
    }
    
    public func sync<TargetPath: PathProtocol>(target: TargetPath) -> SyncTrigger<Path, TargetPath> where TargetPath.Root == Root, TargetPath.Value == Path.Value {
        SyncTrigger(source: actualPath, target: target)
    }
    
}
