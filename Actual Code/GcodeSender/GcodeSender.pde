import processing.serial.*;
import java.awt.event.KeyEvent;
import javax.swing.JOptionPane;


int possible_width_of_map = 0, possible_height_of_map = 0;
int x = 0, y = 0;
boolean pen_is_up = true;
int x_step = 6;
int y_step = 6;

Serial port = null;
String portname = null;
boolean streaming = false;


void setup() {
  size(700, 550);
}


void draw() {

  background(155);
  fill(0);
  int y = 24, dy = 24;
  text("INSTRUCTIONS", 12, y); 
  y += dy;
  text("p: select serial port", 12, y); 
  
  textSize(13);
  text("1: set jog to 6 steps per jog", 12, y); 
  y += dy;
  text("2: set jog to 50 steps per jog", 12, y); 
  y += dy;
  text("3: set jog to 100 steps per jog", 12, y); 
  y += dy;
  text("               Forward", 12, y); 
  y += dy;
  text("                    ^", 12, y); 
  y += dy;
  text("Left <           v          > Right", 12, y); 
  y += dy;
  text("             Backward", 12, y); 
  y += dy;
  text("PAGE_UP: go up in z axis", 12, y); 
  y += dy;
  text("PAGE_DOWN: go down in z axis", 12, y); 
  y += dy;
  text("h: go home", 12, y); 
  y += dy;
  text("c: clear chat", 12, y); 
  y += dy;
  text("0: set home to the current location", 12, y); 
  
  y += dy;
  y = height - dy;
  text("ALT: stop streaming coordinates", 12, y); 
  y -= dy;
  text("current jog: " + x_step + " steps", 12, y); 
  y -= dy;
  text("current serial port: " + portname, 12, y); 
  y -= dy;
  

  if (port!=null) {
    if ( port.available() > 0) {
      String response = port.readStringUntil('\n');
      if (response!=null) {
        if(!response.contains("Done"));
          println(response);
        treat_response(response);
      }
    }
  }
}


void go_home(){
  if(port!=null){
    port.write("0 0 0\n");
  } else {
    println("Can't go home, port is null");
  }
}


boolean im_typing = false;
void keyPressed() {
  
  if (port!=null) {
     if (key == 'h' || key == 'H') {
      go_home();
      println("Going home");
    } else if (key == '0') {
      port.write("h\n");
    } else if (key == '1') {
      port.write("y\n");
      x_step = 6;
      y_step = 6;
    } else if (key == '2') {
      port.write("t\n");
      x_step = 50;
      y_step = 50;
    } else if (key == '3') {
      port.write("r\n");
      x_step = 100;
      y_step = 100;
    } else if (keyCode == LEFT) {
      if (x<x_step) {
        println("\nReached edge of map\n");
      }
      x -= x_step;
      port.write("q\n");
    } else if (keyCode == RIGHT) {
      if (x>possible_width_of_map-x_step) {
        println("\nReached edge of map\n");
      }
      x += x_step;
      port.write("d\n");
    } else if (keyCode == UP) {
      if (y>possible_height_of_map-y_step) {
        println("\nReached edge of map\n");
      }
      y += y_step;
      port.write("z\n");
    } else if (keyCode == DOWN) {
      if (y<y_step) {
        println("\nReached edge of map\n");
      }
      y -= y_step;
      port.write("s\n");
    } else if (keyCode == KeyEvent.VK_PAGE_UP) {
      port.write("e\n");
    }
    else if (keyCode == KeyEvent.VK_PAGE_DOWN){
      port.write("a\n");
    }
  } else {
    println("Please select a port first");
  }
  
  if (keyCode == KeyEvent.VK_ALT) {
    println("DUDE CLICK ON THE PROGRAM WINDOW AGAIN TO BE ABLE TO STEER THE MACHINE AND CONTINUE RUNNING");
    go_home();
  }
}


void treat_response(String response) {
  if (response.contains("Ready")) {
    response = response.substring(0, response.length()-2);
    String[] pieces = response.split(" ");
    possible_width_of_map = Integer.parseInt(pieces[1]);
    possible_height_of_map = Integer.parseInt(pieces[2]);
  } else if(response.contains("Done")){
  }
  
}

void openSerialPort() {
  if (portname == null) return;
  if (port != null) port.stop();

  port = new Serial(this, portname, 9600);

  port.bufferUntil('\n');
}


void selectSerialPort() {
  String result = (String) JOptionPane.showInputDialog(frame, 
    "Select the serial port that corresponds to your Arduino board.", 
    "Select serial port", 
    JOptionPane.QUESTION_MESSAGE, 
    null, 
    Serial.list(), 
    0);

  if (result != null) {
    portname = result;
    openSerialPort();
  }
}
