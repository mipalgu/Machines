//
// State_Wait_For_Pulse_End.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_Wait_For_Pulse_End.h"
#include "State_Wait_For_Pulse_End_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

Wait_For_Pulse_End::Wait_For_Pulse_End(const char *name): CLState(name, *new Wait_For_Pulse_End::Internal, *new Wait_For_Pulse_End::OnExit, *new Wait_For_Pulse_End::OnEntry)
{
    _transitions[0] = new Transition_0();
    _transitions[1] = new Transition_1();
}

Wait_For_Pulse_End::~Wait_For_Pulse_End()
{
    delete &internalAction();
    delete &onExitAction();
    delete &onEntryAction();
    delete _transitions[0];
    delete _transitions[1];
}

void Wait_For_Pulse_End::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_End_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_Internal.mm"
}

void Wait_For_Pulse_End::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_End_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_OnExit.mm"
}

void Wait_For_Pulse_End::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_End_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_OnEntry.mm"
}

bool Wait_For_Pulse_End::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_End_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_FuncRefs.mm"
 
    return
    (
#include "State_Wait_For_Pulse_End_Transition_0.expr"
    );
}

bool Wait_For_Pulse_End::Transition_1::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_End_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_End_FuncRefs.mm"
 
    return
    (
#include "State_Wait_For_Pulse_End_Transition_1.expr"
    );
}
