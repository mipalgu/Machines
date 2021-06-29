//
//  File.swift
//  
//
//  Created by Morgan McColl on 31/5/21.
//

public struct WhenChanged<Path: ReadOnlyPathProtocol, Trigger: TriggerProtocol>: TriggerProtocol where Path.Root == Trigger.Root {

    public typealias Root = Path.Root
    
    private let actualPath: Path
    
    private let trigger: Trigger
    
    public var path: AnyPath<Root> {
        AnyPath(actualPath)
    }
    
    init(actualPath: Path, trigger: Trigger) {
        self.actualPath = actualPath
        self.trigger = trigger
    }
    
    public func performTrigger(_ root: inout Path.Root, for path: AnyPath<Root>) -> Result<Bool, AttributeError<Path.Root>> {
        if isTriggerForPath(path, in: root) {
            return trigger.performTrigger(&root, for: path)
        }
        return .success(false)
    }
    
    public func isTriggerForPath(_ path: AnyPath<Path.Root>, in _: Root) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }
    
}

extension WhenChanged where Trigger == IdentityTrigger<Path.Root> {
    
    public init(_ path: Path) {
        self.init(actualPath: path, trigger: IdentityTrigger())
    }
    
    public func when<NewTrigger: TriggerProtocol>(_ condition: @escaping (Root) -> Bool, @TriggerBuilder<Root> then builder: (WhenChanged<Path, Trigger>) -> NewTrigger) -> WhenChanged<Path, ConditionalTrigger<NewTrigger>> where NewTrigger.Root == Root {
        WhenChanged<Path, ConditionalTrigger<NewTrigger>>(
            actualPath: actualPath,
            trigger: ConditionalTrigger(condition: condition, trigger: builder(self))
        )
    }
    
    public func sync<TargetPath: SearchablePath>(target: TargetPath) -> SyncTrigger<Path, TargetPath> where TargetPath.Root == Root, TargetPath.Value == Path.Value {
        SyncTrigger(source: actualPath, target: target)
    }
    
    public func makeAvailable<FieldsPath: PathProtocol, AttributesPath: PathProtocol>(field: Field, after order: [String], fields: FieldsPath, attributes: AttributesPath) -> MakeAvailableTrigger<Path, FieldsPath, AttributesPath> where FieldsPath.Root == Root, FieldsPath.Value == [Field], AttributesPath.Value == [String: Attribute] {
        MakeAvailableTrigger(field: field, after: order, source: self.actualPath, fields: fields, attributes: attributes)
    }
    
    public func makeUnavailable<FieldsPath: PathProtocol>(field: Field, fields: FieldsPath) -> MakeUnavailableTrigger<Path, FieldsPath> where FieldsPath.Root == Root, FieldsPath.Value == [Field] {
        MakeUnavailableTrigger(field: field, source: actualPath, fields: fields)
    }
    
}
