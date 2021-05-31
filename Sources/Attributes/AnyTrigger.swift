//
//  File.swift
//  
//
//  Created by Morgan McColl on 30/5/21.
//

public struct AnyTrigger<Root>: TriggerProtocol {
    
    private let _trigger: (inout Root) -> Result<Bool, AttributeError<Root>>
    
    public init<Base: TriggerProtocol>(_ base: Base) where Base.Root == Root {
        self._trigger = { base.performTrigger(&$0) }
    }
    
    public init(trigger: @escaping (inout Root) -> Result<Bool, AttributeError<Root>>) {
        self._trigger = trigger
    }
    
    public init(_ trigger: AnyTrigger<Root>) {
        self = trigger
    }
    
    public init(@TriggerBuilder<Root> builder: () -> [AnyTrigger<Root>]) {
        self.init(builder())
    }
    
    public init<S: Sequence>(_ triggers: S) where S.Element == AnyTrigger<Root> {
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
    
    public func performTrigger(_ root: inout Root) -> Result<Bool, AttributeError<Root>> {
        _trigger(&root)
    }
    
    public func toNewRoot<NewPath: PathProtocol>(path: NewPath) -> AnyTrigger<NewPath.Root> where NewPath.Value == Root {
        AnyTrigger<NewPath.Root> {
            let result = self.performTrigger(&$0[keyPath: path.path])
            switch result {
            case .failure(let error):
                guard let newPath = AnyPath(path).appending(error.path) else {
                    return .failure(AttributeError<NewPath.Root>(message: error.message, path: Path(path: \.self, ancestors: [])))
                }
                return .failure(AttributeError(message: error.message, path: newPath))
            case .success(let result):
                return .success(result)
            }
        }
    }
    
}

extension AnyTrigger: ExpressibleByArrayLiteral {
    
    public typealias ArrayLiteralElement = AnyTrigger<Root>
    
    
    public init(arrayLiteral triggers: ArrayLiteralElement...) {
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
