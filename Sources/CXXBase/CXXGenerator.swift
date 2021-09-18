//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import IO

public struct CXXGenerator {
    
    public init() {}
    
//    var helpers: FileHelpers
//
//    public init(helpers: FileHelpers = FileHelpers()) {
//        self.helpers = helpers
//    }
    
    public func generate(machine: Machine) -> CXXFileWrapper? {
        var files: [String: FileWrapper] = [:]
        guard
            let includePath = createIncludePaths(paths: machine.includePaths),
            let statesFiles = createStatesFiles(
                machineName: machine.name,
                states: machine.states,
                allTransitions: machine.transitions,
                actions: machine.actionDisplayOrder
            ),
            let machineFiles = createMachineFiles(machine: machine),
            let transitionFiles = createTransitionFiles(transitions: machine.transitions)
        else {
            return nil
        }
        files["IncludePath"] = includePath
        files.merge(statesFiles, uniquingKeysWith: { (f1, _) in return f1 })
        files.merge(machineFiles, uniquingKeysWith: { (f1, _) in return f1 })
        files.merge(transitionFiles, uniquingKeysWith: { (f1, _) in return f1 })
        let fileWrapper = CXXFileWrapper(directoryWithFileWrappers: files, machine: machine)
        fileWrapper.filename = "\(machine.name).machine"
        return fileWrapper
    }
    
    func comment(filename: String) -> String {
        """
         //
         // \(filename)
         //
         // This is a generated file - do not change manually.
         //
         """
    }
    
    private func createFileWrapper(named: String, with contents: String) -> FileWrapper? {
        guard
            let data = contents.data(using: .utf8)
        else {
            return nil
        }
        let fileWrapper = FileWrapper(regularFileWithContents: data)
        fileWrapper.preferredFilename = named
        return fileWrapper
    }
    
    func createIncludePaths(paths: [String]) -> FileWrapper? {
        createFileWrapper(named: "IncludePath", with: paths.joined(separator: "\n"))
    }
    
    func actionDefinition(actionName: String) -> String {
        """
                             class \(actionName): public CLAction
                             {
                                 virtual void perform(CLMachine *, CLState *) const;
                             };
         """
    }
    
    func transitionDefinition(priority: UInt, target: Int) -> String {
        """
                             class Transition_\(priority): public CLTransition
                             {
                                 public:
                                     Transition_\(priority)(int toState = \(target)): CLTransition(toState) {}

                                     virtual bool check(CLMachine *, CLState *) const;
                             };
         """
    }
    
    func stateHFile(machineName: String, state: String, actions: [String], transitions: [Transition], states: [State], numberOfTransitions: Int) -> String {
        """
         \(comment(filename: "State_\(state).h"))
         #ifndef clfsm_\(machineName)_State_\(state)_h
         #define clfsm_\(machineName)_State_\(state)_h

         #include "CLState.h"
         #include "CLAction.h"
         #include "CLTransition.h"

         namespace FSM
         {
             namespace CLM
             {
                 namespace FSM\(machineName)
                 {
                     namespace State
                     {
                         class \(state): public CLState
                         {
         \(actions.map(actionDefinition).joined(separator: "\n\n"))
                             
         \(transitions.compactMap { transition in
            guard let targetIndex = states.firstIndex(where: { $0.name == transition.target }) else {
                return nil
            }
            return transitionDefinition(priority: transition.priority, target: targetIndex)
         }.joined(separator: "\n\n"))

                             \(numberOfTransitions == 0 ? "#pragma clang diagnostic ignored \"-Wzero-length-array\"" : "")
                             CLTransition *_transitions[\(numberOfTransitions)];
                             \(numberOfTransitions == 0 ? "#pragma clang diagnostic pop" : "")
          
                             public:
                                 \(state)(const char *name = "\(state)");
                                 virtual ~\(state)();
          
                                 virtual CLTransition * const *transitions() const { return _transitions; }
                                 virtual int numberOfTransitions() const { return \(numberOfTransitions); }
          
         #include "State_\(state)_Variables.h"
         #include "State_\(state)_Methods.h"
                         };
                     }
                 }
             }
         }
          
         #endif
         
         """
    }
    
    func createStateHFile(machineName: String, state: String, actions: [String], transitions: [Transition], states: [State]) -> FileWrapper? {
        let contents = stateHFile(
            machineName: machineName,
            state: state,
            actions: actions,
            transitions: transitions,
            states: states,
            numberOfTransitions: transitions.count
        )
        return createFileWrapper(named: "State_\(state).h", with: contents)
    }
    
    func actionPerform(machineName: String, state: String, action: String) -> String {
        """
         void \(state)::\(action)::perform(CLMachine *_machine, CLState *_state) const
         {
         #\tinclude "\(machineName)_VarRefs.mm"
         #\tinclude "State_\(state)_VarRefs.mm"
         #\tinclude "\(machineName)_FuncRefs.mm"
         #\tinclude "State_\(state)_FuncRefs.mm"
         #\tinclude "State_\(state)_\(action).mm"
         }
         """
    }
    
    func transitionCheck(machineName: String, state: String, transition: Transition) -> String {
        """
         bool \(state)::Transition_\(transition.priority)::check(CLMachine *_machine, CLState *_state) const
         {
         #\tinclude "\(machineName)_VarRefs.mm"
         #\tinclude "State_\(state)_VarRefs.mm"
         #\tinclude "\(machineName)_FuncRefs.mm"
         #\tinclude "State_\(state)_FuncRefs.mm"

         \treturn
         \t(
         #\t\tinclude "State_\(state)_Transition_\(transition.priority).expr"
         \t);
         }
         """
    }
    
    func actionConstructor(actions: [String], state: String) -> String {
        if actions.count == 3 {
            return "\(actions.map { "*new \(state)::\($0)" }.joined(separator: ", "))"
        }
        if actions.count == 5 {
            return "\(actions[0...2].map { "*new \(state)::\($0)" }.joined(separator: ", ")), NULLPTR, \(actions[3...4].map { "new \(state)::\($0)" }.joined(separator: ", "))"
        }
        return "*new \(state)::OnEntry, *new \(state)::OnExit, *new \(state)::Internal"
    }
    
    func actionDestructor(actions: [String]) -> String {
        if actions.count == 3 {
            return "\(actions.map{ "\tdelete &\($0.prefix(1).lowercased() + $0.dropFirst())Action();" }.joined(separator: "\n"))"
        }
        if actions.count == 5 {
            return "\(actions[0...2].map{ "\tdelete &\($0.prefix(1).lowercased() + $0.dropFirst())Action();" }.joined(separator: "\n"))\n\(actions[3...4].map{ "\tdelete \($0.prefix(1).lowercased() + $0.dropFirst())Action();" }.joined(separator: "\n"))"
        }
        return "\tdelete &onEntryAction();\n\tdelete &onExitAction();\n\tdelete &internalAction();"
    }
    
    func stateMMString(machineName: String, state: String, transitions: [Transition], actions: [String]) -> String {
        """
         \(comment(filename: "State_\(state).mm"))
         #include "\(machineName)_Includes.h"
         #include "\(machineName).h"
         #include "State_\(state).h"
         
         #include "State_\(state)_Includes.h"
         
         using namespace FSM;
         using namespace CLM;
         using namespace FSM\(machineName);
         using namespace State;
         
         \(state)::\(state)(const char *name): CLState(name, \(actionConstructor(actions: actions, state: state)))
         {
         \(transitions.map { "\t_transitions[\($0.priority)] = new Transition_\($0.priority)();" }.joined(separator: "\n"))
         }
         
         \(state)::~\(state)()
         {
         \(actionDestructor(actions: actions))

         \(transitions.map { "\tdelete _transitions[\($0.priority)];" }.joined(separator: "\n"))
         }
         
         \(actions.map { actionPerform(machineName: machineName, state: state, action: $0) }.joined(separator: "\n\n"))
         
         \(transitions.map { transitionCheck(machineName: machineName, state: state, transition: $0) }.joined(separator: "\n"))

         """
    }
    
    func createStateMMFile(machineName: String, state: String, transitions: [Transition], actions: [String]) -> FileWrapper? {
        let content = stateMMString(machineName: machineName, state: state, transitions: transitions, actions: actions)
        return createFileWrapper(named: "State_\(state).mm", with: content)
    }
    
    func stateVarRef(state: String) -> String {
        """
         \(comment(filename: "State_\(state)_VarRefs.mm"))
         #pragma clang diagnostic push
         #pragma clang diagnostic ignored "-Wunused-variable"
         #pragma clang diagnostic ignored "-Wshadow"
          
         \(state) *_s = static_cast<\(state) *>(_state);
          
          
         #pragma clang diagnostic pop
         
         """
    }
    
    func createStateFiles(machineName: String, state: State, transitions: [Transition], states: [State], actions: [String]) -> [String: FileWrapper]? {
        var files: [String: FileWrapper] = [:]
        guard
            let hFile = createStateHFile(machineName: machineName, state: state.name, actions: actions, transitions: transitions, states: states),
            let mmFile = createStateMMFile(machineName: machineName, state: state.name, transitions: transitions, actions: actions),
            let varRef = createVarRefs(state: state.name),
            let funcRef = createStateFuncRefs(state: state.name),
            let includes = createIncludes(state: state.name),
            let methods = createStateMethods(state: state.name),
            let variables = createStateVariables(state: state.name),
            let transitionsDictionary = createTransitionsForState(state: state.name, transitions: transitions),
            let actionsDictionary = createActionsForState(state: state.name, actions: state.actions),
            actionsDictionary.keys.count == actions.count
//            for transition in transitions {
//                transition.condition.write(toFile: root.appendingPathComponent("State_\(state.name)_Transition_\(transition.priority).expr").absoluteString, atomically: true, encoding: .utf8)
//            }
//            for (action, code) in state.actions {
//                code.write(toFile: root.appendingPathComponent("State_\(state.name)_\(action).mm").absoluteString, atomically: true, encoding: .utf8)
//            }
        else {
            return nil
        }
        files["State_\(state.name).h"] = hFile
        files["State_\(state.name).mm"] = mmFile
        files["State_\(state.name)_VarRefs.mm"] = varRef
        files["State_\(state.name)_FuncRefs.mm"] = funcRef
        files["State_\(state.name)_Includes.h"] = includes
        files["State_\(state.name)_Methods.h"] = methods
        files["State_\(state.name)_Variables.h"] = variables
        files.merge(transitionsDictionary, uniquingKeysWith: { (f1, _) in return f1 })
        files.merge(actionsDictionary, uniquingKeysWith: { (f1, _) in return f1 })
        return files
    }
    
//    private func createFileWrapper(in directory: URL, called fileName: String, with contents: String) -> FileWrapper? {
//        guard let url = self.helpers.createFile(fileName, inDirectory: directory, withContents: contents) else {
//            return nil
//        }
//        return try? FileWrapper(url: url, options: .immediate)
//    }
    
    private func createActionsForState(state: String, actions: [String: String]) -> [String: FileWrapper]? {
        var files: [String: FileWrapper] = [:]
        var foundNil = false
        actions.forEach {
            let fileName = "State_\(state)_\($0.key).mm"
            guard let actionWrapper = createFileWrapper(named: fileName, with: $0.value) else {
                foundNil = true
                return
            }
            files[fileName] = actionWrapper
        }
        if foundNil {
            return nil
        }
        return files
    }
    
    private func createTransitionsForState(state: String, transitions: [Transition]) -> [String: FileWrapper]? {
        var files: [String: FileWrapper] = [:]
        var foundNil = false
        transitions.forEach {
            let fileName = "State_\(state)_Transition_\($0.priority).expr"
            guard let transitionFile = createFileWrapper(named: fileName, with: "\($0.condition)\n") else {
                foundNil = true
                return
            }
            files[fileName] = transitionFile
        }
        if foundNil {
            return nil
        }
        return files
    }
    
    private func createStateVariables(state: String) -> FileWrapper? {
        createFileWrapper(named: "State_\(state)_Variables.h", with: "")
    }
    
    private func createStateMethods(state: String) -> FileWrapper? {
        createFileWrapper(named: "State_\(state)_Methods.h", with: "")
    }
    
    private func createIncludes(state: String) -> FileWrapper? {
        createFileWrapper(named: "State_\(state)_Includes.h", with: "")
    }
    
    private func createStateFuncRefs(state: String) -> FileWrapper? {
        createFileWrapper(named: "State_\(state)_FuncRefs.mm", with: "")
    }
    
    private func createVarRefs(state: String) -> FileWrapper? {
        createFileWrapper(named: "State_\(state)_VarRefs.mm", with: stateVarRef(state: state))
    }
    
    func createStatesFiles(machineName: String, states: [State], allTransitions: [Transition], actions: [String]) -> [String: FileWrapper]? {
        var files: [String: FileWrapper] = [:]
        for state in states {
            let transitions = allTransitions.filter { $0.source == state.name }
            guard let stateFiles = createStateFiles(machineName: machineName, state: state, transitions: transitions, states: states, actions: actions) else {
                return nil
            }
            files.merge(stateFiles, uniquingKeysWith: { (f1, _) in return f1 })
        }
        let stateNames = states.map { $0.name }.joined(separator: "\n")
        guard let statesWrapper = createFileWrapper(named: "States", with: stateNames) else {
            return nil
        }
        files["States"] = statesWrapper
        return files
    }
    
    func machineHFile(machineName: String, numberOfStates: Int) -> String {
        """
         \(comment(filename: "\(machineName).h"))
         #ifndef clfsm_machine_\(machineName)_
         #define clfsm_machine_\(machineName)_
         
         #include "CLMachine.h"
         
         namespace FSM
         {
             class CLState;
         
             namespace CLM
             {
                 class \(machineName): public CLMachine
                 {
                     CLState *_states[\(numberOfStates)];
                     public:
                         \(machineName)(int mid  = 0, const char *name = "\(machineName)");
                         virtual ~\(machineName)();
                         virtual CLState * const * states() const { return _states; }
                         virtual int numberOfStates() const { return \(numberOfStates); }
         #               include "\(machineName)_Variables.h"
         #               include "\(machineName)_Methods.h"
                 };
             }
         }
         
         extern "C"
         {
             FSM::CLM::\(machineName) *CLM_Create_\(machineName)(int mid, const char *name);
         }
         
         #endif // defined(clfsm_machine_\(machineName)_)
         
         """
    }
    
    func machineMMFile(machineName: String, states: [State], initialState: Int, suspendState: Int?) -> String {
        var suspendCode: String = ""
        if suspendState != nil {
            suspendCode = "setSuspendState(_states[\(suspendState!)]);            // set suspend state"
        }
        return (
        """
         \(comment(filename: "\(machineName).mm"))
         #include "\(machineName)_Includes.h"
         #include "\(machineName).h"
         
         \(states.map { "#include \"State_\($0.name).h\"" }.joined(separator: "\n"))
         
         using namespace FSM;
         using namespace CLM;
         
         extern "C"
         {
             \(machineName) *CLM_Create_\(machineName)(int mid, const char *name)
             {
                 return new \(machineName)(mid, name);
             }
         }
         
         \(machineName)::\(machineName)(int mid, const char *name): CLMachine(mid, name)
         {
             \(states.indices.map { "_states[\($0)] = new FSM\(machineName)::State::\(states[$0].name);" }.joined(separator: "\n    "))
         
             \(suspendCode)
             setInitialState(_states[\(initialState)]);            // set initial state
         }
         
         \(machineName)::~\(machineName)()
         {
             \(states.indices.map { "delete _states[\($0)];" }.joined(separator: "\n    "))
         }
         
         """
        )
    }
    
    func machineVarRefs(machineName: String, variables: [Variable]) -> String {
        """
         \(comment(filename: "\(machineName)_VarRefs.mm"))
         #pragma clang diagnostic push
         #pragma clang diagnostic ignored "-Wunused-variable"
         #pragma clang diagnostic ignored "-Wshadow"
         
         \(machineName) *_m = static_cast<\(machineName) *>(_machine);
         
         \(variables.map { "\($0.type)\t&\($0.name) = _m->\($0.name);\t///< \($0.comment)" }.joined(separator: "\n"))
         
         #pragma clang diagnostic pop
         
         """
    }
    
    func machineVariables(machineName: String, variables: [Variable]) -> String {
        """
         \(comment(filename: "\(machineName)_Variables.h"))
         \(variables.map { "\($0.type)\t\($0.name);\t///< \($0.comment)" }.joined(separator: "\n"))
         
         """
    }
    
    func createMachineFiles(machine: Machine) -> [String: FileWrapper]? {
        var files: [String: FileWrapper] = [:]
        guard
            let machineHFile = createFileWrapper(named: "\(machine.name).h", with: machineHFile(machineName: machine.name, numberOfStates: machine.states.count)),
            let machineMMFile = createFileWrapper(named: "\(machine.name).mm", with: machineMMFile(
                machineName: machine.name,
                states: machine.states,
                initialState: machine.initialState,
                suspendState: machine.suspendedState
            )),
            let machineFuncRefs = createFileWrapper(named: "\(machine.name)_FuncRefs.mm", with: machine.funcRefs),
            let machineIncludes = createFileWrapper(named: "\(machine.name)_Includes.h", with: machine.includes),
            let machineMethods = createFileWrapper(named: "\(machine.name)_Methods.h", with: ""),
            let machineVarRefs = createFileWrapper(named: "\(machine.name)_VarRefs.mm", with: machineVarRefs(machineName: machine.name, variables: machine.machineVariables)),
            let machineVariables = createFileWrapper(named: "\(machine.name)_Variables.h", with: machineVariables(machineName: machine.name, variables: machine.machineVariables))
        else {
            return nil
        }
        files["\(machine.name).h"] = machineHFile
        files["\(machine.name).mm"] = machineMMFile
        files["\(machine.name)_FuncRefs.mm"] = machineFuncRefs
        files["\(machine.name)_Includes.h"] = machineIncludes
        files["\(machine.name)_Methods.h"] = machineMethods
        files["\(machine.name)_VarRefs.mm"] = machineVarRefs
        files["\(machine.name)_Variables.h"] = machineVariables
        return files
    }
    
    func createTransitionFiles(transitions: [Transition]) -> [String: FileWrapper]? {
        var files: [String: FileWrapper] = [:]
        for transition in transitions {
            let fileName = "State_\(transition.source)_Transition_\(transition.priority).expr"
            guard let transitionWrapper = createFileWrapper(named: fileName, with: "\(transition.condition)\n") else {
                return nil
            }
            files[fileName] = transitionWrapper
        }
        return files
    }
    
}
