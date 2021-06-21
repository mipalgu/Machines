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
    
    public func when(_ condition: @escaping (Root) -> Bool, @TriggerBuilder<Root> then builder: (WhenChanged<Path, Trigger>) -> AnyTrigger<Root>) -> WhenChanged<Path, ConditionalTrigger<AnyTrigger<Path.Root>>> {
        WhenChanged<Path, ConditionalTrigger<AnyTrigger<Path.Root>>>(
            actualPath: actualPath,
            trigger: ConditionalTrigger(condition: condition, trigger: AnyTrigger(builder(self)))
        )
    }
    
    public func sync<TargetPath: PathProtocol>(target: TargetPath) -> SyncTrigger<Path, TargetPath> where TargetPath.Root == Root, TargetPath.Value == Path.Value {
        SyncTrigger(source: actualPath, target: target)
    }
    
    public func makeAvailable<FieldsPath: PathProtocol, AttributesPath: PathProtocol>(field: Field, after order: [String], fields: FieldsPath, attributes: AttributesPath) -> MakeAvailableTrigger<Path, FieldsPath, AttributesPath> where FieldsPath.Root == Root, FieldsPath.Value == [Field], AttributesPath.Root == Root, AttributesPath.Value == [String: Attribute] {
        MakeAvailableTrigger(field: field, after: order, source: self.actualPath, fields: fields, attributes: attributes)
    }
    
}

public struct MakeAvailableTrigger<Source: PathProtocol, Fields: PathProtocol, Attributes: PathProtocol>: TriggerProtocol where Source.Root == Fields.Root, Fields.Root == Attributes.Root, Fields.Value == [Field], Attributes.Value == [String: Attribute] {
    
    public typealias Root = Fields.Root
    
    public var path: AnyPath<Root> {
        AnyPath(source)
    }
    
    let field: Field
    
    let order: [String]
    
    let source: Source
    
    let fields: Fields
    
    let attributes: Attributes
    
    public init(field: Field, after order: [String], source: Source, fields: Fields, attributes: Attributes) {
        self.field = field
        self.order = order
        self.source = source
        self.fields = fields
        self.attributes = attributes
    }
    
    public func performTrigger(_ root: inout Source.Root, for _: AnyPath<Root>) -> Result<Bool, AttributeError<Source.Root>> {
        if nil != root[keyPath: fields.keyPath].first(where: { $0.name == field.name }) {
            return .success(false)
        }
        let indices = order.compactMap {
            root[keyPath: fields.path].lazy.map(\.name).firstIndex(of: $0)
        }
        root[keyPath: fields.path].insert(field, at: indices.first ?? 0)
        if nil == root[keyPath: attributes.keyPath][field.name] {
            root[keyPath: attributes.path][field.name] = field.type.defaultValue
        }
        return .success(true)
    }
    
    public func isTriggerForPath(_ path: AnyPath<Root>) -> Bool {
        path.isChild(of: self.path) || path.isSame(as: self.path)
    }
    
}
