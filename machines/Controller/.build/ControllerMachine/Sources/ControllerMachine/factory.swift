import FSM
import CGUSimpleWhiteboard
import GUSimpleWhiteboard
import PingPongMachine

public func make_Controller() -> [AnyScheduleableFiniteStateMachine] {
    let (fsm, submachines) = make_submachine_Controller()
    return [fsm.asScheduleableFiniteStateMachine] + submachines
}

public func make_submachine_Controller() -> (AnyControllableFiniteStateMachine, [AnyScheduleableFiniteStateMachine]) {
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
    var submachines: [AnyScheduleableFiniteStateMachine] = []
    let (PingPongMachine, PingPongFSMs) = make_submachine_PingPong()
    submachines.append(contentsOf: PingPongFSMs)
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
    return (FSM(
        "Controller",
        initialState: Controller,
        externalVariables: [AnySnapshotController(wbcount)],
        fsmVars: fsmVars,
        suspendState: EmptyMiPalState("_Suspend")
    ), submachines)
}

