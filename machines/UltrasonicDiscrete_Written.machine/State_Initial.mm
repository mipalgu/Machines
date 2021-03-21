//
// State_Initial.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_Initial.h"
#include "State_Initial_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

Initial::Initial(const char *name): CLState(name, *new Initial::OnExit, *new Initial::Internal, *new Initial::OnEntry)
{
    _transitions[0] = new Transition_0();
}

Initial::~Initial()
{
    delete &onExitAction();
    delete &internalAction();
    delete &onEntryAction();
    delete _transitions[0];
}

void Initial::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Initial_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Initial_FuncRefs.mm"
#include "State_Initial_OnExit.mm"
}

void Initial::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Initial_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Initial_FuncRefs.mm"
#include "State_Initial_Internal.mm"
}

void Initial::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Initial_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Initial_FuncRefs.mm"
#include "State_Initial_OnEntry.mm"
}

bool Initial::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Initial_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Initial_FuncRefs.mm"
 
    return
    (
#include "State_Initial_Transition_0.expr"
    );
}
