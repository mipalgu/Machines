//
// State_Wait_For_Pulse_Start.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_Wait_For_Pulse_Start.h"
#include "State_Wait_For_Pulse_Start_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

Wait_For_Pulse_Start::Wait_For_Pulse_Start(const char *name): CLState(name, *new Wait_For_Pulse_Start::OnEntry, *new Wait_For_Pulse_Start::OnExit, *new Wait_For_Pulse_Start::Internal)
{
    _transitions[0] = new Transition_0();
    _transitions[1] = new Transition_1();
}

Wait_For_Pulse_Start::~Wait_For_Pulse_Start()
{
    delete &onEntryAction();
    delete &onExitAction();
    delete &internalAction();
    delete _transitions[0];
    delete _transitions[1];
}

void Wait_For_Pulse_Start::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_Start_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_OnEntry.mm"
}

void Wait_For_Pulse_Start::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_Start_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_OnExit.mm"
}

void Wait_For_Pulse_Start::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_Start_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_Internal.mm"
}

bool Wait_For_Pulse_Start::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_Start_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_FuncRefs.mm"
 
    return
    (
#include "State_Wait_For_Pulse_Start_Transition_0.expr"
    );
}

bool Wait_For_Pulse_Start::Transition_1::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Wait_For_Pulse_Start_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Wait_For_Pulse_Start_FuncRefs.mm"
 
    return
    (
#include "State_Wait_For_Pulse_Start_Transition_1.expr"
    );
}
