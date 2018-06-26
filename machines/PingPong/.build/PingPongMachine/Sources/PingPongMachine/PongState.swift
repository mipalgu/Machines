import FSM

public class PongState: SleepingState {

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
        transitions: [Transition<PongState, SleepingState>] = [],
        fsmVars: SimpleVariablesContainer<PingPongVars>
    ) {
        self._fsmVars = fsmVars
        super.init(name, transitions: cast(transitions: transitions))
    }

    public override func onEntry() {
        print("Pong")
    }

    public override final func clone() -> PongState {
        let state = PongState(
            "Pong",
            transitions: cast(transitions: self.transitions),
            fsmVars: self._fsmVars
        )
        return state
    }

}
