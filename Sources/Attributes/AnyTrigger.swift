//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct AnyTrigger<Root>: TriggerProtocol {
    
    private let _isTriggerForPath: (AnyPath<Root>, Root) -> Bool
    
    private let _trigger: (inout Root, AnyPath<Root>) -> Result<Bool, AttributeError<Root>>
    
    public init<Base: TriggerProtocol>(_ base: Base) where Base.Root == Root {
        self._isTriggerForPath = { base.isTriggerForPath($0, in: $1) }
        self._trigger = { base.performTrigger(&$0, for: $1) }
    }
    
    public init<SearchPath: SearchablePath>(path: SearchPath, trigger: @escaping (inout Root, AnyPath<Root>) -> Result<Bool, AttributeError<Root>>) where SearchPath.Root == Root {
        self._isTriggerForPath = { path.isAncestorOrSame(of: $0, in: $1) }
        self._trigger = trigger
    }
    
    public init(_ trigger: AnyTrigger<Root>) {
        self = trigger
    }
    
    public init(@TriggerBuilder<Root> builder: () -> [AnyTrigger<Root>]) {
        self.init(builder())
    }
    
    public init<S: Sequence, V: TriggerProtocol>(_ triggers: S) where S.Element == V, V.Root == Root {
        self._isTriggerForPath = { (path, root) in
            triggers.first { $0.isTriggerForPath(path, in: root) } != nil
        }
        self._trigger = { (root, path) in triggers.reduce(.success(false)) {
            let result = $1.performTrigger(&root, for: path)
            switch ($0, result) {
            case (.success(let leftValue), .success(let rightValue)):
                return .success(leftValue || rightValue)
            case (.failure, _):
                return $0
            case (_, .failure):
                return result
            }
        } }
    }
    
    public func isTriggerForPath(_ path: AnyPath<Root>, in root: Root) -> Bool {
        self._isTriggerForPath(path, root)
    }
    
    public func performTrigger(_ root: inout Root, for path: AnyPath<Root>) -> Result<Bool, AttributeError<Root>> {
        _trigger(&root, path)
    }
    
}

extension AnyTrigger: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = AnyTrigger<Root>
    
    public init(arrayLiteral triggers: ArrayLiteralElement...) {
        self.init(triggers)
    }
    
}
