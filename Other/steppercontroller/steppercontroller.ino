#include <Stepper.h> 
#define STEPS 200

// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver
Stepper stepper(STEPS, 5, 6); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
Stepper stepper2(STEPS, 3, 4); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
Stepper stepper3(STEPS, 7, 8); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver

//#define motorInterfaceType 1
int maximum_width = 4550;
int maximum_height = 2070;
int maximum_medium = 690; // 1700 absolute maximum, 620 great value

int x = 0, y = 0, z = maximum_medium;

int z_state = 0; // will be 0 or 1 according to current state and will be applied
int old_z_state = 0; // needed for confirmations
    
String coordinates_x = "", coordinates_y = "", coordinates_z = "";
bool coordinates_x_ready = false, coordinates_y_ready = false, coordinates_z_ready = false;

// x y axis step
int stepo = 10;

// z axis step
int stepo2 = 10;


void setup() {

  Serial.begin(9600);

  stepper.setSpeed(500); // max 1000
  stepper2.setSpeed(500); // max 1000
  stepper3.setSpeed(500); // max 1000
  Serial.println("Started!\n(note: X and Y axis step is " + String(stepo, DEC) + " and Z axis step is " + String(stepo2, DEC) + ")\na (go up)     z (forward)     e (go down)\nq (left)      s (backward)    d (right)\n\nOr type coordinates and it will go there!\n(note: enter the coordinates in the following order)\n\n   x-axis:\n      a number between 0 and " + String(maximum_width, DEC) + "\n   y-axis:\n      a number between 0 and " + String(maximum_height, DEC) + "\n   z-axis: (note: range is " + String(maximum_medium, DEC) + ")\n      0. to go up.\n      1. to go down");

}

bool is_a_number(char received){
  switch(received){
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '0':
      return true;
    default:
      return false;
  }
}

void showcoords() {
  Serial.println("x: " + String(x, DEC) + " y: " + String(y, DEC) + " z: " + String(z, DEC) + " with state: " + String(z_state, DEC) + ".\n\n\n");
}

void run_z_state(int state){

  // if state is 1 go down
  if(state==1){
      z = 0;
      Serial.println("going down");
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
  
  // if state is 0 go up
  } else {
      z = maximum_medium;
      Serial.println("going up");
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
}


bool previous_method_1_has_ran = false;
void loop() {

  if (Serial.available() > 0) {
    
    // Step 1: read the incoming message:
    char received = Serial.read();

    // Step 2: check if user wants directional stepping
    boolean method_1_has_ran = true;
    switch(received){
      case 'e':
        old_z_state = z_state;
        z_state = 0;
        break;
      case 'a':
        old_z_state = z_state;
        z_state = 1;
        break;
      case 'q':
        Serial.println("left");
        if(x>=stepo){
          x -= stepo;
          stepper.step(-stepo);
          stepper2.step(-stepo);
        }
        showcoords();
        break;
      case 'd':
        Serial.println("right");
        if(x<=maximum_width-stepo){
          x += stepo;
          stepper.step(stepo);
          stepper2.step(stepo);
        }
        showcoords();
        break;
      case 's':
        Serial.println("backward");
        if(y>=stepo){
          y -= stepo;
          stepper.step(-stepo);
          stepper2.step(stepo);
        }
        showcoords();
        break;
      case 'z':
        Serial.println("forward");
        if(y<=maximum_height-stepo){
          y += stepo;
          stepper.step(stepo);
          stepper2.step(-stepo);
        }
        showcoords();
        break;
      default:
        method_1_has_ran = false;
        Serial.println("entered default mode.");
        break;
    }

    // Step 2.2: run z axis if requested
    if(old_z_state!=z_state && method_1_has_ran){
      Serial.println("entered here");
      Serial.println("old_z_state " + String(old_z_state, DEC) + " z_state " + String(z_state, DEC));
      old_z_state = z_state;
      run_z_state(z_state);
    }

    // Pre-Step 3: if method 1 didn't run then check for method 2
    if(!method_1_has_ran && !previous_method_1_has_ran){

      // Pre-Step 3: reset previous_method_1_has_ran
      previous_method_1_has_ran = true;
      
      // Step 3: check if user is inputting coordinates
      if(is_a_number(received) || received=='\n'){
  
        // Step 3.1: convert serial input into string
        String message = String(received);
  
        // Step 3.2: check for coordinates_x
        if(!coordinates_x_ready){
    
          // Step 3.2.1: serial sends \n at end of any serial input
          if(message=="\n"){
            
            // Step 3.2.2: double safety to check if we're here with coordinates and not an empty coordinate
            if(coordinates_x!=""){
              
              // Step 3.2.3: if coordinate is within inforced range accept it, else clear variable
              if(coordinates_x.toInt()>=0 && coordinates_x.toInt()<=maximum_width){
                coordinates_x_ready= true;
                Serial.println("caught x coordinate " + coordinates_x);
              } else {
                coordinates_x = "";
                Serial.println("Given x coordinate is out of range of travel please stay between 0 and " + String(maximum_width));
              }
            }
          } 
          // Step 3.2.4: if we get here then we're still reading the full number just keep appending
          else
            coordinates_x += message;
  
  
        // Step 3.3: check for coordinates_y
        } else if(!coordinates_y_ready){
  
          // Step 3.3.1:  serial sends \n at end of any serial input
          if(message=="\n"){
  
            // Step 3.3.2: double safety to check if we're here with coordinates and not an empty coordinate
            if(coordinates_y!=""){
  
              // Step 3.3.3: if coordinate is within inforced range accept it, else clear variable
              if(coordinates_y.toInt()>=0 && coordinates_y.toInt()<=maximum_height){
                coordinates_y_ready= true;
                Serial.println("caught y coordinate " + coordinates_y);
              } else {
                coordinates_y = "";
                Serial.println("Given y coordinate is out of range of travel please stay between 0 and " + String(maximum_height));
              }
              
            }
          } 
          // Step 3.3.4: if we get here then we're still reading the full number just keep appending
          else
            coordinates_y += message;
          
        // Step 3.4: check for coordinates_z
        } else if(!coordinates_z_ready){
          
          // Step 3.3.1:  serial sends \n at end of any serial input
          if(message=="\n"){
  
            // Step 3.3.2: double safety to check if we're here with coordinates and not an empty coordinate
            if(coordinates_z!=""){
  
              // Step 3.3.3: if coordinate is within inforced range accept it, else clear variable
              if(coordinates_z=="0" || coordinates_z=="1"){
                coordinates_z_ready= true;
                old_z_state = z_state;
                z_state = coordinates_z.toInt();
                Serial.println("caught z state ");
              } else {
                coordinates_z = "";
                Serial.println("Given z state is wrong please choose either 1 to go down or 0 to go up");
              }
              
            }
          } 
          // Step 3.3.4: if we get here then we're still reading the full number just keep appending
          else
            coordinates_z = message;
        }
  
        // Step 3.4: if both coordinates were inputted then go to them
        if(coordinates_z_ready){
  
          // Step 3.4.1: go to coordinates
          int x_difference = coordinates_x.toInt()-x;
          if(x_difference>0){
            while(true){
              if(x_difference>=10){
                x_difference -= 10;
                stepper.step(10);
                stepper2.step(10);
              } else {
                stepper.step(x_difference);
                stepper2.step(x_difference);
                break;
              }
            }
          } else if(x_difference<0){
            while(true){
              if(x_difference<=-10){
                x_difference += 10;
                stepper.step(-10);
                stepper2.step(-10);
              } else {
                stepper.step(x_difference);
                stepper2.step(x_difference);
                break;
              }
            }
          }
  
          
          int y_difference = coordinates_y.toInt()-y;
  
          if(y_difference>0){
            while(true){
              if(y_difference>=10){
                y_difference -= 10;
                stepper.step(10);
                stepper2.step(-10);
              } else {
                stepper.step(y_difference);
                stepper2.step(-y_difference);
                break;
              }
            }
          } else if(y_difference<0){
            while(true){
              if(y_difference<=-10){
                y_difference += 10;
                stepper.step(-10);
                stepper2.step(10);
              } else {
                stepper.step(y_difference);
                stepper2.step(-y_difference);
                break;
              }
            }
          } else if(z_state!=old_z_state){
            Serial.println("no i enteredhere");
            old_z_state = z_state;
            run_z_state(z_state);
          }
  
          // Step 3.4.2: apply coordinates to x & y and then display it
          x = coordinates_x.toInt();
          y = coordinates_y.toInt();
          
          showcoords();
  
          // Step 3.4.3: clear variables
          coordinates_x = "";
          coordinates_y = "";
          coordinates_z = "";
          coordinates_x_ready = false;
          coordinates_y_ready = false;
          coordinates_z_ready = false;
        }
      }
    }

  
    // Step 4: save method_1_has_ran to cancel the \n that comes after it
    previous_method_1_has_ran = method_1_has_ran;
  }
}
