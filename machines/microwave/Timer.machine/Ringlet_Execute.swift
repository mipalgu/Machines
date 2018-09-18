if self.shouldExecuteOnEntry {
    state.onEntry()
}
if let target = checkTransitions(forState: state) {
    state.onExit()
    self.shouldExecuteOnEntry = target != state
    return target
}
state.main()
self.shouldExecuteOnEntry = false
return state