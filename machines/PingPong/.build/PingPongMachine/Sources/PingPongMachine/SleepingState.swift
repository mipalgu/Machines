import FSM
import KripkeStructure

public class SleepingState:
    StateType,
    CloneableState,
    CustomStringConvertible,
    CustomDebugStringConvertible,
    Transitionable,
    KripkeVariablesModifier
{

    public let name: String

    public var transitions: [Transition<SleepingState, SleepingState>]

    public var validVars: [String: [Any]] {
        return [:]
    }

    public init(_ name: String, transitions: [Transition<SleepingState, SleepingState>] = []) {
        self.name = name
        self.transitions = transitions
    }

    public func onEntry() {}

    public func clone() -> Self {
        fatalError("Please implement your own clone.")
    }

    public func update(fromDictionary dictionary: [String: Any]) {}

}
