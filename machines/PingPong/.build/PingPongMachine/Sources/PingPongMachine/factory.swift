import FSM

public func make_PingPong() -> [AnyScheduleableFiniteStateMachine] {
    // FSM Variables.
    let fsmVars = SimpleVariablesContainer(vars: PingPongVars())
    // States.
    var Ping = PingState(
        "Ping",
        fsmVars: fsmVars
    )
    var Pong = PongState(
        "Pong",
        fsmVars: fsmVars
    )
    // State Transitions.
    Ping.addTransition(Transition(Pong) { _ in true })
    Pong.addTransition(Transition(Ping) { _ in true })
    let ringlet = PingPongRinglet()
    // Create FSM.
    return [MachineFSM(
        "PingPong",
        initialState: Ping,
        externalVariables: [],
        fsmVars: fsmVars,
        ringlet: ringlet,
        initialPreviousState: EmptySleepingState("_Previous"),
        suspendedState: nil,
        suspendState: EmptySleepingState("_Suspend"),
        exitState: EmptySleepingState("_Exit")
    ).asScheduleableFiniteStateMachine]
}

