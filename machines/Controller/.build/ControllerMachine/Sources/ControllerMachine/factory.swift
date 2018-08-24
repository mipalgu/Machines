import FSM
import swiftfsm
import CGUSimpleWhiteboard
import GUSimpleWhiteboard
import PingPongMachine

public func make_Controller() -> (AnyScheduleableFiniteStateMachine, [Dependency]) {
    let (fsm, dependencies) = make_submachine_Controller()
    return (fsm.asScheduleableFiniteStateMachine, dependencies)
}

public func make_submachine_Controller() -> (AnyControllableFiniteStateMachine, [Dependencies]) {
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
    var submachines: [(AnyScheduleableFiniteStateMachine, [Dependency])] = []
    let (PingPongMachine, PingPongMachineDependencies) = make_submachine_PingPong()
    submachines.append((PingPongMachine.asScheduleableFiniteStateMachine, PingPongMachineDependencies))
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
    return (MachineFSM(
        "Controller",
        initialState: Controller,
        externalVariables: [AnySnapshotController(wbcount)],
        fsmVars: fsmVars,
        ringlet: MiPalRinglet(),
        initialPreviousState: EmptyMiPalState("_Previous"),
        suspendedState: nil,
        suspendState: EmptyMiPalState("_Suspend"),
        exitState: EmptyMiPalState("_Exit")
    ), submachines.map { Dependency.submachine($0, $1) })
}

