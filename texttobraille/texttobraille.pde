import processing.serial.*;
import java.awt.PointerInfo;
import java.awt.MouseInfo;
import java.awt.Point;
import java.util.*;
import java.util.ArrayList;
import javafx.util.Pair; 

import java.lang.Math; 
//                      * * * Setup Part * * *                     //
int slots_per_line = 14;
int lines = 2;
int vertical_spacing_between_single_slot_dots = 1;
int horizontal_spacing_between_single_slot_dots = 1;
int vertical_spacing_between_full_slots = 2;
int horizontal_spacing_between_full_slots = 3;
boolean rotate_90_degrees = true;
String sentence = "This is test number 1";


void setup(){
    List<Coordinates> coordinates_of_dots_to_po9_for_this_paragraph = new ArrayList<Coordinates>();
    String map;
    
    /*
    if(rotate_90_degrees){
      horizontal_spacing_between_single_slot_dots = Math.round(horizontal_spacing_between_single_slot_dots/2);
      horizontal_spacing_between_full_slots = Math.round(horizontal_spacing_between_full_slots/2);
      vertical_spacing_between_single_slot_dots = Math.round(vertical_spacing_between_single_slot_dots*2);
      vertical_spacing_between_full_slots = Math.round(vertical_spacing_between_full_slots*2);
    }*/
    
    sentence = "This is test number 1";
    String new_sentence = add_indicators(sentence);
    print(sentence + '\n');
    Pair<String, List<Coordinates>> p = blabla(new_sentence);
    coordinates_of_dots_to_po9_for_this_paragraph = p.getValue();
    map  = p.getKey();
    
    print(map);
    
}

private boolean is_a_number(char character){
  try{
    Integer.parseInt(String.valueOf(character));
    return true;
  } catch(NumberFormatException ignored){
    return false;
  }
}

private boolean is_capitalized(char character){
  switch(String.valueOf(character)){
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

private String add_indicators(String word){
  boolean currently_number = false;
  boolean first_character = true;
  String result = "";
  for(char character:word.toCharArray()){
      
      if(is_a_number(character) &&  (!currently_number || first_character)){
        first_character = false;
        currently_number = true;
        result += "}";
      } else if(!is_a_number(character) && (currently_number || first_character)){
        first_character = false;
        currently_number = false;
        result += "{";
      }
     
      if(is_capitalized(character)){
        result += "/";
      }
      result += character;
  }
  return result;
}


private Pair<String, List<Coordinates>> blabla(String word){
  
    List<Coordinates> coordinates_of_all_po9able_dots = new ArrayList<Coordinates>();
    List<Coordinates> coordinates_of_dots_to_po9_for_this_paragraph = new ArrayList<Coordinates>();
    String map = "";
    List<Slot> slots = new ArrayList<Slot>();


    // Preparation 1: find the resolution of each slot
    int height_of_slot = vertical_spacing_between_single_slot_dots*2 + vertical_spacing_between_full_slots + 3;
    int width_of_slot = horizontal_spacing_between_single_slot_dots + horizontal_spacing_between_full_slots + 2;

    if(rotate_90_degrees){
      height_of_slot++;
    }
    // Preparation 2: find the resolution of our print
    int width_of_map = slots_per_line*width_of_slot;
    int height_of_map = lines*height_of_slot;
    
    
      
    // Preparation 3: find how many slots there can be
    int amount_of_slots = amount_of_slots_portrait(width_of_map, height_of_map, width_of_slot, height_of_slot);
      
    // out of range alert
    if(word.length()>amount_of_slots){
      println("Error: The slots available can't fit your paragraph as there's " + amount_of_slots + " slots available but your paragraph requires " + word.length() + ", which is higher by " + String.valueOf(word.length()-amount_of_slots + ".")
      + '\n' + "Tips: decrease the size of letters (currently " + height_of_slot + " x " + width_of_slot + ")."
      + '\n' + "      Increase slots per line (currently " + slots_per_line + ")."
      + '\n' + "      Increase amount of lines (currently " + lines + ").");
    } else {
    // Preparation 4: find all po9able coordinates in the space
      coordinates_of_all_po9able_dots = find_coords_of_all_po9able_dots_portrait(width_of_map, height_of_map, width_of_slot, height_of_slot, horizontal_spacing_between_single_slot_dots, vertical_spacing_between_single_slot_dots);

      // Preparation 5: apply corresponding coordinates to all slots
      slots = split_coords_between_ordered_slots_portrait(coordinates_of_all_po9able_dots, amount_of_slots, slots_per_line, lines);
      
      // Preparation 6: get the specific dots to po9
      for(int i=0; i<word.length(); i++){
        coordinates_of_dots_to_po9_for_this_paragraph = apply_this_letter_to_this_slot_portrait(i, String.valueOf(word.charAt(i)), slots, coordinates_of_dots_to_po9_for_this_paragraph);
      }
      
      if(rotate_90_degrees){ // flip just the result, not the action 
      
        for(int i=0; i<coordinates_of_dots_to_po9_for_this_paragraph.size(); i++){
         coordinates_of_dots_to_po9_for_this_paragraph.get(i).x = width_of_map - coordinates_of_dots_to_po9_for_this_paragraph.get(i).x;
        }
        
        for(int i=0; i<coordinates_of_all_po9able_dots.size(); i++){
          coordinates_of_all_po9able_dots.get(i).x = width_of_map - coordinates_of_all_po9able_dots.get(i).x;
        }
        
        for(Coordinates coordinate: coordinates_of_all_po9able_dots){
          coordinate.x = coordinate.x + coordinate.y;
          coordinate.y = coordinate.x - coordinate.y;
          coordinate.x = coordinate.x - coordinate.y;
        }
        
        for(Coordinates coordinate: coordinates_of_dots_to_po9_for_this_paragraph){
          coordinate.x = coordinate.x + coordinate.y;
          coordinate.y = coordinate.x - coordinate.y;
          coordinate.x = coordinate.x - coordinate.y;
        }
        
        map = print_map_portrait(coordinates_of_dots_to_po9_for_this_paragraph, height_of_map, width_of_map, coordinates_of_all_po9able_dots, horizontal_spacing_between_full_slots, vertical_spacing_between_full_slots); 

      } else {
        // Experiment: build a console-friendly map
        map = print_map_portrait(coordinates_of_dots_to_po9_for_this_paragraph, width_of_map, height_of_map, coordinates_of_all_po9able_dots, horizontal_spacing_between_full_slots, vertical_spacing_between_full_slots); 
      }
    }
    
    return new Pair<String, List<Coordinates>>(map, coordinates_of_dots_to_po9_for_this_paragraph);

}


private String print_map_portrait(List<Coordinates> coordinates_of_dots_to_po9_for_this_paragraph, int width_of_map, int height_of_map, List<Coordinates> coordinates_of_all_po9able_dots, int horizontal_spacing_between_full_slots, int vertical_spacing_between_full_slots){
  
    StringBuilder map_builder = new StringBuilder();
    
    // put a hat on it
    for(int i=0; i<width_of_map+1; i++){
      map_builder.append("-");
    }
    map_builder.append('\n');
    
    for(int i=0; i<height_of_map-vertical_spacing_between_full_slots; i++){
      
      // put a wall at the start of each line
      map_builder.append("| ");
      
      for(int j=0; j<width_of_map-horizontal_spacing_between_full_slots; j++){
        
        // If this location was requested to be po9ed a.k.a is in the po9_list then append "." or else just append " "
        boolean po9_it = false;
        boolean po9ble_dot = false;
        
        for(Coordinates dot: coordinates_of_all_po9able_dots){
          if(dot.x == j && dot.y == i){
            po9ble_dot = true;
            break;
          }
        }
        
        for(Coordinates dot: coordinates_of_dots_to_po9_for_this_paragraph){
          if(dot.x == j && dot.y == i){
            po9_it = true;
            break;
          }
        }
        
        if(po9ble_dot){
          if(po9_it){
            map_builder.append("o");
          } else {
            map_builder.append(" ");
          }
        }
        else {
          map_builder.append(" ");
        }
        
      }
      
      // put a wall at the end of each line
      map_builder.append(" |");
      
      // new line
      map_builder.append('\n');
    }
    
    // cover its butt
    for(int i=0; i<width_of_map+1; i++){
      map_builder.append("-");
    }
  
    return map_builder.toString();
}


private List<Coordinates> apply_this_letter_to_this_slot_portrait(int slottag, String letter, List<Slot> slots, List<Coordinates> coordinates_of_dots_to_po9_for_this_paragraph){

    Slot selected_slot = slots.get(slottag);
    Coordinates new_coordinates = new Coordinates();
  
    switch(letter){
      case "{": // Letter indicator
        new_coordinates.x = selected_slot.point4x;     new_coordinates.y = selected_slot.point4y;
        coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
        new_coordinates = new Coordinates();
        new_coordinates.x = selected_slot.point6x;     new_coordinates.y = selected_slot.point6y;
        coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
        break;
      case "}": // Number indicator
        new_coordinates.x = selected_slot.point2x;     new_coordinates.y = selected_slot.point2y;
        coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
        new_coordinates = new Coordinates();
        new_coordinates.x = selected_slot.point4x;     new_coordinates.y = selected_slot.point4y;
        coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
        new_coordinates = new Coordinates();
        new_coordinates.x = selected_slot.point5x;     new_coordinates.y = selected_slot.point5y;
        coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
        new_coordinates = new Coordinates();
        new_coordinates.x = selected_slot.point6x;     new_coordinates.y = selected_slot.point6y;
        coordinates_of_dots_to_po9_for_this_paragraph.add(new_coordinates);
        break;
      case "/": // Capitalization indicator
        new_coordinates.x = selected_slot.point6x;     new_coordinates.y = selected_slot.point6y;
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


private List<Slot> split_coords_between_ordered_slots_portrait(List<Coordinates> coordinates_of_all_po9able_dots, int amount_of_slots, int slots_per_line, int lines){
    List<Slot> slots = new ArrayList<Slot>();
    
    for(int i=0; i<amount_of_slots; i++){
      slots.add(new Slot());
    }
    
    for(int j=0; j<lines; j++){ // we iterate over every line (by just adding +j*slots_per_line down below we can jump to the slots in the next line)
      for(int i=0; i<slots_per_line; i++){ // we iterate over every Slot in that line
        
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


private int amount_of_slots_portrait(int width_of_map, int height_of_map, int width_of_slot, int height_of_slot){
    int amount_of_slots = 0;
    while(width_of_map>0){
      amount_of_slots ++;
      width_of_map -= width_of_slot;
    }
    int lines = 0;
    while(height_of_map>0){
      lines += 1;
      height_of_map -= height_of_slot;
    }
    
    amount_of_slots = amount_of_slots * lines;
    
    return amount_of_slots;
}


private List<Coordinates> find_coords_of_all_po9able_dots_portrait(int width_of_map, 
                                                                      int height_of_map, 
                                                                      int width_of_slot, 
                                                                      int height_of_slot, 
                                                                      int horizontal_spacing_between_single_slot_dots, 
                                                                      int vertical_spacing_between_single_slot_dots){
    List<Coordinates> coordinates_of_all_po9able_dots = new ArrayList<Coordinates>();
    
    for(int i=0; i<height_of_map; i++){
      for(int j=0; j<width_of_map; j++){
        
        // this is just looking for the dots, and getting their coordinates
    if(     (
              i%height_of_slot==0 
              || i%height_of_slot==vertical_spacing_between_single_slot_dots+1 
              || i%height_of_slot==(vertical_spacing_between_single_slot_dots+1)*2
            ) 
            && 
            (
              j%width_of_slot == 0 
              || j%width_of_slot == horizontal_spacing_between_single_slot_dots+1)
            ){
          
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


//                      * * * Main Part * * *                     //
void draw(){
}
