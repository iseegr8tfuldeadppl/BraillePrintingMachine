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
boolean ready = false;
String[] gcode;
int i = 0;


void setup() {
  size(700, 550);
}


void draw() {

  background(155);
  fill(0);
  textSize(13);
  int y = 24, dy = 24;
  
  text("INSTRUCTIONS", 12, y); y += dy;
  text("p: select serial port", 12, y); y += dy;
  text("1: set jog to default (6) steps per jog", 12, y); y += dy;
  text("2: set jog to 50 steps per jog", 12, y); y += dy;
  text("3: set jog to 100 steps per jog", 12, y); y += dy;
  text("UP: forward", 12, y); y += dy;
  text("LEFT: left", 12, y); y += dy;
  text("RIGHT: right", 12, y); y += dy;
  text("DOWN: down", 12, y); y += dy;
  text("PAGE_UP: go up in z axis", 12, y); y += dy;
  text("PAGE_DOWN: go down in z axis", 12, y); y += dy;
  text("h: go home", 12, y); y += dy;
  text("c: clear chat", 12, y); y += dy;
  text("g: stream gcode file", 12, y); y += dy;
  text("0: set home to the current location", 12, y); y += dy;
  
  y = height - dy;
  text("ALT: stop streaming coordinates", 12, y); y -= dy;
  text("current jog: " + x_step + " steps", 12, y); y -= dy;
  text("current serial port: " + portname, 12, y); y -= dy;
  
  receive_serial_prints();
}


void receive_serial_prints() {
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
    port.write("G1 X0 Y0\n");
    return;
  }
  println("Can't go home, port is null");
}


void select_gcode_file() {
  gcode = null; i = 0;
  File file = null; 
  println("Loading file...");
  selectInput("Select a file to process:", "fileSelected", file);
}



void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    gcode = loadStrings(selection.getAbsolutePath());
    if (gcode == null) return;
    streaming = true;
    stream();
  }
}


boolean endOfFile(){
  if (i == gcode.length) {
    streaming = false;
    return true;
  }
  return false;
}

void stream() {  
  while(!endOfFile()){
    if(gcode[i].startsWith("G1") || gcode[i].startsWith("G4") ||gcode[i].startsWith("M300 S30") || gcode[i].startsWith("M300 S50"))
        break;
    else
        i ++;
  }
  
  if(endOfFile())
    return;
  
  println(gcode[i]);
  port.write(gcode[i] + '\n');
  i++;
}



void keyPressed() {

  if (key == 'p' || key == 'P') selectSerialPort();
        
  if (port==null)
    return;

  if (keyCode == KeyEvent.VK_ALT) {
    streaming = false;
    go_home();
    return;
  }

  if(streaming)
    return;

   if (key == 'g' || key == 'G') {
      select_gcode_file();
      println("finna select a gcode  file");
  } else if (key == 'h' || key == 'H') {
      go_home();
      println("Going home");
  } else if (key == '0') {
      port.write("G0\n");
  } 
  
  else if (key == '1') {
      x_step = 6;
      y_step = 6;
      port.write("B1\n");
  } else if (key == '2') {
      x_step = 50;
      y_step = 50;
      port.write("B2\n");
  } else if (key == '3') {
      x_step = 100;
      y_step = 100;
      port.write("B3\n");
  } 
  
  else if (keyCode == LEFT) {
      if (x<x_step) println("\nReached edge of map\n");
      x -= x_step;
      port.write("G1 X" + x + " Y" + y + "\n");
  } else if (keyCode == RIGHT) {
      if (x>possible_width_of_map-x_step) println("\nReached edge of map\n");
      x += x_step;
      port.write("G1 X" + x + " Y" + y + "\n");
  } else if (keyCode == UP) {
      if (y>possible_height_of_map-y_step) println("\nReached edge of map\n");
      y += y_step;
      port.write("G1 X" + x + " Y" + y + "\n");
  } else if (keyCode == DOWN) {
      if (y<y_step) println("\nReached edge of map\n");
      y -= y_step;
      port.write("G1 X" + x + " Y" + y + "\n");
  } 
  
  else if (keyCode == KeyEvent.VK_PAGE_UP) {
    port.write("M300 S50\n");
  } else if (keyCode == KeyEvent.VK_PAGE_DOWN){
    port.write("M300 S30\n");
  }
    
}


void treat_response(String response) {
  if (response.contains("Ready")) {
      response = response.substring(0, response.length()-2);
      String[] pieces = response.split(" ");
      possible_width_of_map = Integer.parseInt(pieces[1]);
      possible_height_of_map = Integer.parseInt(pieces[2]);
      ready = true;
  } else if(response.contains("Done")){
    stream();
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
