import FSM
import ControllerMachineBridging
import CGUSimpleWhiteboard
import GUSimpleWhiteboard

public class ExitState: MiPalState {

    public let _wbcount: SnapshotCollectionController<GenericWhiteboard<wb_count>>
    private let _fsmVars: SimpleVariablesContainer<ControllerVars>

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
        transitions: [Transition<ExitState, MiPalState>] = [],
        wbcount: SnapshotCollectionController<GenericWhiteboard<wb_count>>,
        fsmVars: SimpleVariablesContainer<ControllerVars>
    ) {
        self._wbcount = wbcount
        self._fsmVars = fsmVars
        super.init(name, transitions: cast(transitions: transitions))
    }

    public override func onEntry() {
        
    }

    public override func main() {
        
    }

    public override func onExit() {
        
    }

    public override final func clone() -> ExitState {
        let state = ExitState(
            "Exit",
            transitions: cast(transitions: self.transitions),
            wbcount: self._wbcount,
            fsmVars: self._fsmVars
        )
        return state
    }

}
