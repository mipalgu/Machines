//
// State_InitialPseudoState.mm
//
// Automatically created through MiPalCASE -- do not change manually!
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"
#include "State_InitialPseudoState.h"

#include "State_InitialPseudoState_Includes.h"

using namespace FSM;
using namespace CLM;
using namespace FSMUltrasonicDiscrete;
using namespace State;

InitialPseudoState::InitialPseudoState(const char *name): CLState(name, *new InitialPseudoState::OnEntry, *new InitialPseudoState::OnExit, *new InitialPseudoState::Internal)
{
	_transitions[0] = new Transition_0();
}

InitialPseudoState::~InitialPseudoState()
{
	delete &onEntryAction();
	delete &onExitAction();
	delete &internalAction();

	delete _transitions[0];
}

void InitialPseudoState::OnEntry::perform(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_InitialPseudoState_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_InitialPseudoState_FuncRefs.mm"
#	include "State_InitialPseudoState_OnEntry.mm"
}

void InitialPseudoState::OnExit::perform(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_InitialPseudoState_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_InitialPseudoState_FuncRefs.mm"
#	include "State_InitialPseudoState_OnExit.mm"
}

void InitialPseudoState::Internal::perform(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_InitialPseudoState_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_InitialPseudoState_FuncRefs.mm"
#	include "State_InitialPseudoState_Internal.mm"
}

bool InitialPseudoState::Transition_0::check(CLMachine *_machine, CLState *_state) const
{
#	include "UltrasonicDiscrete_VarRefs.mm"
#	include "State_InitialPseudoState_VarRefs.mm"
#	include "UltrasonicDiscrete_FuncRefs.mm"
#	include "State_InitialPseudoState_FuncRefs.mm"

	return
	(
#		include "State_InitialPseudoState_Transition_0.expr"
	);
}
