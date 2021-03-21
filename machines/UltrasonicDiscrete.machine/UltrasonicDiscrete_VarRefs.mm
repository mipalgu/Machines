//
// UltrasonicDiscrete_VarRefs.mm
//
// Automatically created through MiPalCASE -- do not change manually!
//
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wshadow"

UltrasonicDiscrete *_m = static_cast<UltrasonicDiscrete *>(_machine);

int	&numPins = _m->numPins;	///< number of US distance sensors
uint8_t *	&echoPins = _m->echoPins;	///< pin numbers for echo signal
uint8_t *	&triggerPins = _m->triggerPins;	///< pin numbers to trigger
uint8_t *	&currentTrigger = _m->currentTrigger;	///< pointer to current trigger pin
uint8_t *	&currentEcho = _m->currentEcho;	///< pointer to current echo pin
uint8_t	&i = _m->i;	///< current sensor index
uint8_t	&inputPin = _m->inputPin;	///< echo input pin number
uint8_t	&outputPin = _m->outputPin;	///< trigger pin number
uint16_t	&distance = _m->distance;	///< measured distance in mm
unsigned long	&width = _m->width;	///< measured pulse width
unsigned long	&numloops = _m->numloops;	///< iteration count
unsigned long	&maxloops = _m->maxloops;	///< maximum iterations
uint8_t	&inputPort = _m->inputPort;	///< input port number
uint8_t	&inputBit = _m->inputBit;	///< bit mask for input

#pragma clang diagnostic pop
