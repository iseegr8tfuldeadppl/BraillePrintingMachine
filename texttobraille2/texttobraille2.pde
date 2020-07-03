// Braille to text conversion imports
import java.util.*;
import java.util.ArrayList;
import javafx.util.Pair;
import java.lang.Math;

// Control Imports
import processing.serial.*;
import java.awt.event.KeyEvent;
import javax.swing.JOptionPane;

// Braille to text conversion variables
int slots_per_line = 14;
int lines = 2;
int vertical_spacing_between_single_slot_dots = 200; // 1
int horizontal_spacing_between_single_slot_dots = 100; // 1
int vertical_spacing_between_full_slots = 500; // 2
int horizontal_spacing_between_full_slots = 200; // 3

int width_of_map = 0, height_of_map = 0;
int possible_width_of_map = 0, possible_height_of_map = 0;
int height_of_slot = 0, width_of_slot = 0;

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
  width_of_map = slots_per_line*width_of_slot;
  height_of_map = lines*height_of_slot;

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
  text("x: stop streaming coordinates", 12, y); 
  y -= dy;
  text("current jog: " + step + " steps", 12, y); 
  y -= dy;
  text("current serial port: " + portname, 12, y); 
  y -= dy;
  

  if (port!=null) {
    if ( port.available() > 0) {
      String response = port.readStringUntil('\n');
      if (response!=null) {
        print(response);
        treat_response(response);
      }
    }
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
          port.write(coordinates.get(0).x + " " + coordinates.get(0).y + " 1\n");
          print("sentence has been sent to the machine");
        } else {
          print("\nHave you entered an empty sentence?");
        }
      }
    } else if(key == KeyEvent.VK_BACK_SPACE){
      if(sentence.length()>0)
        sentence = sentence.substring(0, sentence.length()-1);
    } else {
      if(key_is_valid(key))
        sentence += key;
    }
    
  } else if (index==-1) {
    
      if (key == KeyEvent.VK_ENTER) {
        im_typing = true;
        print("You can now type a sentence!");
      } else {
        if (key == 'p') selectSerialPort();
        if (key == 'c') print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");
        
        if (port!=null) {
          if (keyCode == '0') {
            port.write("Sethome\n");
            x = 0;
            y = 0;
          } else if (keyCode == '1') {
            port.write("Step10\n");
            step = 10;
          } else if (keyCode == '2') {
            port.write("Step50\n");
            step = 50;
          } else if (keyCode == '3') {
            port.write("Step100\n");
            step = 100;
          } else if (keyCode == 'h') {
            port.write("0 0 0\n");
          } else if (keyCode == LEFT) {
            if (x>=step) {
              port.write("q\n");
            } else {
              print("\nReached edge of map");
            }
          } else if (keyCode == RIGHT) {
            if (x<=possible_width_of_map-step) {
              port.write("d\n");
            } else {
              print("\nReached edge of map");
            }
          } else if (keyCode == UP) {
            if (y<=possible_height_of_map-step) {
              port.write("z\n");
            } else {
              print("\nReached edge of map");
            }
          } else if (keyCode == DOWN) {
            if (y>=step) {
              port.write("s\n");
            } else {
              print("\nReached edge of map");
            }
          } else if (keyCode == KeyEvent.VK_PAGE_UP) port.write("e\n");
          else if (keyCode == KeyEvent.VK_PAGE_DOWN) port.write("a\n");
        } else {
          print("\nPlease select a port first");
        }
    
        if (key == 'x') {
          coordinates = new ArrayList<Coordinates>();
          sentence = "";
          index = -1;
        }
      }
  
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
    String[] pieces = response.split(" ");
    possible_width_of_map = Integer.parseInt(pieces[1]);
    possible_height_of_map = Integer.parseInt(pieces[2]);
    if (possible_width_of_map<width_of_map) {
      port = null;
      print("\n\nYour result of width_of_map " + width_of_map + " exceed the maximum possible_width_of_map " + possible_width_of_map + "\n\n");
    } else if (possible_height_of_map<height_of_map) {
      port = null;
      print("\n\nYour result of height_of_map " + height_of_map + " exceed the maximum possible_height_of_map " + possible_height_of_map + "\n\n");
    }
  } else if (response.equals("Done")) {
    if (index!=-1) {
      port.write(coordinates.get(index).x + " " + coordinates.get(0).y + " 1\n");

      if (index==coordinates.size()) {
        sentence = "";
        index = -1;
        coordinates = new ArrayList<Coordinates>();
      }
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

  // mirror coodinates so when you poke at the paper you can flip it upside-down to actually read from a better side
  for (Coordinates coord : coordinates)
    coord.x = width_of_map - coord.x;


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

  // re-order coordinates from top to bottom / bottom to top interchangeably so my machine can go up bzz down bzz up bzz down bzz
  boolean upside_true_downside_false = true;
  for (int i=0; i<coordinates_len; i++) {
    for (int j=0; j<coordinates_len; j++) {
      if (coordinates_len>j+1) {
        if (coordinates.get(j).x==coordinates.get(j+1).x) {

          if (upside_true_downside_false) {
            if (coordinates.get(j).y>coordinates.get(j+1).y) {
              Coordinates temp = coordinates.get(j);
              coordinates.set(j, coordinates.get(j+1));
              coordinates.set(j+1, temp);
            }
          } else {
            if (coordinates.get(j).y<coordinates.get(j+1).y) {
              Coordinates temp = coordinates.get(j);
              coordinates.set(j, coordinates.get(j+1));
              coordinates.set(j+1, temp);
            }
          }
        } else {
          upside_true_downside_false = !upside_true_downside_false;
        }
      } else
        break;
    }
  }

  for (Coordinates coords : coordinates)  print("\nx " + coords.x + " y " + coords.y);
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
  boolean first_character = true;
  String result = "";
  for (char character : word.toCharArray()) {

    if (is_a_number(character) &&  (!currently_number || first_character)) {
      first_character = false;
      currently_number = true;
      result += "}";
    } else if (!is_a_number(character) && (currently_number || first_character)) {
      first_character = false;
      currently_number = false;
      result += "{";
    }

    if (is_capitalized(character)) {
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

  // Preparation 3: find how many slots there can be
  int amount_of_slots = amount_of_slots_portrait();

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

  Slot selected_slot = slots.get(slottag);
  Coordinates new_coordinates = new Coordinates();

  switch(letter) {
  case "{": // Letter indicator
    new_coordinates.x = selected_slot.point4x;     
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;     
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "}": // Number indicator
    new_coordinates.x = selected_slot.point2x;     
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;     
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;     
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;     
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "/": // Capitalization indicator
    new_coordinates.x = selected_slot.point6x;     
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "1":
  case "A":
  case "a":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "2":
  case "B":
  case "b":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "3":
  case "C":
  case "c":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "4":
  case "D":
  case "d":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "5":
  case "E":
  case "e":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "6":
  case "F":
  case "f":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "7":
  case "G":
  case "g":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "8":
  case "H":
  case "h":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "9":
  case "I":
  case "i":
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "0":
  case "J":
  case "j":
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "K":
  case "k":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "L":
  case "l":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "M":
  case "m":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "N":
  case "n":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "O":
  case "o":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "P":
  case "p":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "Q":
  case "q":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "R":
  case "r":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "S":
  case "s":
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "T":
  case "t":
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "U":
  case "u":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "V":
  case "v":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "W":
  case "w":
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "X":
  case "x":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "Y":
  case "y":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "Z":
  case "z":
    new_coordinates.x = selected_slot.point1x;
    new_coordinates.y = selected_slot.point1y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case ".":
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case ",":
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case " ":
    break;
  case ";":
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case ":":
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
    /*
      case "/":
     new_coordinates.x = selected_slot.point2x;
     new_coordinates.y = selected_slot.point2y;
     coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
     new_coordinates = new Coordinates();
     new_coordinates.x = selected_slot.point5x;
     new_coordinates.y = selected_slot.point5y;
     coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
     break;
     */
  case "?":
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "!":
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "(":
  case ")":
    new_coordinates.x = selected_slot.point3x;
    new_coordinates.y = selected_slot.point3y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point6x;
    new_coordinates.y = selected_slot.point6y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    break;
  case "@":
    new_coordinates.x = selected_slot.point2x;
    new_coordinates.y = selected_slot.point2y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point4x;
    new_coordinates.y = selected_slot.point4y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
    new_coordinates = new Coordinates();
    new_coordinates.x = selected_slot.point5x;
    new_coordinates.y = selected_slot.point5y;
    coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
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
