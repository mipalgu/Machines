import FSM
import KripkeStructure

public final class PingPongVars: Variables, Updateable {

    public final func clone() -> PingPongVars {
        let vars = PingPongVars()
        return vars
    }

    public final func update(fromDictionary dictionary: [String: Any]) {
    }

}
