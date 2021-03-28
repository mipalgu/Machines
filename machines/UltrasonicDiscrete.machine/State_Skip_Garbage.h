//
// State_Skip_Garbage.h
//
// Automatically created through MiPalCASE -- do not change manually!
//
#ifndef clfsm_UltrasonicDiscrete_State_Skip_Garbage_h
#define clfsm_UltrasonicDiscrete_State_Skip_Garbage_h

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
            class Skip_Garbage: public CLState
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
                    Transition_0(int toState = 6): CLTransition(toState) {}

                    virtual bool check(CLMachine *, CLState *) const;
                };

                CLTransition *_transitions[1];

                public:
                    Skip_Garbage(const char *name = "Skip_Garbage");
                    virtual ~Skip_Garbage();

                    virtual CLTransition * const *transitions() const { return _transitions; }
                    virtual int numberOfTransitions() const { return 1; }

#                   include "State_Skip_Garbage_Variables.h"
#                   include "State_Skip_Garbage_Methods.h"
            };
        }
      }
    }
}

#endif
