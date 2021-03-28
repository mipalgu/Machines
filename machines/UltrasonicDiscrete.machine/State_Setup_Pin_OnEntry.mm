digitalWrite(RXLED, (i & 1) ? LOW : HIGH);
outputPin = *currentTrigger++;
inputPin = *currentEcho++;
pinMode(inputPin, INPUT);
digitalWrite(outputPin, LOW);
pinMode(outputPin, OUTPUT);
