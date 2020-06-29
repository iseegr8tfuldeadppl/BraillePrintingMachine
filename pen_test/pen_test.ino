#include <Servo.h>

const int penZUp = 100; // make me larger
const int penZDown = 140; // 135
const int penServoPin = 6;
Servo penServo;  

void setup() {
  penServo.attach(penServoPin);
}

void loop() {
  penServo.write(penZUp);
  delay(1000);
  penServo.write(penZDown);
  delay(1000);
}
