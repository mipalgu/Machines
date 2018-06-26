import FSM
import KripkeStructure

public final class PingPongRinglet: Ringlet, Cloneable, Updateable {

    public typealias _StateType = SleepingState

    var previousState: SleepingState = EmptySleepingState("_previous")

    public init() {}

    public func execute(state: SleepingState) -> SleepingState {
        // Call onEntry if we have just transitioned into this state.
        if (state != previousState) {
            state.onEntry()
        }
        previousState = state
        // Can we transition to another state?
        if let target = checkTransitions(forState: state) {
            // Yes - Return the next state to execute.
            return target
        }
        return state
    }

    private func checkTransitions(forState state: SleepingState) -> SleepingState? {
        return state.transitions.lazy.filter(self.isValid(forState: state)).first?.target
    }

    private func isValid(forState state: SleepingState) -> (Transition<SleepingState, SleepingState>) -> Bool {
        return { $0.canTransition(state) }
    }

    public final func clone() -> PingPongRinglet {
        let ringlet = PingPongRinglet()
        ringlet.previousState = self.previousState
        return ringlet
    }

    public final func update(fromDictionary dictionary: [String: Any]) {
        self.previousState.update(fromDictionary: dictionary["previousState"] as! [String: Any])
    }

}
