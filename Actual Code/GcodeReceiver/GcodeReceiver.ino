#include <Stepper.h> 
#define STEPS 200
#include <ctype.h>

// Setup: X & Y axies
// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver
Stepper stepper1(STEPS, 3, 4); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
// activator = pin 10
#define stepper1Enable 10

Stepper stepper2(STEPS, 5, 6); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
// activator = pin 11
#define stepper2Enable 11

int x_range = 5300; // 9500 4550
int y_range = 3200; // 2500 2070

int x = 0, y = 0;


// Setup: pen
Stepper pen(STEPS, 7, 8); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
// activator = pin 9
#define penEnable 9

int z_range = 2005; // 1700 absolute maximum, 620 great value / 1300 better / 2100 best / best 2005
boolean pen_is_up = true;

String command = "";

void setup() {

  // Prepare: X & Y axies
  pinMode(stepper1Enable, OUTPUT);
  pinMode(stepper2Enable, OUTPUT);
  pinMode(penEnable, OUTPUT);
  digitalWrite(stepper1Enable, HIGH);
  digitalWrite(stepper2Enable, HIGH);
  digitalWrite(penEnable, HIGH);
  
  // Prepare: Serial
  Serial.begin(9600);
  
  stepper1.setSpeed(500); // max 1000
  stepper2.setSpeed(500); // max 1000
  pen.setSpeed(500); // max 1000
  
  // Prepare: Display Information
  //Serial.println("Ready " + String(x_range, DEC) + " " + String(y_range, DEC));
}


void loop() {

  // Pre: keep listening for messages
  if (Serial.available() > 0) {
    
    // Step 1: read the incoming message:
    char received = Serial.read();

    // Step 2: Check if this is end of a command
    if(received=='\n'){

      // Step 2.2: if so check if command isn't empty
      if(command!=""){
        process_command();
        command = "";
        Serial.println("Done");
      } 

    // Step 2.3: command is still being supplied keep reading
    } else {
        command += String(received);
    }
    
  }
}


void process_command(){

  if(command.startsWith("G1")){
    treat_coordinates();
    return;
  } 
  
  if(command=="M300 S30"){
    if(pen_is_up)
      move_pen(false);
    return;
  } 
  
  if(command=="M300 S50"){
    if(!pen_is_up)
      move_pen(true);
    return;
  } 
  
  if(command.startsWith("G4")){
    int value = treat_delay();
    delay(value);
    return;
  }
  
  if(command=="G0"){
    x = 0;
    y = 0;
    return;
  }
}

int treat_delay() {
    int index = 0;
    char * token = strtok(command.c_str(), " ");
    while( token != NULL ) {

      if(index==1){
          String tokeno = String(token);
          tokeno.replace("P", "");
          return atof(tokeno.c_str());
          break;
      }

      index ++;
      token = strtok(NULL, " ");
    }
    return 1;
}

void move_pen(boolean up_true_down_false){

  // Step 1: setup
  int temp_z_range = z_range;
  int z_step_each = 6;

  // Step 2: if going down flip variable
  int value = z_step_each;
  if(!up_true_down_false)
    value = -z_step_each;

  // Step 3: execute
  while(temp_z_range>z_step_each){
    pen.step(value);
    temp_z_range -= z_step_each;
  }

  // Step 4: step last few steps
  if(temp_z_range>0){
    
    value = temp_z_range;
    if(!up_true_down_false)
      value = -temp_z_range;
    
    pen.step(value);
  }

  pen_is_up = up_true_down_false;
  
}

void treat_coordinates(){

  int y_step_each = 6;
  int x_step_each = 6;
  //int delay_between_x_and_y = 1;

  // Step 1: loop through the string to extract coordinates
    float x_in_command, y_in_command;
    int index = 0;
    char * token = strtok(command.c_str(), " ");
    while( token != NULL ) {

      if(index==1){
          String tokeno = String(token);
          tokeno.replace("X", "");
          x_in_command = atof(tokeno.c_str());
      } else if(index==2){
          String tokeno = String(token);
          tokeno.replace("Y", "");
          y_in_command = atof(tokeno.c_str());
          break;
      }

      index ++;
      token = strtok(NULL, " ");
    }

    // Step 2: find distance to walk
    x = 0;
    y = 0;
    float x_difference = x_in_command - x;
    float y_difference = y_in_command - y;

    // Step 3: sort of triangulate the distance

    // Step 3.1: ratio
    float ratio = x_difference / y_difference;

    float x_step = ratio * x_step_each, y_step = y_step_each;

    // Step 3.2: if we're going further into y than into x then flip the ratio
    if(x_difference!=0 && y_difference!=0){
      if(abs(ratio)<1){
        ratio = 1 / ratio; 

        x_step = x_step_each;
        y_step = ratio * y_step_each;
      }
    } else {
      ratio = 1;
      x_step = x_step_each;
    }

    // Prep 4 : if it's going left/backwards flip variables
    if(x_difference<0)
      x_step = -x_step;
      
    if(y_difference<0)
      y_step = - y_step;

    x_difference = abs(x_difference);
    y_difference = abs(y_difference);

    // Step 5: move motors interchangeably between x and y
    while(x_difference>x_step_each || y_difference>y_step_each){

      // Step 5.1: go into x
      if(x_difference>0){
        stepper1.step(x_step);
        stepper2.step(x_step);

        // Step 5.1.2: decrease difference, update x but for the last rama9
        x_difference -= abs(x_step);
        
        //delay(delay_between_x_and_y);
      }

      // Step 5.2: go into y
      if(y_difference>0){
          stepper1.step(y_step);
          stepper2.step(-y_step);

        // Step 5.2.2: decrease difference, update y
        y_difference -= abs(y_step);
        //delay(delay_between_x_and_y);
      }
      
    }

    // Step the last few steps
    if(x_difference>0){
        
      int value = x_difference;
      if(x_step<0)
        value = - x_difference;
        
      stepper1.step(value);
      stepper2.step(value);
    }
      
    
    // Step the last few steps
    if(y_difference>0){
        
      int value = y_difference;
      if(y_step<0)
        value = -y_difference;
        
      stepper1.step(value);
      stepper2.step(-value);
    }

    // update x and y
    x = x_in_command;
    y = y_in_command;

    Serial.println("after x " + String(x, DEC) + " y " + String(y, DEC));
  
}
