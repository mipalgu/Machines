//
// State_Skip_Garbage.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_Skip_Garbage.h"
#include "State_Skip_Garbage_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

Skip_Garbage::Skip_Garbage(const char *name): CLState(name, *new Skip_Garbage::OnEntry, *new Skip_Garbage::Internal, *new Skip_Garbage::OnExit)
{
    _transitions[0] = new Transition_0();
}

Skip_Garbage::~Skip_Garbage()
{
    delete &onEntryAction();
    delete &internalAction();
    delete &onExitAction();
    delete _transitions[0];
}

void Skip_Garbage::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Skip_Garbage_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Skip_Garbage_FuncRefs.mm"
#include "State_Skip_Garbage_OnEntry.mm"
}

void Skip_Garbage::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Skip_Garbage_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Skip_Garbage_FuncRefs.mm"
#include "State_Skip_Garbage_Internal.mm"
}

void Skip_Garbage::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Skip_Garbage_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Skip_Garbage_FuncRefs.mm"
#include "State_Skip_Garbage_OnExit.mm"
}

bool Skip_Garbage::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Skip_Garbage_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Skip_Garbage_FuncRefs.mm"
 
    return
    (
#include "State_Skip_Garbage_Transition_0.expr"
    );
}
