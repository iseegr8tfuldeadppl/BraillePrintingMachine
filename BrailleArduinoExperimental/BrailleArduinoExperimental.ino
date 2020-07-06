#include <Stepper.h> 
#define STEPS 200
#include <ctype.h>

// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver
Stepper stepper(STEPS, 5, 6); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
Stepper stepper2(STEPS, 3, 4); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
Stepper stepper3(STEPS, 7, 8); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver

//#define motorInterfaceType 1
int maximum_width = 5300; // 9500 4550
int maximum_height = 3200; // 2500 2070
int maximum_medium = 2010; // 1700 absolute maximum, 620 great value / 1300 better / 2100 best

String coordinates_x = "", coordinates_y = "", coordinates_z = "";
int x = 0, y = 0, z = 0;


bool previous_method_1_has_ran = false;

int poke_request = 0; // will be 0 or 1 according to current state and will be applied

// x y axis step
int stepo = 10;

// z axis step
int stepo2 = 10;

String my_dude_coordinates_full_string = "";



void setup() {
  Serial.begin(9600);

  stepper.setSpeed(500); // max 1000
  stepper2.setSpeed(500); // max 1000
  stepper3.setSpeed(500); // max 1000
  /*
  Serial.println(
    "Started!\n(note: X and Y axis step is " + 
    String(stepo, DEC) + 
    " and Z axis step is " + 
    String(stepo2, DEC) + 
    ")\na (go up)     z (forward)     e (go down)\nq (left)      s (backward)    d (right)\n\n" + 
    "Or type coordinates as three numbers separated by 1 space each with the ranges 0-" + String(maximum_width, DEC) + " 0-" + String(maximum_height, DEC) + " 0/1 \n\n");
  */
  Serial.println("Ready " + String(maximum_width, DEC) + " " + String(maximum_height, DEC));
}



void loop() {

  if (Serial.available() > 0) {
    
    // Step 1: read the incoming message:
    char received = Serial.read();

    switch(received){
      case 'h':
        x = 0;
        y = 0;
        Serial.println("Home set");
        break;
      case 'r':
        stepo = 100;
        Serial.println("X-Y step is now 100");
        break;
      case 't':
        stepo = 50;
        Serial.println("X-Y step is now 50");
        break;
      case 'y':
        stepo = 10;
        Serial.println("X-Y step is now 10");
        break;
      default:
        // Step 2: check method 1 which is jogging the motor manually
        bool method_1_has_ran = manually_stepping_motor(received);
    
        // Step 3: check method 2 which is sending the motor to specific coordinates
        if(!method_1_has_ran && !previous_method_1_has_ran){
          automatically_stepping_motor(received);
    
          // Step 4: save method_1_has_ran to cancel the \n that comes after it
          previous_method_1_has_ran = method_1_has_ran;
        }
        break;
    }

  }
}



void automatically_stepping_motor(char received){

  bool coords_are_queued = false;

  if(isdigit(received) || received==' ' || received=='\n'){

    if(received!='\n')
      my_dude_coordinates_full_string += String(received);
    else
      coords_are_queued = check_coordinates_being_inputed(received);

  } else
    my_dude_coordinates_full_string = ""; // \0 just means empty char

  // Step 3.4: if both coordinates were inputted then go to them
  if(coords_are_queued){

    // Step 3.4.1: go to coordinates
    // Step 3.4.1.1: x axis
    int x_difference = coordinates_x.toInt()-x;
    step_motors_this_much(x_difference, "x");

    delay(630);
    // Step 3.4.1.2: y axis
    int y_difference = coordinates_y.toInt()-y;
    step_motors_this_much(y_difference, "y");

    // Step 3.4.1.3: z axis
    run_poke_request();

    // Step 3.4.3: aftermath cleanup & preparation to continue
    // converting coordinates_x/y into an array is necessary or else the atoi() function won't convert correctly
    x = coordinates_x.toInt();
    y = coordinates_y.toInt();
    
    coordinates_x = "";
    coordinates_y = "";
    coordinates_z = "";
    my_dude_coordinates_full_string = "";
    
    //showcoords();
    Serial.println("Done");
  }
}



bool manually_stepping_motor(char received){

  // Step 2: check if user wants directional stepping
  boolean method_1_has_ran = true;
  switch(received){
    case 'e':
      z = 0;
      z_go_up();
      break;
    case 'a':
      z = maximum_medium;
      z_go_down();
      break;
    case 'q':
      Serial.println("left");
      x -= stepo;
      stepper.step(-stepo);
      stepper2.step(-stepo);
      break;
    case 'd':
      Serial.println("right");
      x += stepo;
      stepper.step(stepo);
      stepper2.step(stepo);
      break;
    case 's':
      Serial.println("backward");
      y -= stepo;
      stepper.step(stepo);
      stepper2.step(-stepo);
      break;
    case 'z':
      Serial.println("forward");
      y += stepo;
      stepper.step(-stepo);
      stepper2.step(stepo);
      break;
    default:
      method_1_has_ran = false;
      //Serial.println("entered default mode.");
      break;
  }
  
  return method_1_has_ran;
}



bool check_coordinates_being_inputed(char received){
  
  // loop through the string to extract all other tokens
  if(strstr(my_dude_coordinates_full_string.c_str(), " ") != NULL) {
    char * token = strtok(my_dude_coordinates_full_string.c_str(), " ");
    int counter = 0;
    
    String temp_x, temp_y, temp_poke_request;
    while( token != NULL ) {
      counter += 1;
      String token_no_star = String(atoi(token), DEC);

      char tokenNoStar[1];
      strcpy(tokenNoStar, token);

      if(!isdigit(tokenNoStar[0])){
        my_dude_coordinates_full_string = "";
        Serial.println("coordinates must be integers");
        return false;
      }

      if(counter==1){
          temp_x = token_no_star;
          if(token_no_star.toInt() <0 && token_no_star.toInt()>maximum_width){
            Serial.println("Given x coordinate is out of range of travel please stay between 0 and " + String(maximum_width));
            return false;
          }
      } else if(counter==2){
          temp_y = token_no_star;
          if(token_no_star.toInt()<0 && token_no_star.toInt()>maximum_height){
            Serial.println("Given y coordinate is out of range of travel please stay between 0 and " + String(maximum_height));
            return false;
          }
      } else if(counter==3){
          temp_poke_request = token_no_star;
          if(token_no_star!="1" && token_no_star!="0"){
            Serial.println("Given z state is wrong please choose either 1 to go down or 0 to go up");
            return false;
          }
      } else {
        Serial.println("You entered more than 3 coordinates");
        return false;
      }
      token = strtok(NULL, " ");
    }
    
    if(counter==3){
      coordinates_x = temp_x;
      coordinates_y = temp_y;
      poke_request = temp_poke_request.toInt();
      return true;
    }
    
  }
  return false;
}



void showcoords() {
  Serial.println("x: " + String(x, DEC) + " y: " + String(y, DEC) + " z: " + String(z, DEC) + " with poke_request: " + String(poke_request, DEC));
}



void z_go_down(){
  Serial.println("going down");
  int temp_maximum_medium = maximum_medium;
  while(true){
    if(temp_maximum_medium>=stepo2){
      temp_maximum_medium -= stepo2;
      stepper3.step(stepo2);
    } else {
      stepper3.step(temp_maximum_medium);
      break;
    }
  }
}



void z_go_up(){
  Serial.println("going up");
  int temp_maximum_medium2 = -maximum_medium;
  while(true){
    if(temp_maximum_medium2<=-stepo2){
      temp_maximum_medium2 += stepo2;
      stepper3.step(-stepo2);
    } else {
      stepper3.step(temp_maximum_medium2);
      break;
    }
  }
}



void run_poke_request(){

  // if state is 1 poke the paper
  if(poke_request==1){
    z = 0;
    z_go_down();
    delay(400);
    z_go_up();
  }
}



void step_motors_this_much(int difference, String axis){

  // Prep: if it's y axis change accordingly
  int stepper_step = stepo;
  int stepper2_step = stepo;
  if(axis=="y")
    stepper_step = -stepo;

  // Prep 2 : if it's going left/backwards flip variables
  if(difference<0){
    difference = - difference;
    stepper_step = -stepper_step;
    stepper2_step = -stepper2_step;
  }

  // Main: do it
  while(true){
    if(difference>=stepo){
      difference -= stepo;
      stepper.step(stepper_step);
      stepper2.step(stepper2_step);
    } else {
      stepper.step(difference);
      stepper2.step(difference);
      break;
    }
  }
}
