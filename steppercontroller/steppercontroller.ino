#include <Stepper.h> 
#define STEPS 200

// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver
Stepper stepper(STEPS, 5, 6); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
Stepper stepper2(STEPS, 3, 4); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
Stepper stepper3(STEPS, 7, 8); // Pin 2 connected to DIRECTION & Pin 3 connected to STEP Pin of Driver
//#define motorInterfaceType 1
int x = 0, y = 0, z = 0;
int maximum_width = 4550;
int maximum_height = 2070;
int maximum_medium = 1700;

void setup() {
  Serial.begin(9600);
  stepper.setSpeed(0); // max 1000
  stepper2.setSpeed(0); // max 1000
  stepper3.setSpeed(0); // max 1000
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
  Serial.println("x " + String(x, DEC) + " y " + String(y, DEC));
}

String coordinates_x = "", coordinates_y = "";
bool coordinates_x_ready = false, coordinates_y_ready = false;
void loop() {

  //if (Serial.available() > 0) {
    
    // Step 1: read the incoming message:
    //char received = Serial.read();
    char received = "";

    // Step 1.5: detect z axis
    
    int stepo2 = 10;
    while(true){
      delay(350);
      if(received=='g')
        received='e';
      else
        received='g';
      if(received=='g'){
          Serial.println("going down");
          stepper3.setSpeed(1000); // max 1000
          int temp_maximum_medium2 = -maximum_medium;
          while(true){
            if(temp_maximum_medium2<=-stepo2){
              temp_maximum_medium2 += stepo2;
              stepper3.step(-stepo2);
            } else {
              stepper3.step(temp_maximum_medium2);
              stepper3.setSpeed(0); // max 1000
              break;
            }
          }
          Serial.println("lmfao");
          z = 0;
      } else if(received=='e'){
          Serial.println("going up");
          stepper3.setSpeed(1000); // max 1000
          int temp_maximum_medium = maximum_medium;
          while(true){
            if(temp_maximum_medium>=stepo2){
              temp_maximum_medium -= stepo2;
              stepper3.step(stepo2);
            } else {
              stepper3.step(temp_maximum_medium);
              stepper3.setSpeed(0); // max 1000
              break;
            }
          }
          z = maximum_medium;
      }
    }
    
    // Step 2: check if user wants directional stepping
    int stepo = 10;
    switch(received){
      case 'q':
        Serial.println("left");
        if(x>=stepo){
          x -= stepo;
          showcoords();
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          stepper.step(-stepo);
          stepper2.step(-stepo);
          stepper.setSpeed(0); // max 1000
          stepper2.setSpeed(0); // max 1000
          return;
        }
        showcoords();
        break;
      case 'd':
        Serial.println("right");
        if(x<=maximum_width-stepo){
          x += stepo;
          showcoords();
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          stepper.step(stepo);
          stepper2.step(stepo);
          stepper.setSpeed(0); // max 1000
          stepper2.setSpeed(0); // max 1000
          return;
        }
        showcoords();
        break;
      case 's':
        Serial.println("backward");
        if(y>=stepo){
          y -= stepo;
          showcoords();
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          stepper.step(-stepo);
          stepper2.step(stepo);
          stepper.setSpeed(0); // max 1000
          stepper2.setSpeed(0); // max 1000
          return;
        }
        showcoords();
        break;
      case 'z':
        Serial.println("forward");
        if(y<=maximum_height-stepo){
          y += stepo;
          showcoords();
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          stepper.step(stepo);
          stepper2.step(-stepo);
          stepper.setSpeed(0); // max 1000
          stepper2.setSpeed(0); // max 1000
          return;
        }
        showcoords();
        break;
      default:
        //Serial.println("Enter:\n  1. To go left.\n  2. To go right.\n  3. To go forward.\n  4. To go backward.");
        break;
    }

    // Step 3: check if user is inputting coordinates
    if(is_a_number(received) || received=='\n'){

      // Step 3.1: convert serial input into string
      String message = String(received);

      // Step 3.2: check for coordinate_x
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


      // Step 3.3: check for coordinate_y
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
        
      }

      // Step 3.4: if both coordinates were inputted then go to them
      if(coordinates_y_ready){

        // Step 3.4.1: go to coordinates
        int x_difference = coordinates_x.toInt()-x;
        if(x_difference>0){
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          while(true){
            if(x_difference>=10){
              x_difference -= 10;
              stepper.step(10);
              stepper2.step(10);
            } else {
              stepper.step(x_difference);
              stepper2.step(x_difference);
              stepper.setSpeed(0); // max 1000
              stepper2.setSpeed(0); // max 1000
              break;
            }
          }
        } else if(x_difference<0){
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          while(true){
            if(x_difference<=-10){
              x_difference += 10;
              stepper.step(-10);
              stepper2.step(-10);
            } else {
              stepper.step(x_difference);
              stepper2.step(x_difference);
              stepper.setSpeed(0); // max 1000
              stepper2.setSpeed(0); // max 1000
              break;
            }
          }
        }

        
        int y_difference = coordinates_y.toInt()-y;

        if(y_difference>0){
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          while(true){
            if(y_difference>=10){
              y_difference -= 10;
              stepper.step(10);
              stepper2.step(-10);
            } else {
              stepper.step(y_difference);
              stepper2.step(-y_difference);
              stepper.setSpeed(0); // max 1000
              stepper2.setSpeed(0); // max 1000
              break;
            }
          }
        } else if(y_difference<0){
          stepper.setSpeed(500); // max 1000
          stepper2.setSpeed(500); // max 1000
          while(true){
            if(y_difference<=-10){
              y_difference += 10;
              stepper.step(-10);
              stepper2.step(10);
            } else {
              stepper.step(y_difference);
              stepper2.step(-y_difference);
              stepper.setSpeed(0); // max 1000
              stepper2.setSpeed(0); // max 1000
              break;
            }
          }
        }

        // Step 3.4.2: apply coordinates to x & y and then display it
        x = coordinates_x.toInt();
        y = coordinates_y.toInt();
        
        showcoords();

        // Step 3.4.3: clear variables
        coordinates_x = "";
        coordinates_y = "";
        coordinates_x_ready = false;
        coordinates_y_ready = false;
      }
    }

 // }
}
