// Call onEntry if we have just transitioned into this state.
if (state != previousState) {
    state.onEntry()
}
previousState = state
// Can we transition to another state?
if let target = checkTransitions(forState: state) {
    // Yes - Return the next state to execute.
    return target
}
return state
