import FSM
import CGUSimpleWhiteboard
import GUSimpleWhiteboard
import PingPongMachine

public func make_Controller() -> AnyScheduleableFiniteStateMachine {
    return make_submachine_Controller().asScheduleableFiniteStateMachine
}

public func make_submachine_Controller() -> AnyControllableFiniteStateMachine {
    // External Variables.
    let wbcount = SnapshotCollectionController<GenericWhiteboard<wb_count>>(
        "privateWhiteboard.kCount_v",
        collection: GenericWhiteboard<wb_count>(
            msgType: kCount_v,
            wbd: Whiteboard(wbd: gsw_new_whiteboard("privateWhiteboard")),
            atomic: true,
            shouldNotifySubscribers: true
        )
    )
    // Submachines.
    var submachines: [AnyControllableFiniteStateMachine] = []
    let PingPongMachine = make_submachine_PingPong()
    submachines.append(PingPongMachine)
    // FSM Variables.
    let fsmVars = SimpleVariablesContainer(vars: ControllerVars())
    // States.
    var Controller = ControllerState(
        "Controller",
        wbcount: wbcount,
        fsmVars: fsmVars,
        PingPongMachine: PingPongMachine
    )
    let Exit = ExitState(
        "Exit",
        wbcount: wbcount,
        fsmVars: fsmVars
    )
    // State Transitions.
    Controller.addTransition(Transition(Exit) {
        let state = $0 as! ControllerState
        return state.count >= 100
    })
    // Create FSM.
    return MachineFSM(
        "Controller",
        initialState: Controller,
        externalVariables: [AnySnapshotController(wbcount)],
        fsmVars: fsmVars,
        ringlet: MiPalRinglet(),
        initialPreviousState: EmptyMiPalState("_Previous"),
        suspendedState: nil,
        suspendState: EmptyMiPalState("_Suspend"),
        exitState: EmptyMiPalState("_Exit"),
        submachines: submachines
    )
}

