// Braille to text conversion imports
import java.util.*;
import java.util.ArrayList;
import javafx.util.Pair;
import java.lang.Math;

// Control Imports
import processing.serial.*;
import java.awt.event.KeyEvent;
import javax.swing.JOptionPane;


// Control variables
int x = 0, y = 0;
Serial port = null;
String portname = null;
int step = 10;
int step2 = 10;
boolean streaming = false;



void setup() {

  // Preparation 1: find the resolution of each slot
  height_of_slot = vertical_spacing_between_single_slot_dots*2 + vertical_spacing_between_full_slots + 3;
  width_of_slot = horizontal_spacing_between_single_slot_dots + horizontal_spacing_between_full_slots + 2;

  // Preparation 2: find the resolution of our print
  width_of_map = slots_per_line*width_of_slot - horizontal_spacing_between_full_slots;
  height_of_map = lines*height_of_slot - vertical_spacing_between_full_slots;
  
  // Preparation 3: find how many slots there can be
  amount_of_slots = amount_of_slots_portrait();

  size(700, 550);
  
  
 
    //possible_width_of_map = 9500;
    //possible_height_of_map = 2500;
 
}


// Braille to text conversion variables
int slots_per_line = 9; // 14
int lines = 4; // 2
int vertical_spacing_between_single_slot_dots = 200; // 1
int vertical_spacing_between_full_slots = 400; // 2

int horizontal_spacing_between_single_slot_dots = 200; // 1
int horizontal_spacing_between_full_slots = 400; // 3

int width_of_map = 0, height_of_map = 0;
int possible_width_of_map = 0, possible_height_of_map = 0;
int height_of_slot = 0, width_of_slot = 0;
int amount_of_slots = 0;

void draw() {

  background(155);
  fill(0);
  int y = 24, dy = 24;
  text("INSTRUCTIONS", 12, y); 
  y += dy;
  text("p: select serial port", 12, y); 
  
  textSize(13);
  y += 2*dy;
  text("ENTER: press enter and start typing, once done press enter again to send it to the machine.", 12, y); 
  y += dy;
  text("SENTENCE: " + sentence, 12, y); 
  y += 2*dy;
  
  text("1: set jog to 10 steps per jog", 12, y); 
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
  text("current jog: " + step + " steps", 12, y); 
  y -= dy;
  text("current serial port: " + portname, 12, y); 
  y -= dy;
  

  if (port!=null) {
    if ( port.available() > 0) {
      String response = port.readStringUntil('\n');
      if (response!=null) {
        if(!response.contains("Done") && !response.contains("going"));
          println(response);
        treat_response(response);
      }
    }
  }
}


boolean sentence_with_indicators_fits(){
  String new_sentence = add_indicators(sentence);
  return new_sentence.length()<amount_of_slots;
}


void go_home(){
  if(port!=null){
    port.write("0 0 0\n");
  } else {
    println("Can't go home, port is null");
  }
}


String sentence = "";
boolean im_typing = false;
void keyPressed() {
  if(im_typing){

    if (key == KeyEvent.VK_ENTER) {
      im_typing = false;
      
      if (port!=null) {
      
        turn_into_coordinates();
        if (coordinates.size()>0) {
          index = 0;
          port.write("h\n");
        } else {
          println("Have you entered an empty sentence?");
        }
      }
    } else if(key == KeyEvent.VK_BACK_SPACE){
      if(sentence.length()>0)
        sentence = sentence.substring(0, sentence.length()-1);
    } else {
      if(key_is_valid(key) && sentence_with_indicators_fits())
        sentence += key;
      else println("You have reached the maximum amount of letters");
    }
    
  } else if (index==-1) {
    
      if (key == KeyEvent.VK_ENTER && port!=null) {
        im_typing = true;
        println("You can now type a sentence!");
      } else {
        if (key == 'p' || key == 'P') selectSerialPort();
        if (key == 'c' || key == 'C') println("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        if (key == 'l' || key == 'L') println("x: " + x + " y: " + y);
        
        if (port!=null) {
           if (key == 'h' || key == 'H') {
            go_home();
            println("Going home");
          } else if (key == '0') {
            port.write("h\n");
          } else if (key == '1') {
            port.write("y\n");
            step = 10;
          } else if (key == '2') {
            port.write("t\n");
            step = 50;
          } else if (key == '3') {
            port.write("r\n");
            step = 100;
          } else if (keyCode == LEFT) {
            if (x<step) {
              println("\nReached edge of map\n");
            }
            x -= step;
            port.write("q\n");
          } else if (keyCode == RIGHT) {
            if (x>possible_width_of_map-step) {
              println("\nReached edge of map\n");
            }
            x += step;
            port.write("d\n");
          } else if (keyCode == UP) {
            if (y>possible_height_of_map-step) {
              println("\nReached edge of map\n");
            }
            y += step;
            port.write("z\n");
          } else if (keyCode == DOWN) {
            if (y<step) {
              println("\nReached edge of map\n");
            }
            y -= step;
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
    
      }
  
  }
  if (keyCode == KeyEvent.VK_ALT) {
    println("DUDE CLICK ON THE PROGRAM WINDOW AGAIN TO BE ABLE TO STEER THE MACHINE AND CONTINUE RUNNING");
    coordinates = new ArrayList<Coordinates>();
    sentence = "";
    index = -1;
    go_home();
  }
}



// Control Section


boolean key_is_valid(char key){
  switch(key){
    case 'a':
    case 'A':
    case 'b':
    case 'B':
    case 'c':
    case 'C':
    case 'd':
    case 'D':
    case 'e':
    case 'E':
    case 'f':
    case 'F':
    case 'g':
    case 'G':
    case 'h':
    case 'H':
    case 'i':
    case 'I':
    case 'j':
    case 'J':
    case 'k':
    case 'K':
    case 'l':
    case 'L':
    case 'm':
    case 'M':
    case 'n':
    case 'N':
    case 'o':
    case 'O':
    case 'p':
    case 'P':
    case 'q':
    case 'Q':
    case 'r':
    case 'R':
    case 's':
    case 'S':
    case 't':
    case 'T':
    case 'u':
    case 'U':
    case 'v':
    case 'V':
    case 'w':
    case 'W':
    case 'x':
    case 'X':
    case 'y':
    case 'Y':
    case 'z':
    case 'Z':
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '.':
    case ':':
    case ';':
    case '@':
    case ' ':
    case '!':
    case '?':
    case '(':
    case ')':
    case ',':
      return true;
    default:
      return false;
  }
}



void treat_response(String response) {
  if (response.contains("Ready")) {
    
    // Pre: remove \n
    response = response.substring(0, response.length()-2);
    String[] pieces = response.split(" ");
    possible_width_of_map = Integer.parseInt(pieces[1]);
    possible_height_of_map = Integer.parseInt(pieces[2]);
    println("Your result of width_of_map " + width_of_map + " maximum possible_width_of_map " + possible_width_of_map);
    println("Your result of height_of_map " + height_of_map + " maximum possible_height_of_map " + possible_height_of_map);
    if (possible_width_of_map<width_of_map) {
      port = null;
      portname = null;
      println("Your result of width_of_map " + width_of_map + " exceed the maximum possible_width_of_map " + possible_width_of_map);
    } else if (possible_height_of_map<height_of_map) {
      port = null;
      portname = null;
      println("Your result of height_of_map " + height_of_map + " exceed the maximum possible_height_of_map " + possible_height_of_map);
    }
  } else if (response.contains("Done")) {
    if (index!=-1) {

      index += 1;
      if (index==coordinates.size()) {
        println("sentence " + sentence);
        sentence = "";
        index = -1;
        coordinates = new ArrayList<Coordinates>();
        go_home();
      } else {
        println("Sending dot x: " + coordinates.get(index).x + " y: " + coordinates.get(index).y + " " + coordinates.get(index).poke_request);
        port.write(coordinates.get(index).x + " " + coordinates.get(index).y + " " + coordinates.get(index).poke_request + "\n");
      }
    }
  } else if(response.contains("Home set")){
    x = 0;
    y = 0;
    println("Home set received");
    
    if(index==0){
      port.write(coordinates.get(0).x + " " + coordinates.get(0).y + " " + coordinates.get(0).poke_request + "\n");
      println("Sending dot x: " + coordinates.get(0).x + " y: " + coordinates.get(0).y + "\n");
    }
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



// Braille to text conversion section
List<Coordinates> coordinates = new ArrayList<Coordinates>();
int index = -1;

void turn_into_coordinates() {

  String new_sentence = add_indicators(sentence);
  Pair<String, List<Coordinates>> p = blabla(new_sentence);

  // re-order dot coordinates from left to right
  coordinates = p.getValue();
  int coordinates_len = coordinates.size();

  for (int i=0; i<coordinates_len; i++) {
    for (int j=0; j<coordinates_len; j++) {
      if (coordinates_len>j+1) {
        if (coordinates.get(j).x>coordinates.get(j+1).x) {
          Coordinates temp = coordinates.get(j);
          coordinates.set(j, coordinates.get(j+1));
          coordinates.set(j+1, temp);
        }
      } else
        break;
    }
  }
  
  
  // i'm counting the different values of x so i can loop after this in a way that makes dots go up and down in ordering so the machine goes up and down as it prints not just down down down and wasting trajectory
  List<Integer> all_possible_x = new ArrayList<Integer>();
  for(Coordinates coord:coordinates){
    boolean alrdy_in = false;
    for(Integer x:all_possible_x){
      if(x==coord.x){
        alrdy_in = true;
        break;
      }
    }
    if(!alrdy_in)
        all_possible_x.add(coord.x);
  }
  
  // re-order coordinates from top to bottom
  for (int i=0; i<coordinates_len; i++) {
    for (int j=0; j<coordinates_len; j++) {
      if (coordinates_len>j+1) {
        if (coordinates.get(j).x==coordinates.get(j+1).x) {

          // find x in the all_possible_x list and then decide if we're ordering upwards or downwards
          int x_odd_or_even = -1;
          for(int z=0; z<all_possible_x.size(); z++){
            if(coordinates.get(j).x==all_possible_x.get(z)){
              x_odd_or_even = z;
              break;
            }
          }
          
          if(x_odd_or_even==-1){
            println("Fatal error in x_odd_or_even equaling to -1");
          } else if(x_odd_or_even%2==0){
            if (coordinates.get(j).y<coordinates.get(j+1).y) {
              Coordinates temp = coordinates.get(j);
              coordinates.set(j, coordinates.get(j+1));
              coordinates.set(j+1, temp);
            }
            
          } else {
            if (coordinates.get(j).y>coordinates.get(j+1).y) {
              Coordinates temp = coordinates.get(j);
              coordinates.set(j, coordinates.get(j+1));
              coordinates.set(j+1, temp);
            }
          }
                    
        }
      } else
        break;
    }
  }
  
  
  // add the dots that just go to maximum y of the same x to be able to move with more accuracy
  //List<Coordinates> new_coordinates = new  ArrayList<Coordinates>();
  
  /*
  // add the first rama9 of going up to maximum
  new_coordinates.add(new Coordinates() {{
    x = 0;
    y = possible_height_of_map;
    poke_request = 0;
  }});
  
  for(int i=0; i<coordinates.size(); i++){
    final int i_final = i;
    new_coordinates.add(new Coordinates(){{
      x= coordinates.get(i_final).x;
      y= coordinates.get(i_final).y;
      poke_request = 1;
    }});
    
    if(coordinates.size()>i+1){
      if(coordinates.get(i).x != coordinates.get(i+1).x){
        new_coordinates.add(new Coordinates() {{
          x = coordinates.get(i_final).x;
          y = possible_height_of_map;
          poke_request = 0;
        }});
      }
    }
  }
  
  // add the last rama9 of going up to maximum
  final int final_coordinates_len = coordinates.size();
  new_coordinates.add(new Coordinates() {{
    x = coordinates.get(final_coordinates_len-1).x;
    y = possible_height_of_map;
    poke_request = 0;
  }});
  
  coordinates = new ArrayList<Coordinates>();
  coordinates.addAll(new_coordinates);
  
  int counter = 0;
  for(Coordinates coord:coordinates){
    if(coord.poke_request==1)
      counter += 1;
  }
  println("counter " + counter);
  */
  
  
  /*
  // mirror coodinates so when you poke at the paper you can flip it upside-down to actually read from a better side
  int mirror_value = coordinates.get(0).x;
  for (Coordinates coord : new_coordinates)
    coord.x = mirror_value - coord.x;
  */
  
  println("last x " + coordinates.get(coordinates.size()-1).x + " last y " + coordinates.get(coordinates.size()-1).y + " last poke_request " + coordinates.get(coordinates.size()-1).poke_request);
  //println("coordinates_len " + coordinates.size());
  for (Coordinates coords : coordinates) println("x " + coords.x + " y " + coords.y);
  println("sentence " + sentence);
  println(coordinates.size() + " dots");
  
  //String map  = p.getKey();  print(map);
}



private boolean is_a_number(char character) {
  try {
    Integer.parseInt(String.valueOf(character));
    return true;
  } 
  catch(NumberFormatException ignored) {
    return false;
  }
}



private boolean is_capitalized(char character) {
  switch(String.valueOf(character)) {
  case "A":
  case "B":
  case "C":
  case "D":
  case "E":
  case "F":
  case "G":
  case "H":
  case "I":
  case "J":
  case "K":
  case "L":
  case "M":
  case "N":
  case "O":
  case "P":
  case "Q":
  case "R":
  case "S":
  case "T":
  case "U":
  case "V":
  case "W":
  case "X":
  case "Y":
  case "Z":
    return true;
  default:
    return false;
  }
}



private String add_indicators(String word) {
  boolean currently_number = false;
  boolean currently_capitalized = false;
  String result = "";
  for (char character : word.toCharArray()) {

    // Add number indicator at the beggining and the end of strings of numbers
    if (is_a_number(character) && !currently_number) {
      currently_number = true;
      result += "}";
    } else if (!is_a_number(character) && currently_number) {
      currently_number = false;
      result += "}";
    }
    
    // Add capitalization indicator at the beginning and the end of strings of capitalized words
    if (is_capitalized(character) && !currently_capitalized) {
      currently_capitalized = true;
      result += "/";
    } else if (!is_capitalized(character) && currently_capitalized) {
      currently_capitalized = false;
      result += "/";
    }

    result += character;
  }
  return result;
}



private Pair<String, List<Coordinates>> blabla(String word) {

  List<Coordinates> coordinates_of_all_po9able_dots = new ArrayList<Coordinates>();
  List<Coordinates> coordinates_of_dots_to_po9_for_this_paragraph = new ArrayList<Coordinates>();
  String map = "";
  List<Slot> slots = new ArrayList<Slot>();    

  // out of range alert
  if (word.length()>amount_of_slots) {
    println("Error: The slots available can't fit your paragraph as there's " + amount_of_slots + " slots available but your paragraph requires " + word.length() + ", which is higher by " + String.valueOf(word.length()-amount_of_slots + ".")
      + '\n' + "Tips: decrease the size of letters (currently " + height_of_slot + " x " + width_of_slot + ")."
      + '\n' + "      Increase slots per line (currently " + slots_per_line + ")."
      + '\n' + "      Increase amount of lines (currently " + lines + ").");

    return new Pair<String, List<Coordinates>>("", coordinates_of_dots_to_po9_for_this_paragraph);
  }

  // Preparation 4: find all po9able coordinates in the space
  coordinates_of_all_po9able_dots = find_coords_of_all_po9able_dots_portrait(horizontal_spacing_between_single_slot_dots, vertical_spacing_between_single_slot_dots);

  // Preparation 5: apply corresponding coordinates to all slots
  slots = split_coords_between_ordered_slots_portrait(coordinates_of_all_po9able_dots, amount_of_slots, slots_per_line, lines);

  // Preparation 6: get the specific dots to po9
  for (int i=0; i<word.length(); i++) {
    coordinates_of_dots_to_po9_for_this_paragraph = apply_this_letter_to_this_slot_portrait(i, String.valueOf(word.charAt(i)), slots, coordinates_of_dots_to_po9_for_this_paragraph);
  }

  // Experiment: build a console-friendly map
  //map = print_map_portrait(coordinates_of_dots_to_po9_for_this_paragraph, coordinates_of_all_po9able_dots, horizontal_spacing_between_full_slots, vertical_spacing_between_full_slots); 

  return new Pair<String, List<Coordinates>>("", coordinates_of_dots_to_po9_for_this_paragraph);
}



private String print_map_portrait(List<Coordinates> coordinates_of_dots_to_po9_for_this_paragraph, List<Coordinates> coordinates_of_all_po9able_dots, int horizontal_spacing_between_full_slots, int vertical_spacing_between_full_slots) {

  StringBuilder map_builder = new StringBuilder();

  // put a hat on it
  for (int i=0; i<width_of_map+1; i++) {
    map_builder.append("-");
  }
  map_builder.append('\n');

  for (int i=0; i<height_of_map-vertical_spacing_between_full_slots; i++) {

    // put a wall at the start of each line
    map_builder.append("| ");

    for (int j=0; j<width_of_map-horizontal_spacing_between_full_slots; j++) {

      // If this location was requested to be po9ed a.k.a is in the po9_list then append "." or else just append " "
      boolean po9_it = false;
      boolean po9ble_dot = false;

      for (Coordinates dot : coordinates_of_all_po9able_dots) {
        if (dot.x == j && dot.y == i) {
          po9ble_dot = true;
          break;
        }
      }

      for (Coordinates dot : coordinates_of_dots_to_po9_for_this_paragraph) {
        if (dot.x == j && dot.y == i) {
          po9_it = true;
          break;
        }
      }

      if (po9ble_dot) {
        if (po9_it) {
          map_builder.append("o");
        } else {
          map_builder.append(" ");
        }
      } else {
        map_builder.append(" ");
      }
    }

    // put a wall at the end of each line
    map_builder.append(" |");

    // new line
    map_builder.append('\n');
  }

  // cover its butt
  for (int i=0; i<width_of_map+1; i++) {
    map_builder.append("-");
  }

  return map_builder.toString();
}



private List<Coordinates> apply_this_letter_to_this_slot_portrait(int slottag, String letter, List<Slot> slots, List<Coordinates> coordinates_of_dots_to_po9_for_this_paragraph) {

  final Slot selected_slot = slots.get(slottag);

  switch(letter) {
  case "}": // Number indicator
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "/": // Capitalization indicator
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "1":
  case "A":
  case "a":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    break;
  case "2":
  case "B":
  case "b":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    break;
  case "3":
  case "C":
  case "c":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    break;
  case "4":
  case "D":
  case "d":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    break;
  case "5":
  case "E":
  case "e":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    break;
  case "6":
  case "F":
  case "f":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    break;
  case "7":
  case "G":
  case "g":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    break;
  case "8":
  case "H":
  case "h":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    break;
  case "9":
  case "I":
  case "i":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    break;
  case "0":
  case "J":
  case "j":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    break;
  case "K":
  case "k":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "L":
  case "l":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "M":
  case "m":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "N":
  case "n":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "O":
  case "o":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "P":
  case "p":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "Q":
  case "q":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "R":
  case "r":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "S":
  case "s":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "T":
  case "t":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "U":
  case "u":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "V":
  case "v":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "W":
  case "w":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "X":
  case "x":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "Y":
  case "y":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "Z":
  case "z":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point1x;
      y = selected_slot.point1y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case ".":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case ",":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    break;
  case " ":
    break;
  case ";":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case ":":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    break;
  case "?":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "!":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "(":
  case ")":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "@":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "+":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "-":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    break;
  case "*":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    break;
  case "=":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point3x;
      y = selected_slot.point3y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  case "#":
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point2x;
      y = selected_slot.point2y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point4x;
      y = selected_slot.point4y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point5x;
      y = selected_slot.point5y;
      poke_request = 1;
    }});
    coordinates_of_dots_to_po9_for_this_paragraph.add(new Coordinates() {{
      x = selected_slot.point6x;
      y = selected_slot.point6y;
      poke_request = 1;
    }});
    break;
  default:
    println("Unknown character " + letter);
    break;
  }

  return coordinates_of_dots_to_po9_for_this_paragraph;
}



private List<Slot> split_coords_between_ordered_slots_portrait(List<Coordinates> coordinates_of_all_po9able_dots, int amount_of_slots, int slots_per_line, int lines) {
  List<Slot> slots = new ArrayList<Slot>();

  for (int i=0; i<amount_of_slots; i++) {
    slots.add(new Slot());
  }

  for (int j=0; j<lines; j++) { // we iterate over every line (by just adding +j*slots_per_line down below we can jump to the slots in the next line)
    for (int i=0; i<slots_per_line; i++) { // we iterate over every Slot in that line

      // these two points are situation in the first line next to each other
      slots.get(i+j*slots_per_line).point1x = coordinates_of_all_po9able_dots.get(i*2+j*slots_per_line*2*3).x;
      slots.get(i+j*slots_per_line).point1y = coordinates_of_all_po9able_dots.get(i*2+j*slots_per_line*2*3).y;

      slots.get(i+j*slots_per_line).point2x = coordinates_of_all_po9able_dots.get(i*2+1+j*slots_per_line*2*3).x;
      slots.get(i+j*slots_per_line).point2y = coordinates_of_all_po9able_dots.get(i*2+1+j*slots_per_line*2*3).y;

      // these two points are situation in the second line next to each other
      slots.get(i+j*slots_per_line).point3x = coordinates_of_all_po9able_dots.get(slots_per_line*2+i*2+j*slots_per_line*2*3).x;
      slots.get(i+j*slots_per_line).point3y = coordinates_of_all_po9able_dots.get(slots_per_line*2+i*2+j*slots_per_line*2*3).y;

      slots.get(i+j*slots_per_line).point4x = coordinates_of_all_po9able_dots.get(slots_per_line*2+1+i*2+j*slots_per_line*2*3).x;
      slots.get(i+j*slots_per_line).point4y = coordinates_of_all_po9able_dots.get(slots_per_line*2+1+i*2+j*slots_per_line*2*3).y;

      // these two points are situation in the third line next to each other
      slots.get(i+j*slots_per_line).point5x = coordinates_of_all_po9able_dots.get(slots_per_line*2*2+i*2+j*slots_per_line*2*3).x;
      slots.get(i+j*slots_per_line).point5y = coordinates_of_all_po9able_dots.get(slots_per_line*2*2+i*2+j*slots_per_line*2*3).y;

      slots.get(i+j*slots_per_line).point6x = coordinates_of_all_po9able_dots.get(slots_per_line*2*2+1+i*2+j*slots_per_line*2*3).x; // *2 is because each Slot has 2 dots
      slots.get(i+j*slots_per_line).point6y = coordinates_of_all_po9able_dots.get(slots_per_line*2*2+1+i*2+j*slots_per_line*2*3).y;
    }
  }
  return slots;
}



private int amount_of_slots_portrait() {
  int amount_of_slots = 0;
  int temp_width_of_map = width_of_map;
  while (temp_width_of_map>0) {
    amount_of_slots ++;
    temp_width_of_map -= width_of_slot;
  }
  int lines = 0;
  int temp_height_of_map = height_of_map;
  while (temp_height_of_map>0) {
    lines += 1;
    temp_height_of_map -= height_of_slot;
  }

  amount_of_slots = amount_of_slots * lines;

  return amount_of_slots;
}



private List<Coordinates> find_coords_of_all_po9able_dots_portrait(int horizontal_spacing_between_single_slot_dots, int vertical_spacing_between_single_slot_dots) {
  List<Coordinates> coordinates_of_all_po9able_dots = new ArrayList<Coordinates>();

  for (int i=0; i<height_of_map; i++) {
    for (int j=0; j<width_of_map; j++) {

      // this is just looking for the dots, and getting their coordinates
      if (     (
        i%height_of_slot==0 
        || i%height_of_slot==vertical_spacing_between_single_slot_dots+1 
        || i%height_of_slot==(vertical_spacing_between_single_slot_dots+1)*2
        ) 
        && 
        (
        j%width_of_slot == 0 
        || j%width_of_slot == horizontal_spacing_between_single_slot_dots+1)
        ) {

        Coordinates coordinates_of_a_po9able_dot = new Coordinates();
        coordinates_of_a_po9able_dot.x = j;
        coordinates_of_a_po9able_dot.y = i;
        coordinates_of_all_po9able_dots.add(coordinates_of_a_po9able_dot);
      }
    }
  }

  return coordinates_of_all_po9able_dots;
}



private class Coordinates {
  int x;
  int y;
  int poke_request;
}



private class Slot {
  int point1x;
  int point1y;
  int point2x;
  int point2y;
  int point3x;
  int point3y;
  int point4x;
  int point4y;
  int point5x;
  int point5y;
  int point6x;
  int point6y;
}
