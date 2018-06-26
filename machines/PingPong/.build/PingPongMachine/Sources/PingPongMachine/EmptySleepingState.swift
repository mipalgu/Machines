import FSM

public final class EmptySleepingState: SleepingState {

    public override final func onEntry() {}

    public override final func clone() -> EmptySleepingState {
        return EmptySleepingState(self.name, transitions: self.transitions)
    }

}
