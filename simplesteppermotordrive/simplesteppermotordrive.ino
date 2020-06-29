#include <Stepper.h> 
#define STEPS 200

// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver
Stepper stepper(STEPS, 3, 4); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
#define motorInterfaceType 1

void setup() {
  // max 1000
  Serial.begin(9600);
    stepper.setSpeed(400);
}

int originaltime;
boolean save_original_time = true, is_forward = true, is_off = false;
float backward_time = 0.400,  forward_time= 0.500, off_time = 2;

void loop() {

  // On
  if(is_forward){
        if(save_original_time){
          save_original_time = false;
          originaltime = millis();
        } else {
          if(millis()>originaltime + forward_time * 1000){
            save_original_time = true;
            is_forward = false;
          } else {
            stepper.step(-5);
          }
        }

  // Off
  } else {
        if(save_original_time){
          save_original_time = false;
          originaltime = millis();
        } else {
          if(millis()>originaltime + backward_time * 1000){
            save_original_time = true;
            is_forward = true;
          } else {
            stepper.step(5);
          }
        }
  }
}
