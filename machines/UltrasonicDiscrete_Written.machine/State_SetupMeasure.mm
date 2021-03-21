//
// State_SetupMeasure.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_SetupMeasure.h"
#include "State_SetupMeasure_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

SetupMeasure::SetupMeasure(const char *name): CLState(name, *new SetupMeasure::OnExit, *new SetupMeasure::Internal, *new SetupMeasure::OnEntry)
{
    _transitions[0] = new Transition_0();
}

SetupMeasure::~SetupMeasure()
{
    delete &onExitAction();
    delete &internalAction();
    delete &onEntryAction();
    delete _transitions[0];
}

void SetupMeasure::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_SetupMeasure_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_SetupMeasure_FuncRefs.mm"
#include "State_SetupMeasure_OnExit.mm"
}

void SetupMeasure::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_SetupMeasure_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_SetupMeasure_FuncRefs.mm"
#include "State_SetupMeasure_Internal.mm"
}

void SetupMeasure::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_SetupMeasure_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_SetupMeasure_FuncRefs.mm"
#include "State_SetupMeasure_OnEntry.mm"
}

bool SetupMeasure::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_SetupMeasure_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_SetupMeasure_FuncRefs.mm"
 
    return
    (
#include "State_SetupMeasure_Transition_0.expr"
    );
}
