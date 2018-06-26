import FSM

public class PingState: SleepingState {

    private let _fsmVars: SimpleVariablesContainer<PingPongVars>

    public private(set) var fsmVars: PingPongVars {
        get {
            return self._fsmVars.vars
        } set {
            self._fsmVars.vars = newValue
        }
    }

    public init(
        _ name: String,
        transitions: [Transition<PingState, SleepingState>] = [],
        fsmVars: SimpleVariablesContainer<PingPongVars>
    ) {
        self._fsmVars = fsmVars
        super.init(name, transitions: cast(transitions: transitions))
    }

    public override func onEntry() {
        print("Ping")
    }

    public override final func clone() -> PingState {
        let state = PingState(
            "Ping",
            transitions: cast(transitions: self.transitions),
            fsmVars: self._fsmVars
        )
        return state
    }

}
