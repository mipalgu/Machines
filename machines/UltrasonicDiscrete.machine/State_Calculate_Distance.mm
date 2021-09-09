//
// State_Calculate_Distance.mm
//
// Automatically created through MiPalCASE -- do not change manually!
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_Calculate_Distance.h"

#include "State_Calculate_Distance_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

Calculate_Distance::Calculate_Distance(const char *name): CLState(name, *new Calculate_Distance::OnEntry, *new Calculate_Distance::OnExit, *new Calculate_Distance::Internal)
{
	_transitions[0] = new Transition_0();
}

Calculate_Distance::~Calculate_Distance()
{
	delete &onEntryAction();
	delete &onExitAction();
	delete &internalAction();

	delete _transitions[0];
}

void Calculate_Distance::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_Calculate_Distance_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_Calculate_Distance_FuncRefs.mm"
#	include "State_Calculate_Distance_OnEntry.mm"
}

void Calculate_Distance::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_Calculate_Distance_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_Calculate_Distance_FuncRefs.mm"
#	include "State_Calculate_Distance_OnExit.mm"
}

void Calculate_Distance::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_Calculate_Distance_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_Calculate_Distance_FuncRefs.mm"
#	include "State_Calculate_Distance_Internal.mm"
}

bool Calculate_Distance::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_Calculate_Distance_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_Calculate_Distance_FuncRefs.mm"

	return
	(
#		include "State_Calculate_Distance_Transition_0.expr"
	);
}
