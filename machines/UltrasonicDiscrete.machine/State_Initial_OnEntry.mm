TXLED0; //TX LED is not tied to a normally controlled pin
static uint8_t triggerArray[] = {3, 5, 7, 9};
static uint8_t echoArray[]    = {2, 4, 6, 8};
Serial.begin(9600);
triggerPins = triggerArray;
echoPins = echoArray;
numPins = sizeof(triggerArray) / sizeof(triggerArray[0]);
