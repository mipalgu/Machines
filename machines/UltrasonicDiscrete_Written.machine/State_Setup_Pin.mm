//
// State_Setup_Pin.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_Setup_Pin.h"
#include "State_Setup_Pin_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

Setup_Pin::Setup_Pin(const char *name): CLState(name, *new Setup_Pin::OnEntry, *new Setup_Pin::Internal, *new Setup_Pin::OnExit)
{
    _transitions[0] = new Transition_0();
}

Setup_Pin::~Setup_Pin()
{
    delete &onEntryAction();
    delete &internalAction();
    delete &onExitAction();
    delete _transitions[0];
}

void Setup_Pin::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Setup_Pin_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Setup_Pin_FuncRefs.mm"
#include "State_Setup_Pin_OnEntry.mm"
}

void Setup_Pin::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Setup_Pin_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Setup_Pin_FuncRefs.mm"
#include "State_Setup_Pin_Internal.mm"
}

void Setup_Pin::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Setup_Pin_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Setup_Pin_FuncRefs.mm"
#include "State_Setup_Pin_OnExit.mm"
}

bool Setup_Pin::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#include "UltrasonicDiscrete_VarRefs.mm"
#include "State_Setup_Pin_VarRefs.mm"
#include "UltrasonicDiscrete_FuncRefs.mm"
#include "State_Setup_Pin_FuncRefs.mm"
 
    return
    (
#include "State_Setup_Pin_Transition_0.expr"
    );
}
