import FSM
import CGUSimpleWhiteboard
import GUSimpleWhiteboard
import PingPongMachine

public func make_Controller() -> [AnyScheduleableFiniteStateMachine] {
    // External Variables.
    let wbcount = SnapshotCollectionController<GenericWhiteboard<wb_count>>(
        collection: GenericWhiteboard<wb_count>(
            msgType: kCount_v,
            wb: Whiteboard(wbd: gsw_new_whiteboard("privateWhiteboard")),
            atomic: true,
            shouldNotifySubscribers: true
        )
    )
    // Submachines.
    var submachines: [AnyScheduleableFiniteStateMachine] = []
    let PingPongFSMs = make_PingPong()
    let PingPongMachine = PingPongFSMs.first!
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
    let fsm = FSM(
        "Controller",
        initialState: Controller,
        externalVariables: [AnySnapshotController(wbcount)],
        fsmVars: fsmVars,
        suspendState: EmptyMiPalState("_Suspend")
    )
    submachines.insert(fsm, at: 0)
    return submachines
}

