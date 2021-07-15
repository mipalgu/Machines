//
// UltrasonicDiscrete.h
//
// Automatically created through MiPalCASE -- do not change manually!
//
#ifndef clfsm_machine_UltrasonicDiscrete_
#define clfsm_machine_UltrasonicDiscrete_

#include "CLMachine.h"

namespace FSM
{
    class CLState;

    namespace CLM
    {
        class UltrasonicDiscrete: public CLMachine
        {
            CLState *_states[10];
        public:
            UltrasonicDiscrete(int mid  = 0, const char *name = "UltrasonicDiscrete");
            virtual ~UltrasonicDiscrete();
            virtual CLState * const * states() const { return _states; }
            virtual int numberOfStates() const { return 10; }
#           include "UltrasonicDiscrete_Variables.h"
#           include "UltrasonicDiscrete_Methods.h"
        };
    }
}

extern "C"
{
    FSM::CLM::UltrasonicDiscrete *CLM_Create_UltrasonicDiscrete(int mid, const char *name);
}

#endif // defined(clfsm_machine_UltrasonicDiscrete_)
