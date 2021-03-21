//
// UltrasonicDiscrete.mm
//
// This is a generated file - do not change manually.
//
#include "UltrasonicDiscrete_Includes.h"
#include "UltrasonicDiscrete.h"

#include "State_InitialPseudoState.h"
#include "State_Initial.h"
#include "State_Setup_Pin.h"
#include "State_SetupMeasure.h"
#include "State_PrintDistance.h"
#include "State_Wait.h"
#include "State_Wait_For_Pulse_Start.h"
#include "State_Skip_Garbage.h"
#include "State_Wait_For_Pulse_End.h"
#include "State_Calculate_Distance.h"

using namespace FSM;
using namespace CLM;

extern "C"
{
    UltrasonicDiscrete *CLM_Create_UltrasonicDiscrete(int mid, const char *name)
    {
        return new UltrasonicDiscrete(mid, name);
    }
}

UltrasonicDiscrete::UltrasonicDiscrete(int mid, const char *name): CLMachine(mid, name)
{
    _states[0] = new FSMUltrasonicDiscrete::State::InitialPseudoState;
    _states[1] = new FSMUltrasonicDiscrete::State::Initial;
    _states[2] = new FSMUltrasonicDiscrete::State::Setup_Pin;
    _states[3] = new FSMUltrasonicDiscrete::State::SetupMeasure;
    _states[4] = new FSMUltrasonicDiscrete::State::PrintDistance;
    _states[5] = new FSMUltrasonicDiscrete::State::Wait;
    _states[6] = new FSMUltrasonicDiscrete::State::Wait_For_Pulse_Start;
    _states[7] = new FSMUltrasonicDiscrete::State::Skip_Garbage;
    _states[8] = new FSMUltrasonicDiscrete::State::Wait_For_Pulse_End;
    _states[9] = new FSMUltrasonicDiscrete::State::Calculate_Distance;

    setInitialState(_states[0]);            // set initial state
}

UltrasonicDiscrete::~UltrasonicDiscrete()
{
    delete _states[0];
    delete _states[1];
    delete _states[2];
    delete _states[3];
    delete _states[4];
    delete _states[5];
    delete _states[6];
    delete _states[7];
    delete _states[8];
    delete _states[9];
}
