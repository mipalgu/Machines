import FSM

public final class CallbackSleepingState: SleepingState {

    private let _onEntry: () -> Void

    public init(
        _ name: String,
        transitions: [Transition<CallbackSleepingState, SleepingState>] = [],
        onEntry: @escaping () -> Void = {}
    ) {
        self._onEntry = onEntry
        super.init(name, transitions: cast(transitions: transitions))
    }

    public final override func onEntry() {
        self._onEntry()
    }

    public override final func clone() -> CallbackSleepingState {
        return CallbackSleepingState(self.name, transitions: cast(transitions: self.transitions))
    }

}
