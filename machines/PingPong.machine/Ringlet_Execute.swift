// Call onEntry if we have just transitioned into this state.
if (self.shouldExecuteOnEntry) {
    state.onEntry()
}
// Can we transition to another state?
if let target = checkTransitions(forState: state) {
    // Yes - Return the next state to execute.
    self.shouldExecuteOnEntry = true
    return target
}
self.shouldExecuteOnEntry = false
return state
