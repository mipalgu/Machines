import FSM
import KripkeStructure

public final class ControllerVars: Variables, Updateable {

    public final func clone() -> ControllerVars {
        let vars = ControllerVars()
        return vars
    }

    public final func update(fromDictionary dictionary: [String: Any]) {
    }

}
