//
// State_PrintDistance.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_PrintDistance.h"
#include "State_PrintDistance_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

PrintDistance::PrintDistance(const char *name): CLState(name, *new PrintDistance::Internal, *new PrintDistance::OnExit, *new PrintDistance::OnEntry)
{
    _transitions[0] = new Transition_0();
    _transitions[1] = new Transition_1();
}

PrintDistance::~PrintDistance()
{
    delete &internalAction();
    delete &onExitAction();
    delete &onEntryAction();
    delete _transitions[0];
    delete _transitions[1];
}

void PrintDistance::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_PrintDistance_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_PrintDistance_FuncRefs.mm"
#include "State_PrintDistance_Internal.mm"
}

void PrintDistance::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_PrintDistance_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_PrintDistance_FuncRefs.mm"
#include "State_PrintDistance_OnExit.mm"
}

void PrintDistance::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_PrintDistance_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_PrintDistance_FuncRefs.mm"
#include "State_PrintDistance_OnEntry.mm"
}

bool PrintDistance::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_PrintDistance_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_PrintDistance_FuncRefs.mm"
 
    return
    (
#include "State_PrintDistance_Transition_0.expr"
    );
}

bool PrintDistance::Transition_1::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_PrintDistance_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_PrintDistance_FuncRefs.mm"
 
    return
    (
#include "State_PrintDistance_Transition_1.expr"
    );
}
