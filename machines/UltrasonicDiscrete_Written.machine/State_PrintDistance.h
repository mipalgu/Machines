//
// State_PrintDistance.h
//
// This is a generated file - do not change manually.
//
#ifndef clfsm_UltrasonicDiscrete_State_PrintDistance_h
#define clfsm_UltrasonicDiscrete_State_PrintDistance_h

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
                class PrintDistance: public CLState
                {
                    class Internal: public CLAction
                    {
                        virtual void perform(CLMachine *, CLState *) const;
                    };

                    class OnExit: public CLAction
                    {
                        virtual void perform(CLMachine *, CLState *) const;
                    };

                    class OnEntry: public CLAction
                    {
                        virtual void perform(CLMachine *, CLState *) const;
                    };
                    
                    class Transition_0: public CLTransition
                    {
                        public:
                            Transition_0(int toState = 2: CLTransition(toState) {}

                            virtual bool check(CLMachine *, CLState *) const;
                    };

                    class Transition_1: public CLTransition
                    {
                        public:
                            Transition_1(int toState = 5: CLTransition(toState) {}

                            virtual bool check(CLMachine *, CLState *) const;
                    };

                    CLTransition *_transitions[2];
 
                    public:
                        PrintDistance(const char *name = "PrintDistance");
                        virtual ~PrintDistance();
 
                        virtual CLTransition * const *transitions() const { return _transitions; }
                        virtual int numberOfTransitions() const { return 2; }
 
#include "State_PrintDistance_Variables.h"
#include "State_PrintDistance_Methods.h"
                };
            }
        }
    }
}
 
#endif
