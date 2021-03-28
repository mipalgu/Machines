//
// State_Wait_For_Pulse_End.h
//
// Automatically created through MiPalCASE -- do not change manually!
//
#ifndef clfsm_UltrasonicDiscrete_State_Wait_For_Pulse_End_h
#define clfsm_UltrasonicDiscrete_State_Wait_For_Pulse_End_h

#include "CLState.h"
#include "CLAction.h"
#include "CLTransition.h"

namespace FSM
{
    namespace CLM
    {
      namespace FSMUltrasonicDiscrete
      {
        namespace State
        {
            class Wait_For_Pulse_End: public CLState
            {
                class OnEntry: public CLAction
                {
                    virtual void perform(CLMachine *, CLState *) const;
                };

                class OnExit: public CLAction
                {
                    virtual void perform(CLMachine *, CLState *) const;
                };

                class Internal: public CLAction
                {
                    virtual void perform(CLMachine *, CLState *) const;
                };

                class Transition_0: public CLTransition
                {
                public:
                    Transition_0(int toState = 4): CLTransition(toState) {}

                    virtual bool check(CLMachine *, CLState *) const;
                };

                class Transition_1: public CLTransition
                {
                public:
                    Transition_1(int toState = 9): CLTransition(toState) {}

                    virtual bool check(CLMachine *, CLState *) const;
                };

                CLTransition *_transitions[2];

                public:
                    Wait_For_Pulse_End(const char *name = "Wait_For_Pulse_End");
                    virtual ~Wait_For_Pulse_End();

                    virtual CLTransition * const *transitions() const { return _transitions; }
                    virtual int numberOfTransitions() const { return 2; }

#                   include "State_Wait_For_Pulse_End_Variables.h"
#                   include "State_Wait_For_Pulse_End_Methods.h"
            };
        }
      }
    }
}

#endif
