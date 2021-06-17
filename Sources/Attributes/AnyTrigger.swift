//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct AnyTrigger<Root>: TriggerProtocol {
    
    private let _isTriggerForPath: (AnyPath<Root>) -> Bool
    
    private let _trigger: (inout Root) -> Result<Bool, AttributeError<Root>>
    
    public init<Base: TriggerProtocol>(_ base: Base) where Base.Root == Root {
        self._isTriggerForPath = { base.isTriggerForPath($0) }
        self._trigger = { base.performTrigger(&$0) }
    }
    
    public init(path: AnyPath<Root>, trigger: @escaping (inout Root) -> Result<Bool, AttributeError<Root>>) {
        self._isTriggerForPath = { $0.isChild(of: path) || $0.isSame(as: path) }
        self._trigger = trigger
    }
    
    public init(_ trigger: AnyTrigger<Root>) {
        self = trigger
    }
    
    public init(@TriggerBuilder<Root> builder: () -> [AnyTrigger<Root>]) {
        self.init(builder())
    }
    
    public init<S: Sequence>(_ triggers: S) where S.Element == AnyTrigger<Root> {
        self._isTriggerForPath = { path in
            triggers.first { $0.isTriggerForPath(path) } != nil
        }
        self._trigger = { root in triggers.reduce(.success(false)) {
            let result = $1.performTrigger(&root)
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
    
    public init<S: Sequence, V: TriggerProtocol>(_ triggers: S) where S.Element == V, V.Root == Root {
        self._isTriggerForPath = { path in
            triggers.first { $0.isTriggerForPath(path) } != nil
        }
        self._trigger = { root in triggers.reduce(.success(false)) {
            let result = $1.performTrigger(&root)
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
    
    public func isTriggerForPath(_ path: AnyPath<Root>) -> Bool {
        self._isTriggerForPath(path)
    }
    
    public func performTrigger(_ root: inout Root) -> Result<Bool, AttributeError<Root>> {
        _trigger(&root)
    }
    
}

extension AnyTrigger: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = AnyTrigger<Root>
    
    public init(arrayLiteral triggers: ArrayLiteralElement...) {
        self._isTriggerForPath = { path in
            triggers.first { $0.isTriggerForPath(path) } != nil
        }
        self._trigger = { root in triggers.reduce(.success(false)) {
            let result = $1.performTrigger(&root)
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
    
}
