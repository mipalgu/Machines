//
// UltrasonicDiscrete_Variables.h
//
// This is a generated file - do not change manually.
//
int	numPins;	///< number of US distance sensors
uint8_t *	echoPins;	///< pin numbers for echo signal
uint8_t *	triggerPins;	///< pin numbers to trigger
uint8_t *	currentTrigger;	///< pointer to current trigger pin
uint8_t *	currentEcho;	///< pointer to current echo pin
uint8_t	i;	///< current sensor index
uint8_t	inputPin;	///< echo input pin number
uint8_t	outputPin;	///< trigger pin number
uint16_t	distance;	///< measured distance in mm
unsigned long	width;	///< measured pulse width
unsigned long	numloops;	///< iteration count
unsigned long	maxloops;	///< maximum iterations
uint8_t	inputPort;	///< input port number
uint8_t	inputBit;	///< bit mask for input
