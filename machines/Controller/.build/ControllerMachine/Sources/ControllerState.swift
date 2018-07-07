import FSM
import ControllerMachineBridging
import CGUSimpleWhiteboard
import GUSimpleWhiteboard
import PingPongMachine

public class ControllerState: MiPalState {

    public let _wbcount: SnapshotCollectionController<GenericWhiteboard<wb_count>>
    private let _fsmVars: SimpleVariablesContainer<ControllerVars>

    public private(set) var PingPongMachine: AnyScheduleableFiniteStateMachine

    var count: UInt8 = 0

    public private(set) var fsmVars: ControllerVars {
        get {
            return self._fsmVars.vars
        } set {
            self._fsmVars.vars = newValue
        }
    }

    public private(set) var wbcount: wb_count {
        get {
            return _wbcount.val
        } set {
            _wbcount.val = newValue
        }
    }

    public init(
        _ name: String,
        transitions: [Transition<ControllerState, MiPalState>] = [],
        wbcount: SnapshotCollectionController<GenericWhiteboard<wb_count>>,
        fsmVars: SimpleVariablesContainer<ControllerVars>,
        PingPongMachine: AnyScheduleableFiniteStateMachine
    ) {
        self._wbcount = wbcount
        self._fsmVars = fsmVars
        self.PingPongMachine = PingPongMachine
        super.init(name, transitions: cast(transitions: transitions))
    }

    public override func onEntry() {
        PingPongMachine.restart()
        count = 0
    }

    public override func main() {
        count += 1
    }

    public override func onExit() {
        PingPongMachine.exit()
    }

    public override final func clone() -> ControllerState {
        let state = ControllerState(
            "Controller",
            transitions: cast(transitions: self.transitions),
            wbcount: self._wbcount,
            fsmVars: self._fsmVars,
            PingPongMachine: self.PingPongMachine
        )
        state.count = self.count
        return state
    }

}
