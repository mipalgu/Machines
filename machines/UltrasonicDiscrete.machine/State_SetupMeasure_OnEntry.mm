// keep initialisation out of time critical area
width = 0;
distance = 65535;		// max. distance
numloops = 0;
inputBit = digitalPinToBitMask(inputPin);
inputPort = digitalPinToPort(inputPin);
