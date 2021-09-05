//
//  File.swift
//  
//
//  Created by Morgan McColl on 21/3/21.
//

import Foundation
import IO

public struct CXXGenerator {
    
    var helpers: FileHelpers
    
    public init(helpers: FileHelpers = FileHelpers()) {
        self.helpers = helpers
    }
    
    public func generate(machine: Machine) -> Bool {
        guard
            helpers.deleteItem(atPath: machine.path),
            helpers.createDirectory(atPath: machine.path),
            createIncludePaths(root: machine.path, paths: machine.includePaths),
            createStatesFiles(root: machine.path, machineName: machine.name, states: machine.states, allTransitions: machine.transitions, actions: machine.actionDisplayOrder),
            createMachineFiles(root: machine.path, machine: machine),
            createTransitionFiles(root: machine.path, transitions: machine.transitions)
        else {
            return false
        }
        return true
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
    
    func createIncludePaths(root: URL, paths: [String]) -> Bool {
        let contents = paths.joined(separator: "\n")
        let success = self.helpers.createFile("IncludePath", inDirectory: root, withContents: contents)
        return success != nil
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
    
    func createStateHFile(root: URL, machineName: String, state: String, actions: [String], transitions: [Transition], states: [State]) -> URL? {
        return self.helpers.createFile("State_\(state).h", inDirectory: root, withContents: stateHFile(machineName: machineName, state: state, actions: actions, transitions: transitions, states: states, numberOfTransitions: transitions.count))
    }
    
    func actionPerform(machineName: String, state: String, action: String) -> String {
        """
         void \(state)::\(action)::perform(CLMachine *_machine, CLState *_state) const
         {
         #include "\(machineName)_VarRefs.mm"
         #include "State_\(state)_VarRefs.mm"
         #include "\(machineName)_FuncRefs.mm"
         #include "State_\(state)_FuncRefs.mm"
         #include "State_\(state)_\(action).mm"
         }
         """
    }
    
    func transitionCheck(machineName: String, state: String, transition: Transition) -> String {
        """
         bool \(state)::Transition_\(transition.priority)::check(CLMachine *_machine, CLState *_state) const
         {
         #include "\(machineName)_VarRefs.mm"
         #include "State_\(state)_VarRefs.mm"
         #include "\(machineName)_FuncRefs.mm"
         #include "State_\(state)_FuncRefs.mm"
          
             return
             (
         #include "State_\(state)_Transition_\(transition.priority).expr"
             );
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
            return "\(actions.map{ "delete &\($0.prefix(1).lowercased() + $0.dropFirst())Action();" }.joined(separator: "\n    "))"
        }
        if actions.count == 5 {
            return "\(actions[0...2].map{ "delete &\($0.prefix(1).lowercased() + $0.dropFirst())Action();" }.joined(separator: "\n    "))\n    \(actions[3...4].map{ "delete \($0.prefix(1).lowercased() + $0.dropFirst())Action();" }.joined(separator: "\n    "))"
        }
        return "delete &onEntryAction();\n    delete &onExitAction();\n    delete &internalAction();"
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
             \(transitions.map { "_transitions[\($0.priority)] = new Transition_\($0.priority)();" }.joined(separator: "\n    "))
         }
         
         \(state)::~\(state)()
         {
             \(actionDestructor(actions: actions))
             \(transitions.map { "delete _transitions[\($0.priority)];" }.joined(separator: "\n    "))
         }
         
         \(actions.map { actionPerform(machineName: machineName, state: state, action: $0) }.joined(separator: "\n\n"))
         
         \(transitions.map { transitionCheck(machineName: machineName, state: state, transition: $0) }.joined(separator: "\n\n"))
         
         """
    }
    
    func createStateMMFile(root: URL, machineName: String, state: String, transitions: [Transition], actions: [String]) -> URL? {
        let content = stateMMString(machineName: machineName, state: state, transitions: transitions, actions: actions)
        return self.helpers.createFile("State_\(state).mm", inDirectory: root, withContents: content)
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
    
    func createStateFiles(root: URL, machineName: String, state: State, transitions: [Transition], states: [State], actions: [String]) -> Bool {
        guard
            let _ = createStateHFile(root: root, machineName: machineName, state: state.name, actions: actions, transitions: transitions, states: states),
            let _ = createStateMMFile(root: root, machineName: machineName, state: state.name, transitions: transitions, actions: actions),
            let _ = self.helpers.createFile("State_\(state.name)_VarRefs.mm", inDirectory: root, withContents: stateVarRef(state: state.name)),
            let _ = self.helpers.createFile("State_\(state.name)_FuncRefs.mm", inDirectory: root, withContents: ""),
            let _ = self.helpers.createFile("State_\(state.name)_Includes.h", inDirectory: root, withContents: ""),
            let _ = self.helpers.createFile("State_\(state.name)_Methods.h", inDirectory: root, withContents: ""),
            let _ = self.helpers.createFile("State_\(state.name)_Variables.h", inDirectory: root, withContents: ""),
            transitions.compactMap({ self.helpers.createFile("State_\(state.name)_Transition_\($0.priority).expr", inDirectory: root, withContents: "\($0.condition)\n") }).count == transitions.count,
            state.actions.compactMap({ self.helpers.createFile("State_\(state.name)_\($0.0).mm", inDirectory: root, withContents: $0.1)  }).count == actions.count
//            for transition in transitions {
//                transition.condition.write(toFile: root.appendingPathComponent("State_\(state.name)_Transition_\(transition.priority).expr").absoluteString, atomically: true, encoding: .utf8)
//            }
//            for (action, code) in state.actions {
//                code.write(toFile: root.appendingPathComponent("State_\(state.name)_\(action).mm").absoluteString, atomically: true, encoding: .utf8)
//            }
        else {
            return false
        }
        return true
    }
    
    func createStatesFiles(root: URL, machineName: String, states: [State], allTransitions: [Transition], actions: [String]) -> Bool {
        for state in states {
            let transitions = allTransitions.filter { $0.source == state.name }
            if !createStateFiles(root: root, machineName: machineName, state: state, transitions: transitions, states: states, actions: actions) {
                return false
            }
        }
        let stateNames =  states.map { $0.name }.joined(separator: "\n")
        let success = self.helpers.createFile("States", inDirectory: root, withContents: stateNames)
        return success != nil
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
    
    func createMachineFiles(root: URL, machine: Machine) -> Bool {
        guard
            let _ = self.helpers.createFile("\(machine.name).h", inDirectory: root, withContents: machineHFile(machineName: machine.name, numberOfStates: machine.states.count)),
            let _ = self.helpers.createFile("\(machine.name).mm", inDirectory: root, withContents: machineMMFile(
                machineName: machine.name,
                states: machine.states,
                initialState: machine.initialState,
                suspendState: machine.suspendedState
            )),
            let _ = self.helpers.createFile("\(machine.name)_FuncRefs.mm", inDirectory: root, withContents: machine.funcRefs),
            let _ = self.helpers.createFile("\(machine.name)_Includes.h", inDirectory: root, withContents: machine.includes),
            let _ = self.helpers.createFile("\(machine.name)_Methods.h", inDirectory: root, withContents: ""),
            let _ = self.helpers.createFile("\(machine.name)_VarRefs.mm", inDirectory: root, withContents: machineVarRefs(machineName: machine.name, variables: machine.machineVariables)),
            let _ = self.helpers.createFile("\(machine.name)_Variables.h", inDirectory: root, withContents: machineVariables(machineName: machine.name, variables: machine.machineVariables))
        else {
            return false
        }
        return true
    }
    
    func createTransitionFiles(root: URL, transitions: [Transition]) -> Bool {
        let success: [Bool] = transitions.map {
            guard let _ = self.helpers.createFile("State_\($0.source)_Transition_\($0.priority).expr", inDirectory: root, withContents: $0.condition) else {
                return false
            }
            return true
        }
        return success.reduce(true) { $0 && $1 }
    }
    
}