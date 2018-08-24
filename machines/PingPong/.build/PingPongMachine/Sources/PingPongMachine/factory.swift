import FSM
import swiftfsm

public func make_PingPong() -> (AnyScheduleableFiniteStateMachine, [Dependency]) {
    let (fsm, dependencies) = make_submachine_PingPong()
    return (fsm.asScheduleableFiniteStateMachine, dependencies)
}

public func make_submachine_PingPong() -> (AnyControllableFiniteStateMachine, [Dependency]) {
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
    return (MachineFSM(
        "PingPong",
        initialState: Ping,
        externalVariables: [],
        fsmVars: fsmVars,
        ringlet: ringlet,
        initialPreviousState: EmptySleepingState("_Previous"),
        suspendedState: nil,
        suspendState: EmptySleepingState("_Suspend"),
        exitState: EmptySleepingState("_Exit")
    ), [])
}

