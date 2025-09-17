import processing.sound.*;
import java.io.*;
import java.util.*;

final String PATH = "Escape_The_Room2/graphics/";
final String EXTEND = ".png";


//Red text characters
final char RED_ONE = 34;
final char RED_U = 35;
final char RED_P = 36;
final char RED_COLON = 47;

final byte TEXT_OFFSET = 32;

final byte TILE_SIZE = 50;

final byte GO_SIZE = 24;
final byte MAX_LEVEL = 7;

//IDs for the background tiles
final byte BG_NONE = -8;
final byte BG_GROUND = 1;
final byte BG_COIN = 2;
final byte BG_EXIT = 3;
final byte BG_PILLAR = 4;
final byte BG_VENT = 5;
final byte BG_TELE = 6;

//IDs for moving objects
final byte OBJ_NONE = -1;
final byte OBJ_ROBOT = 1;
final byte OBJ_ROCKET = 2;
final byte OBJ_PLAT_VERT = 3;
final byte OBJ_PLAT_HORIZ = 4;
final byte OBJ_ONE_UP = 5;
final byte OBJ_PLUS_ONE = 6;

//Indices for referencing specific graphics
final byte INSIDE_GROUND = 32;
final byte INSIDE_PILLAR_TOP = 59;
final byte INSIDE_PILLAR_STEM = 60;
final byte OUTSIDE_GROUND = 65;
final byte OUTSIDE_PILLAR_STEM = 66;
final byte COIN_FRAME_ONE = 5;
final byte COIN_SCORE = 42;
final byte COIN_FRAME_TRIGGER = 15;
final byte MAX_COIN_FRAME = 2;

//Information for positioning and defining the bounding box for the goal
final byte GOAL_WIDTH = 25;
final byte GOAL_LEFT = 12;
final byte GOAL_RIGHT = GOAL_LEFT+GOAL_WIDTH;

//Information for the position of the arrow that shows up pointing to the goal
final byte ARROW_WIDTH = 50;
final byte ARROW_X_RIGHT = GOAL_RIGHT+10;
final byte ARROW_X_LEFT = GOAL_LEFT-ARROW_WIDTH-10;

//HUD string lengths
final byte BONUS_TEXT_LENGTH = 6;
final byte CURR_SCORE_TEXT_LENGTH = 12;
final byte HIGH_SCORE_TEXT_LENGTH = 11;
final byte LIVES_TEXT_LENGTH = 9;
final byte SCORE_BONUS_TEXT_LENGTH = 12;
final byte TIME_REMAIN_TEXT_LENGTH = 9;

//Information for the HUD text
final byte HUD_TEXT_SIZE = 8;
final byte HUD_TEXT_PADDING = HUD_TEXT_SIZE+3;
final short HUD_TEXT_POS = 55;

//Between-screen string lengths
final byte READY_TEXT_LENGTH = 6;
final byte GAME_OVER_TEXT_LENGTH = 9;

//Menu text information
final byte MENU_TEXT_LENGTH = 13;
final byte MENU_TEXT_SIZE = 24;
final short MENU_X_POS = 256;
final short MENU_Y_POS = 375;

final byte ENTER_TEXT_LENGTH = 11;
final short ENTER_X_POS = 268;
final short ENTER_Y_POS = 500;

final byte CUTSCENE_TEXT_LENGTH = 16;
final byte PAUSE_TEXT_LENGTH = 5;
final short PAUSE_X_POS = 340;
final short PAUSE_Y_POS = 250;

final byte QUESTION_MARK_TEXT_LENGTH = 1;

final byte ROUND_START_TEXT_LENGTH_LONG = 12;
final byte ROUND_START_TEXT_LENGTH_SHORT = 8;
final byte ROUND_START_TEXT_SIZE = 32;

final byte MODE_GAME_A = 0;
final byte MODE_GAME_B = 1;
final byte MODE_RESET_SCORE = 2;
final byte MODE_EXIT = 3;


final short WIDTH = 800;
final short HEIGHT = 600;

final short GO_MID_X = (short)((WIDTH - GAME_OVER_TEXT_LENGTH*GO_SIZE) >> 1);
final short GO_MID_Y = (short)((HEIGHT - GO_SIZE) >> 1);


final int TEXT_SIZE = 32;

final int SCREEN_WIDTH_TILES = WIDTH/TILE_SIZE;
final int SCREEN_HEIGHT_TILES = HEIGHT/TILE_SIZE;


final byte[] CUT_IDS = {OBJ_ROBOT, OBJ_ROCKET};



final short ROUND_START_TEXT_X_LONG = (short)((WIDTH-(ROUND_START_TEXT_LENGTH_LONG*ROUND_START_TEXT_SIZE))>>>1);
final short ROUND_START_TEXT_X_SHORT = (short)((WIDTH-(ROUND_START_TEXT_LENGTH_SHORT*ROUND_START_TEXT_SIZE))>>>1);

final short MIN_KEY[] = {0xF0, 0x9E, 0xBE};
final short MAX_KEY[] = {0xFF, 0xCD, 0xEC};

final short[] INTRO_INPUTS = {2177, 127, 1025, 127, 2303};
final short[] ENDING_INPUTS = {2177, 15, 4111, 170, 4111, 170, 4111, 170, 1279};
final short[] ATTRACT_MODE_INPUTS = {38, 2086, 6159, 2077, 6159, 2065, 6154, 2061, 8, 2053, 6155, 2087, 31, 1086, 7, 2139, 1034, 61, 4126, 153, 1031, 5141, 1050, 5137, 1078, 85, 1028, 5142, 1027, 79, 1052}; 

Graphics[] characters = new Graphics[67]; //0 = space (ASCII 32), 57 = Z (ASCII 90), 2 - 4 and 15 = red characters 1, U, P, : (TAKE UP ASCII 34 - 36 and 47)
Graphics[] rocketFrames = new Graphics[4];
Graphics[] playerFrames = new Graphics[11];
byte groundRef;
byte[] pillarRef = new byte[2];
File file;
File scanlines;
Scanner reader;
FileWriter writer;
SawOsc saw = new SawOsc(this);
SqrOsc sqr = new SqrOsc(this);
TextMod wrapper = new TextMod();
NonPlayerEnt[] objects = new NonPlayerEnt[7];
Player currPlayer = new Player();
LinkedList<CoinScoreText> scoreQueue = new LinkedList<CoinScoreText>();
CoinScoreText tempScoreText;



/*
Bit 1 of arrowPos contains the side the arrow appear on
2 contains the lock for the 'c' key
3 contains whether or not touching the goal is required
4 contains whether or not the level has been beaten
5 contains if the level inside a room or outside
6 contains if sawtooth sound should play
8 contains if sound is on or off
*/

boolean verticalKeysHeld = false;

int endPoint = 7;
byte frameCounter = 0;
byte levelCount = 0;
byte red = 0;
byte goalCount = 4;
byte keyInputs = 0;
byte oneUpFlash = 0;
byte enSpeed = 14;
byte soundSize = 25;
byte compNum = 0;
byte isSmoothed = 1;
byte mode = 0;
byte coinFrame = 0;
byte arrowXPos = ARROW_X_RIGHT;
byte arrowDirection = ARROW_WIDTH;

short titleTime = 0; //2048 seems to be a key lock for up and down; bits 9 and 10 seem to be used for the mode
short secondScore = 0;
short randomNum = 30242;
short gameOverTime = 201;
short titleLogoX = 0, titleLogoY = 1080; // reserve two bits for the fractional portion and use an offset for both
short attractMode = 0; //Contains the frame counter (from 0 to 1029) and if the game is in attract mode
byte[] coinCounter = {0};
byte[] arrowPos = {1}; 
byte[] nonRedColours = {0, 0};
byte[] soundPointers = {0, 0};//byte 0 is the square, byte 1 is the saw
byte[] soundTimers = {0, 0};
int[] surrPos = new int[3];
int[] surrY = new int[3];
byte[][] levelData = new byte[SCREEN_WIDTH_TILES][SCREEN_HEIGHT_TILES];//The data containing all non-moving elements in a level
short[][] soundDurations = {{0, 0, 0, 0, 0, 0}, {0, 0, 0, 0, 0, 0}}; 
short[][] frequencies = {{0, 0 , 0, 0 ,0 ,0}, {0, 0, 0, 0, 0, 0}};


//gameText features a greater than symbol that is used as an arrow to point to the current menu option
char[] score = {RED_ONE, RED_U, RED_P, RED_COLON, ' ', '0', '0', '0', '0', '0', '0', '0', '9', '9', '9', '9' , '9', '7', '5'};
char[] highScore = {'H','I', ':', ' ', '0', '0', '0', '0', '0', '0', '0', 0};
char[] highComp = {'0', '0', '0', '0', '0', '0', '0', 0};
char[] lives = {'L', 'I', 'V', 'E', 'S', ':', ' ', '0', '0', 0};
char[] bonus = {'B', 'O', 'N', 'U', 'S', ':', ' ', '0', '0', '0', '0', '0', 0};
char[] time = {'T', 'I', 'M', 'E', ':', ' ', '0', '0', '0', 0};
char[] stageStart = {'R', 'O', 'U', 'N', 'D', ':', ' ', '0', 0, 0, 0, 0};
char[] readyText = {'R', 'E', 'A', 'D', 'Y', '?', 0};
char[] gameOver = {'G', 'A', 'M', 'E', ' ', 'O', 'V', 'E', 'R', 0};
char[][] gameText = {{'>', 'G', 'A', 'M', 'E', ' ', 'A', 0, 0, 0, 0, 0, 0, 0}, 
                     {' ', 'G', 'A', 'M', 'E', ' ', 'B', 0, 0, 0, 0, 0, 0, 0}, 
                     {' ', 'D', 'E', 'L', 'E', 'T', 'E', ' ', 'S', 'C', 'O', 'R', 'E', 0},
                     {' ', 'L', 'E', 'A', 'V', 'E', 0, 0, 0, 0, 0, 0, 0, 0}};
char[] enterText = {'P', 'R', 'E', 'S', 'S', ' ', 'E', 'N', 'T', 'E', 'R', 0};
char[][] cutText = {{'C', 'O', 'N', 'G', 'R', 'A', 'T', 'U', 'L', 'A', 'T', 'I', 'O', 'N', 'S', '!', 0},
                    {'Y', 'O', 'U', ' ', 'E', 'S', 'C', 'A', 'P', 'E', 'D', '!', 0, 0, 0, 0},
                    {'U', 'H', ' ', 'O', 'H', '!', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}};
char[] pauseText = {'P', 'A', 'U', 'S', 'E', 0};
char[] bonusText = {'B', 'O', 'N', 'U', 'S', '!', 0};
char[] questionMark = {'?', 0};
char[] max = {'2', '5', '0'};
float vol = 0.25;

short roundStartTextX = 0;

void setup(){
  file = new File("Escape_The_Room2/score.bin");
  scanlines = new File("Escape_The_Room2/option.txt");
  try{
    reader = new Scanner(file);
    if(!file.exists()){
      file.createNewFile();
    }
    else{
      String tempScore = "";
      if(reader.hasNext()){
        tempScore = reader.next();
      }
      else{
        System.out.println("ERROR: NO SCORE");
        writer = new FileWriter(file, false);
        writer.write("0020000");
        tempScore = "0020000";
        writer.close();
      }
      for(byte i = 4; i < HIGH_SCORE_TEXT_LENGTH; i++)
        highScore[i] = highComp[i-4] = tempScore.charAt(i-4);
    }
    reader.close();
  }
  catch(Exception e){
    e.printStackTrace();
    System.exit(-1);
  }
  try{
    
    if(!scanlines.exists()){
      scanlines.createNewFile();
      writer = new FileWriter(scanlines, false);
      writer.write("SMOOTH=FALSE\nLINES=FALSE");
      writer.close();
      isSmoothed = 0;
    }
    else{
      reader = new Scanner(scanlines);
        if(!reader.hasNextLine()){
          writer = new FileWriter(scanlines, false);
          writer.write("SMOOTH=FALSE\nLINES=FALSE\nNEWCONT=TRUE\nVOLUME=0.25");
          writer.close();
          isSmoothed = 0;
        }
        else{
         String tempHold = reader.nextLine().toLowerCase();
         if(tempHold.matches("smooth=true"))
           isSmoothed = 1;
         else
            isSmoothed = 0;
          if(!reader.hasNextLine()){
            writer = new FileWriter(scanlines, false);
            writer.write("SMOOTH=FALSE\nLINES=FALSE\nNEWCONT=TRUE\nVOLUME=0.25");
            writer.close();
            isSmoothed = 0;
          }
          else{
            tempHold = reader.nextLine().toLowerCase();
            if(tempHold.matches("lines=true"))
              isSmoothed|=2;
            else
              isSmoothed&=1;
            if(!reader.hasNextLine()){
              writer = new FileWriter(scanlines, false);
              writer.write("SMOOTH=FALSE\nLINES=FALSE\nNEWCONT=TRUE\nVOLUME=0.25");
              writer.close();
              isSmoothed = 0;
            }
            else{
              tempHold = reader.nextLine().toLowerCase();
              if(tempHold.matches("newcont=false"))
                isSmoothed|=4;
              else
                isSmoothed&=3;
              if(!reader.hasNextLine()){
                writer = new FileWriter(scanlines, false);
                writer.write("SMOOTH=FALSE\nLINES=FALSE\nNEWCONT=TRUE\nVOLUME=0.25");
                writer.close();
                isSmoothed = 0;
              }
              else{
                 tempHold = reader.nextLine().toLowerCase(); 
                 if(tempHold.contains("volume=")){
                   String volumeContainer = "";
                   for(int i = 7; i < tempHold.length(); i++)
                     volumeContainer+=tempHold.charAt(i);
                    vol = Math.max(0, Math.min(Float.parseFloat(volumeContainer), 1));
                 }
              }
            }
          }
         reader.close();
        }
    }
  }
  catch(Exception e){
     e.printStackTrace();
     System.exit(-1);
  }

  size(800, 600);//For some reason, Processing does not like it when you pass in either variables or named constants into size
  noCursor();
  noSmooth();
  stroke(#000000);
  fill(#000000);
  saw.amp(vol);
  sqr.amp(vol);
  characters[' '-TEXT_OFFSET] = new Graphics(setImage((byte)8, (byte)8, (short)255, (short)174, (short)201), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['!'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/!"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[RED_ONE-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/Red/1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[RED_U-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/Red/U"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[RED_P-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/Red/P"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  for(int i = 0; i < 3; i++)
    characters[i+COIN_FRAME_ONE] = new Graphics(loadImage(PATH+"Background/coin"+char(i+49)+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters['('-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/openParen"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[')'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/closeParen"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[10] = characters[0];
  characters[11] = characters[0];
  characters[12] = new Graphics(loadImage(PATH+"Menu/sound1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['-'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/minus"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[14] = new Graphics(loadImage(PATH+"Menu/sound-1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[RED_COLON-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/Red/colon"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  for(int i = 0; i < 10; i++)
    characters[i+'0'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/"+char(i+'0')+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[':'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/colon"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[27] = new Graphics(loadImage(PATH+"Objects/1UP"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[28] = new Graphics(loadImage(PATH+"Objects/enGround"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[29] = new Graphics(loadImage(PATH+"Objects/platform"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['>'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/greater"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['?'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/question"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[INSIDE_GROUND] = new Graphics(loadImage(PATH+"Background/ground"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters['A'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/A"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['B'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/B"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['C'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/C"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['D'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/D"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['E'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/E"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[38] = new Graphics(loadImage(PATH+"Background/goalPanel"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters['G'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/G"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['H'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/H"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['I'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/I"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[COIN_SCORE] = new Graphics(loadImage(PATH+"Background/points"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['K'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/K"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['L'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/L"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['M'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/M"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['N'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/N"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['O'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/O"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['P'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/P"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[49] = new Graphics(loadImage(PATH+"Menu/title"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['R'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/R"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['S'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/S"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['T'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/T"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['U'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/U"+EXTEND),MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['V'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/V"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[55] = new Graphics(loadImage(PATH+"Background/arrow1"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[56] = new Graphics(loadImage(PATH+"Objects/plus1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['Y'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/Y"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters['Z'-TEXT_OFFSET] = new Graphics(loadImage(PATH+"Text/White/Z"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[INSIDE_PILLAR_TOP] = new Graphics(loadImage(PATH+"Background/support1"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[INSIDE_PILLAR_STEM] = new Graphics(loadImage(PATH+"Background/support2"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[61] = new Graphics(loadImage(PATH+"Background/vent11"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[62] = new Graphics(loadImage(PATH+"Background/vent1-1"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[63] = new Graphics(loadImage(PATH+"Background/vent-11"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[64] = new Graphics(loadImage(PATH+"Background/vent-1-1"+EXTEND), MIN_KEY, MAX_KEY, false, (isSmoothed & 1) == 1);
  characters[OUTSIDE_GROUND] = new Graphics(loadImage(PATH+"Background/grass"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  characters[OUTSIDE_PILLAR_STEM] = new Graphics(loadImage(PATH+"Background/bark"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  
  for(int i = 0; i < 3; i++)
    playerFrames[i] = new Graphics(loadImage(PATH+"Objects/P"+char(i+49)+"1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  for(int i = 0; i < 3; i++)
    playerFrames[i+3] = new Graphics(loadImage(PATH+"Objects/P"+char(i+49)+"-1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  playerFrames[6] = new Graphics(loadImage(PATH+"Objects/PFall1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  playerFrames[7] = new Graphics(loadImage(PATH+"Objects/PFall-1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  playerFrames[8] = new Graphics(loadImage(PATH+"Objects/PJump1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  playerFrames[9] = new Graphics(loadImage(PATH+"Objects/PJump-1"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  playerFrames[10] = new Graphics(loadImage(PATH+"Objects/PDeath"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  
  rocketFrames[0] = new Graphics(loadImage(PATH+"Objects/enAir11"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);
  rocketFrames[1] = new Graphics(loadImage(PATH+"Objects/enAir-11"+EXTEND), MIN_KEY, MAX_KEY, true, (isSmoothed & 1) == 1);

  for(int i = 0; i < 16; i++)
     for(int j = 0; j < 12; j++)
       levelData[i][j] = BG_NONE;
  currPlayer = new Player();
  for(int i = 0; i < 7; i++)
     objects[i] = new NonPlayerEnt();
  groundRef = INSIDE_GROUND;
  pillarRef[0] = INSIDE_PILLAR_TOP;
  pillarRef[1] = INSIDE_PILLAR_STEM;
}



//Text drawing will have a function that takes in an array of characters as its input, subtracts 32 from every character's value, and uses that to select a character from the array

void draw(){
  if((keyInputs & 64) == 64){
    reader.close();
    System.exit(0);
  }

  randomNum = LSFRShift(randomNum);
   frameCounter++;
   if((frameCounter & 63) > 60){
     frameCounter&=-64;
     if((frameCounter & 64) == 0){
       if(!wrapper.digitEqual(time, 6, (byte)0, (byte)3))
         wrapper.decrementCounter(time, (byte)1, 6, (byte)3);
       if(!wrapper.digitEqual(bonus, 7, (byte)0, (byte)5))
         wrapper.decrementCounter(bonus, (byte)34, 7, (byte)5);
     }
   }

  if(wrapper.digitEqual(lives, 7, (byte)0, (byte)2) || (arrowPos[0] & 16) == 16){
    frameCounter&=-65;
    if(wrapper.digitEqual(lives, 7, (byte)0, (byte)2))
      isSmoothed+=8;
      if((isSmoothed & 24) == 0){
         isSmoothed&=-25; 
      }
  }
   if(red != 0 && red == nonRedColours[0] && nonRedColours[0] == nonRedColours[1]){
     red-=5;
     nonRedColours[0]-=5;
     nonRedColours[1]-=5;
   }
   background((red & 255), (nonRedColours[0] & 255), (nonRedColours[1] & 255));
   if((keyInputs & -128) == -128){
     if((arrowPos[0] & 2) == 0){
       arrowPos[0]|=2;
       arrowPos[0] = (byte)(((arrowPos[0] & -128) == 0) ? arrowPos[0] | -128 : arrowPos[0] & 127);
       saw.stop();
       sqr.stop();
     }
     soundSize = (byte)((soundSize & -32) | 26);
   }
   else{
     arrowPos[0]&=-3;
     soundSize = (byte)((soundSize & -32) | 31);
   }
   if(!wrapper.digitEqual(lives, 7, (byte)0, (byte)2) || (attractMode & 256) == 256){

     if((attractMode & 256) == 256){
       if((arrowPos[0] & 16) == 0){
         textDraw(gameOver, GAME_OVER_TEXT_LENGTH, GO_MID_X, (short)250, GO_SIZE);
         for(byte i = 5; i < 12; i++)
           score[i] = '0';
         for(byte i = 6; i < 9; i++)
           time[i] = '9';
         for(byte i = 7; i < 12; i++)
           bonus[i] = '0';
         secondScore = 0;
         attractMode = autoPlayer(ATTRACT_MODE_INPUTS, (byte)30, attractMode);
       }
       else{
          rect(700, 350, 100, 50);
          rect(650, 400, 150, 50);
          rect(600, 450, 200, 175);
          attractMode = autoPlayer(INTRO_INPUTS, (byte)5, attractMode, objects, (byte)2, CUT_IDS, (byte)2);
          if(((attractMode >> 9) & 127) == 1)
             textDraw(questionMark, QUESTION_MARK_TEXT_LENGTH, (short)370, (short)480, (byte)8);
          else if(((attractMode >> 9) & 127) > 3 || (((attractMode >> 9) & 127) > 2) && (attractMode & 255) <= 63)
            textDraw(cutText[2], (byte)6, (short)360, (short)480, (byte)8);
       }
       if(keyPressed && key == '\n'){
         gameOverTime = -256;
         attractMode = 16128;
         red = 0;
         nonRedColours[0] = nonRedColours[1] = 0;
       }
     }
     else{
       for(byte i = 0; i < 7; i++){
         if(score[i+5] != highScore[i+4]){
           if(score[i+5] > highScore[i+4])
              for(byte j = 5; j < 12; j++)
                 highScore[j-1] = score[j];
             break;
         }
       }
       switch(levelCount){
         case MAX_LEVEL:
           attractMode = autoPlayer(ENDING_INPUTS, (byte)8, attractMode, objects, (byte)2, CUT_IDS, (byte)6);
           textDraw(cutText[0], CUTSCENE_TEXT_LENGTH, (short)272, (short)128, (byte)16);
           if(((attractMode >> 9) & 127) >= 1){
             textDraw(cutText[1], (byte)12, (short)304, (short)147, (byte)16);
             if(((attractMode >> 9) & 127) >= 7)
               textDraw(cutText[2], (byte)6, (short)387, (short)492, (byte)8);
           }
           break;
         case 0:
           rect(700, 350, 100, 50);
           rect(650, 400, 150, 50);
           rect(600, 450, 200, 175);
           attractMode = autoPlayer(INTRO_INPUTS, (byte)5, attractMode, objects, (byte)2, CUT_IDS, (byte)2);
           if(((attractMode >> 9) & 127) == 1)
              textDraw(questionMark, QUESTION_MARK_TEXT_LENGTH, (short)370, (short)480, (byte)8);
           else if(((attractMode >> 9) & 127) > 3 || (((attractMode >> 9) & 127) > 2) && (attractMode & 255) <= 63)
               textDraw(cutText[2], (byte)6, (short)360, (short)480, (byte)8);
           break;
       }
     }

     if(((gameOverTime >> 9) & 255) >= 127){
       if((oneUpFlash & 63) <= 30){
         score[0] = RED_ONE;
         score[1] = RED_U;
         score[2] = RED_P;
         score[3] = RED_COLON;
       }
       else
          score[0] = score[1] = score[2] = score[3] = ' ';
       oneUpFlash = (byte)(((oneUpFlash & 63) < 60) ? oneUpFlash+1 : (oneUpFlash & -64));


       if((keyInputs & 32) == 32){
         if((frameCounter & -128) == 0 && (gameOverTime & 256) == 0 && (arrowPos[0] & 16) == 0){
            frameCounter = (byte)(((frameCounter & 64) == 0) ? frameCounter | -64 : (frameCounter & -65) | -128);
            initPauseSound();
         }
       }
       else{
         frameCounter&=127;
         gameOverTime&=-257;
       }
       if((arrowPos[0] & 16) == 0){
         textDraw(score, CURR_SCORE_TEXT_LENGTH, HUD_TEXT_POS, HUD_TEXT_POS, HUD_TEXT_SIZE);
         textDraw(lives, LIVES_TEXT_LENGTH, HUD_TEXT_POS, (short)(HUD_TEXT_POS+HUD_TEXT_PADDING), HUD_TEXT_SIZE);
         textDraw(highScore, HIGH_SCORE_TEXT_LENGTH, HUD_TEXT_POS, (short)(HUD_TEXT_POS+HUD_TEXT_PADDING*2), HUD_TEXT_SIZE);
         textDraw(bonus, SCORE_BONUS_TEXT_LENGTH, HUD_TEXT_POS, (short)(HUD_TEXT_POS+HUD_TEXT_PADDING*3), HUD_TEXT_SIZE);
         textDraw(time, TIME_REMAIN_TEXT_LENGTH, HUD_TEXT_POS, (short)(HUD_TEXT_POS+HUD_TEXT_PADDING*4), HUD_TEXT_SIZE);
         
         textDraw(bonusText, BONUS_TEXT_LENGTH, (short)256, (short)248, (byte)48);
       }
       if((frameCounter & 64) == 0){
         if(wrapper.digitEqual(time, 6, (byte)0, (byte)3) && (arrowPos[0] & 16) == 0){
           if((currPlayer.returnState() & 1) == 0)
             currPlayer.setState((byte)1);
             time[6] = time[7] = time[8] = '0';
         }
        
        //Main part of game loop
        drawBack((byte)(frameCounter & 63), currPlayer, wrapper, levelData, coinCounter, goalCount, score, arrowPos, sqr, soundDurations, frequencies, soundPointers, soundTimers);

        for(int i = endPoint-1; i >= 0; i--){
           switch(objects[i].returnID()){
             case OBJ_ROBOT:
               objects[i].robot(currPlayer, characters[28], arrowPos[0]);
               break;
             case OBJ_ROCKET:
               objects[i].rocket(currPlayer, rocketFrames, arrowPos[0]);
               break;
             case OBJ_PLAT_HORIZ:
               objects[i].horizPlat(currPlayer, characters[29]);
               break;
             case OBJ_PLAT_VERT:
               objects[i].vertPlat(currPlayer, characters[29]);
               break;
             case OBJ_ONE_UP:
               objects[i].oneUp(wrapper, currPlayer, characters[27], lives, (byte)(7), (2));
               break;
             case OBJ_PLUS_ONE:
               endPoint = objects[i].oneUpText(characters[56], endPoint, (byte)i);
               break;
           }
         }
         for(int i = 0; i < scoreQueue.size(); i++){
           tempScoreText = scoreQueue.removeFirst();
           tempScoreText.raise(characters[COIN_SCORE]);
           if(!tempScoreText.shouldDelete())
             scoreQueue.add(tempScoreText);
         }
         currPlayer.controlPlayer(wrapper, playerFrames, keyInputs, lives, (byte)2, (byte)0, 7, saw, soundDurations[1], frequencies[1], soundPointers, soundTimers, arrowPos, time, max);
         drawGround(levelData);
          if((arrowPos[0] & 4) == 0){
            if(goalCount > 0 && coinCounter[0] >= goalCount && (gameOverTime & 255) < 127)
              gameOverTime++;
            else if(currPlayer.returnX() > WIDTH || (gameOverTime & 255) >= 127)
              arrowPos[0]|=8;
          }
          if((attractMode & 255) == 0 && ((((attractMode >> 9) & 255) >= 30) || (((attractMode >> 9) & 255) >= 4 && (arrowPos[0] & 16) == 16))){
            arrowPos[0]&=-9;
            attractMode = 0;
            keyInputs = 0;
            gameOverTime|=-257;
            for(int i = 0; i < 6; i++){
              soundDurations[0][i] = 0;
              soundDurations[1][i] = 0;
            }
          }
          if((arrowPos[0] & 8) == 8){

            levelCount++;
          if(levelCount > MAX_LEVEL || ((isSmoothed & 4) == 4 && levelCount > 5)){
            levelCount = 1;
            enSpeed = 23;
          }
          

          gameOverTime = 0;
          if((attractMode & 256) == 256){
             attractMode = 0;
             gameOverTime = -1;
          }
          if(isTooBig(score, (byte)7, 5, 9990000))
             for(int s = 5; s < 12; s++){
               score[s] = score[s+7];
             }
           else{
             int ten = 100;
             for(byte i = 2; i >= 0; i--){
               wrapper.incrementCounter(score, (byte)(((4-i) << 4) | (bonus[7+i]-48)), 0, (byte)12);
               secondScore+=((bonus[7+i]-48)*ten);
               ten*=10;
             }
           }
          arrowPos[0]&=-126;
          sqr.stop();
          saw.stop();
          arrowPos[0]&=-97;
          keyInputs = 0;
          zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
          coinCounter[0] = 0;
          if(levelCount != 4)
            for(byte i = 0; i < BONUS_TEXT_LENGTH; i++)
              bonusText[i] = 0;
          else{
            bonusText[0] = 'B';
            bonusText[1] = 'O';
            bonusText[2] = 'N';
            bonusText[3] = 'U';
            bonusText[4] = 'S';
            bonusText[5] = '!';
          }
          switch(levelCount){
            case 1:
              roundStartTextX = ROUND_START_TEXT_X_SHORT;
              stageStart[7] = '1';
              for(byte i = 8; i < stageStart.length; i++)
                stageStart[i] = 0;
              loadLevel1(enSpeed);
              break;
            case 2:
              roundStartTextX = ROUND_START_TEXT_X_SHORT;
              stageStart[7] = '2';
              for(byte i = 8; i < stageStart.length; i++)
                stageStart[i] = 0;
                loadLevel2(enSpeed);
              break;
            case 3:
              roundStartTextX = ROUND_START_TEXT_X_SHORT;
              stageStart[7] = '3';
              for(byte i = 8; i < stageStart.length; i++)
                stageStart[i] = 0;
              loadLevel3(enSpeed);
              break;
            case 4:
              roundStartTextX = ROUND_START_TEXT_X_LONG;
              stageStart[7] = 'B';
              stageStart[8] = 'O';
              stageStart[9] = 'N';
              stageStart[10] = 'U';
              stageStart[11] = 'S';
              loadLevel4();
              break;
            case 5:
              roundStartTextX = ROUND_START_TEXT_X_SHORT;
              stageStart[7] = '4';
              for(byte i = 8; i < stageStart.length; i++)
                stageStart[i] = 0;
              loadLevel5(enSpeed);
              break;
            case 6:
              roundStartTextX = ROUND_START_TEXT_X_SHORT;
              stageStart[7] = '5';
              for(byte i = 8; i < stageStart.length; i++)
                stageStart[i] = 0;
                loadLevel7(enSpeed);
              break;
            case MAX_LEVEL:
              roundStartTextX = ROUND_START_TEXT_X_LONG;
              gameOverTime|=65024;
              stageStart[7] = 'B';
              stageStart[8] = 'R';
              stageStart[9] = 'E';
              stageStart[10] = 'A';
              stageStart[11] = 'K';
              loadLevel6();
              break;
            default:
              roundStartTextX = ROUND_START_TEXT_X_SHORT;
              levelCount = 1;
              loadLevel1(enSpeed);
              stageStart[7] = '1';
              for(byte i = 8; i < stageStart.length; i++)
                stageStart[i] = 0;
              break;
          }
          if((arrowPos[0] & 16) == 0){
            currPlayer.setX(100);
          }
          else{
            currPlayer.setX(-150);
          }
          currPlayer.setY((short)(500));
          currPlayer.setState((byte)(0));
          currPlayer.setSpeed((byte)0);
          currPlayer.setYSpeed((byte)(0));
         }
       }
       else{
         saw.stop();
          drawBack((byte)(frameCounter & 63), currPlayer, wrapper, levelData, coinCounter, goalCount, score, arrowPos, sqr, soundDurations, frequencies, soundPointers, soundTimers);
          if((frameCounter & 63) >= 0 && (frameCounter & 63) <= 30)
            textDraw(pauseText, PAUSE_TEXT_LENGTH, PAUSE_X_POS, PAUSE_Y_POS, MENU_TEXT_SIZE);
       }
       drawGround(levelData);
       if((attractMode & 256) == 0){
         oscPlay(saw, soundTimers, soundPointers, frequencies, soundDurations, arrowPos, (byte)1, (byte)32, (byte)6);
         oscPlay(sqr, soundTimers, soundPointers, frequencies, soundDurations, arrowPos, (byte)0, (byte)64, (byte)6);
       }
       if(secondScore >= 20000){
         initPauseSound();
         short ten = 1;
         secondScore = 0;
         for(byte i = 11; i > 7; i--){
           secondScore+=(score[i]-48)*ten;
           ten*=10;
         }
         if((score[7] & 1) == 1)
           secondScore+=10000;
         wrapper.lockInc(lives, (byte)1, 7, (byte)2);
       }
     }
     else{
       for(int i = 0; i < 6; i++){
         soundDurations[0][i] = 0;
         soundDurations[1][i] = 0;
       }
       gameOverTime+=512;
       titleTime = 0;
       textDraw(stageStart, ROUND_START_TEXT_LENGTH_LONG, roundStartTextX, (short)252, (byte)32);
       textDraw(readyText, READY_TEXT_LENGTH, (short)(304), (short)(300), (byte)32);
       if((keyInputs & 32) == 32 && (gameOverTime & 256) == 0){
         gameOverTime = -256;
       }
       if(enSpeed == 14){
         max[1] = '5';
         bonus[7] = '1';
         bonus[8] = '0';
       }
       else{
         max[1] = '0'; 
         bonus[7] = '0';
         bonus[8] = '5';
       }
       for(byte i = 9; i < SCORE_BONUS_TEXT_LENGTH; i++)
         bonus[i] = '0';
       time[6] = max[0];
       time[7] = max[1];
       time[8] = max[2];
     }
     
   }
   else{
    //Writes high score to a file
     for(byte i = 0; i < 7; i++){
       compNum = 0;
       if(highComp[i] != highScore[i+4]){
         if(highComp[i] < highScore[i+4])
           compNum = -1;
         else
           compNum = 1;
         break;
       }
     }
     if(compNum <= -1){
       try{
         String tempString = "";
         writer = new FileWriter(file, false);
         for(byte i = 0; i < 8; i ++){
           tempString+=highScore[i+4];
           highComp[i] = highScore[i+4];
         }
         writer.write(tempString);
         writer.close();
       }
       catch(Exception e){
         e.printStackTrace();
         System.exit(-1);
       }
     }
     //Game over and title screen
     if((gameOverTime & 255) <= 200){
       for(int i = 0; i < 6; i++){
         soundDurations[0][i] = 0;
         soundDurations[1][i] = 0;
       }
       titleLogoY = 1080;
       titleLogoX = 0;
       textDraw(gameOver, GAME_OVER_TEXT_LENGTH, GO_MID_X, GO_MID_Y, GO_SIZE);
       gameOverTime++;
       if((keyInputs & 32) == 32){
         gameOverTime = 457;
       }
     }
     else{
       characters[49].draw((titleLogoX >> 2)-477, (titleLogoY >> 2)-70, 354, 58);
       if(titleLogoX < 2808 || (titleTime & 511) >= 300){
         titleLogoX+=7;
         if(titleLogoX >= 976 && (titleTime & 511) < 300){
           if((keyInputs & 32) == 32){
             if((gameOverTime & 256) == 0){
               titleLogoX = 2808;
               titleLogoY = 1080;
               gameOverTime = 457;
             }
             
           }
           else
             gameOverTime&=-257;
         }
       }
       else{
         if(titleLogoY >= 1080)
           titleTime++;
         
       }
       if(titleLogoX > 5308){
         if((soundSize & -64) == -64)
           soundSize&=63;
         soundSize+=64; //Keeps track of how many cycles of the logo there have been before going to the attract mode
         titleTime&=-512;
         titleLogoY = 0;
         titleLogoX = 2808;
       }
       if(titleLogoY < 1080)
         titleLogoY+=7;
       if(titleLogoX >= 2808){
         soundSize = (byte)(((arrowPos[0] & -128) == 0) ? (soundSize & -33) : ((soundSize & -33) | 32));
         characters[12+((soundSize >> 4) & 2)].draw(100+(5*(soundSize >> 5) & 1), 500+(5*(soundSize >> 5) & 1), soundSize & 31, soundSize & 31);
         //Triggers the attract mode
         if(((soundSize >> 6) & 3) > 2){
           levelCount = 0;
           red = 0;
           titleLogoX = 0;
           titleLogoY = 1080;
           titleTime = 0;
           soundSize&=63;
           attractMode = 0;
           currPlayer.setXSpeed((byte)(0));
           if((isSmoothed & 24) == 8 || (isSmoothed & 4) == 4){
             currPlayer.setX((short)(100));
             attractMode = (short)(256 | (ATTRACT_MODE_INPUTS[0] & 255));
             loadLevel1((byte)14);
           }
           else{
             currPlayer.setX(-150);
             attractMode = (short)(256 | (INTRO_INPUTS[0] & 255));
             arrowPos[0]&=-128;
             loadLevel0(); 
           }
           currPlayer.setY((short)(500));
           currPlayer.setYSpeed((byte)(0));
           currPlayer.setState((byte)(0));
           for(byte i = 0; i < BONUS_TEXT_LENGTH; i++)
             bonusText[i] = 0;
           gameOverTime = -512;
         }
         for(byte i = 0; i < 4; i++){
           gameText[i][0] = (i == mode) ? '>' : ' ';
           textDraw(gameText[i], MENU_TEXT_LENGTH, MENU_X_POS, (short)(MENU_Y_POS+(MENU_TEXT_SIZE+1)*i), MENU_TEXT_SIZE);
         }
         if(frameCounter >= 0 && frameCounter <= 30)
           textDraw(enterText, ENTER_TEXT_LENGTH, ENTER_X_POS, ENTER_Y_POS, MENU_TEXT_SIZE);
         if((keyInputs & 3) != 0){
           if(!verticalKeysHeld){
             if((keyInputs & 3) == 1)
               mode = (byte)((mode-1) & 3);
             else if((keyInputs & 3) == 2)
               mode = (byte)((mode+1) & 3);
           }
           verticalKeysHeld = true;
         }
         else
           verticalKeysHeld = false;
         if((keyInputs & 32) == 32){
           if((gameOverTime & 256) == 0){
             switch(mode){
               case MODE_GAME_A:
                 enSpeed = 14;
                 oneUpFlash|=64;
                 initializeGame();
                 break;
                 
               case MODE_GAME_B:
                 enSpeed = 23;
                 oneUpFlash&=-65;
                 initializeGame();
                 break;
                 
               case MODE_RESET_SCORE:
                 gameOverTime = 457;
                 red = -1;
                 nonRedColours[0] = -1;
                 nonRedColours[1] = -1;
                 try{
                   writer = new FileWriter(file, false);
                   writer.write("0020000");
                   writer.close();
                 }
                 catch(Exception e){
                   e.printStackTrace();
                   System.exit(-1);
                 }
                 highScore[4] = highScore[5] = highComp[0] = highComp[1] =  '0';
                 highScore[6] = highComp[3] = '2';
                 for(byte i = 7; i < HIGH_SCORE_TEXT_LENGTH; i++)
                   highScore[i] = highComp[i-4] = '0';
                 break;
                 
               case MODE_EXIT:
                 System.exit(0);
                 break;
                 

             }
           }
         }
         else
           gameOverTime&=-257;
       }
     }
   }
   if((isSmoothed & 1) == 1){
     loadPixels();
     for(int i = 0; i < 800; i++){
       for(int j = 0; j < 600; j++){
         int loc = i+j*800;
         short blue = (short)((pixels[loc] & 0xFF)*13);
         short red2 = (short)(((pixels[loc] >> 0x10) & 0xFF)*13);
         short green = (short)(((pixels[loc] >> 0x08) & 0xFF)*13);
         if((isSmoothed & 2) == 2 && j%5 == 0){
           red2 = green = blue = 0;
         }
         else{
           surrPos[0] = Math.min(Math.max(i-1+j*800, 0), 479999); 
           surrPos[1] = Math.min(Math.max(i+(j-1)*800, 0), 479999);
           surrPos[2] = Math.min(Math.max(i+1+j*800, 0), 479999); 
           surrY[0] = j;
           surrY[1] = j-1;
           surrY[2] = j;
           for(int s = 0; s < surrPos.length; s++){
             if((isSmoothed & 2) == 0 || (surrY[s] & 7) > 0){
                red2+=((pixels[surrPos[s]] >> 0x10) & 0xFF)*17;
                blue+=((pixels[surrPos[s]]) & 0xFF)*17;
                 green+=(((pixels[surrPos[s]]) >> 0x08) & 0xFF)*17;
             }
             else{
                red2+=((pixels[loc] >> 0x10) & 0xFF)*17;
                blue+=(pixels[loc] & 0xFF)*17;
                green+=((pixels[loc] >> 0x08) & 0xFF)*17;
             }
           }
           blue = (short)((blue >> 6) & 255);
           red2 = (short)((red2 >> 6) & 255);
           green = (short)((green >> 6) & 255);
         }
         pixels[loc] = color(red2, green, blue);
       }
     }
     updatePixels();
     pixels = null;

   }
   if(isSmoothed == 2){
     for(int i = 0; i < 600; i+=7)
       line(0, i, 800, i);
   }
}

short autoPlayer(short[] inputs, byte inputNum, short tracker){
  keyInputs = (byte)((inputs[(tracker >> 9) & 255] >> 8) & 255);
  tracker--;
  if((tracker & 255) == 0 && ((tracker >> 9) & 255) < inputNum){
    tracker+=512;
    tracker|=(inputs[(tracker >> 9) & 255] & 255);
  }
  return tracker;
}

short autoPlayer(short[] inputs, byte inputNum, short tracker, NonPlayerEnt[] objects, byte numOfNonPlayer, byte[] newId, byte triggerIndex){
  keyInputs = (byte)((inputs[(tracker >> 9) & 255] >> 8) & 255);
  tracker--;
  if((tracker & 255) == 0 && ((tracker >> 9) & 255) < inputNum){
    tracker+=512;
    tracker|=(inputs[(tracker >> 9) & 255] & 255);
  }
  if(((tracker >> 9) & 127) == triggerIndex)
    for(byte i = 0; i < numOfNonPlayer; i++)
      objects[i].setID(newId[i]);
  return tracker;
}

void loadLevel0(){
  keyInputs = 0;
  arrowPos[0]|=16;
  groundRef = OUTSIDE_GROUND;
  pillarRef[0] = OUTSIDE_GROUND;
  pillarRef[1] = OUTSIDE_PILLAR_STEM;
  zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
  if((attractMode & 256) == 0)
    attractMode = (short)(INTRO_INPUTS[0] & 255);
  bonus[7] = '0';
  bonus[8] = '0';
  time[6] = time[7] = time[8] = '9';
  placeTile(12, 8, BG_GROUND, levelData);
  placeRect(13, 7, 3, 4, BG_GROUND, levelData);
  placeHoriz(14, 6, 2, BG_GROUND, levelData);
  placeHoriz(5, 8, 3, BG_GROUND, levelData);
  placeTile(6, 7, BG_GROUND, levelData);
  placeTile(6, 8, BG_PILLAR, levelData);
  placeHoriz(9, 3, 3, BG_GROUND, levelData);
  placeTile(10, 2, BG_GROUND, levelData);
  placeTile(10, 3, BG_PILLAR, levelData);
  placeHoriz(2, 5, 3, BG_GROUND, levelData);
  placeTile(3, 4, BG_GROUND, levelData);
  placeTile(3, 5, BG_PILLAR, levelData);
  placeTile(12, 10, BG_TELE, levelData);
  objects[0].setProperties(OBJ_NONE, (short)-150, (short)525, (byte)2, (short)-150, (short)(800));
  objects[1].setProperties(OBJ_NONE, (short)-150, (short)500, (byte)2, (short)-150, (short)(800));
  for(byte i = 2; i < 7; i++)
    objects[i].setProperties();
}

void loadLevel1(byte enemySpeed){
  arrowPos[0] = (byte)((arrowPos[0] & -22) | 5);
  groundRef = INSIDE_GROUND;
  pillarRef[0] = INSIDE_PILLAR_TOP;
  pillarRef[1] = INSIDE_PILLAR_STEM;
  zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
  goalCount = 5;
  endPoint = 3;
  placeTile(8, 10, BG_GROUND, levelData); 
  placeHoriz(9, 10, 3, BG_COIN, levelData);
  placeTile(9, 9, BG_GROUND, levelData); 
  placeHoriz(10, 8, 2, BG_GROUND, levelData);
  placeHoriz(6, 6, 3, BG_GROUND, levelData);
  placeTile(11, 6, BG_GROUND, levelData);
  placeTile(5, 7, BG_GROUND, levelData); 
  placeTile(5, 6, BG_COIN, levelData);
  placeTile(3, 7, BG_GROUND, levelData); 
  placeTile(3, 6, BG_COIN, levelData);
  placeHoriz(1, 6, 2, BG_GROUND, levelData);
  placeTile(11, 7, BG_PILLAR, levelData); 
  placeTile(11, 9, BG_PILLAR, levelData); 
  placeTile(7, 7, BG_PILLAR, levelData); 
  placeTile(5, 8, BG_PILLAR, levelData); 
  placeTile(3, 8, BG_PILLAR, levelData); 
  placeTile(11, 4, BG_VENT, levelData); 
  placeTile(1, 5, BG_EXIT, levelData); 
  objects[0].setProperties(OBJ_ROBOT, (short)300, (short)525, (byte)(enemySpeed & 3), (short)150, (short)400);
  objects[1].setProperties(OBJ_ROCKET, (short)200,(short)225, (byte)((enemySpeed >> 2) & 7), (short)175,(short)300);
  objects[2].setProperties(OBJ_PLAT_VERT, (short)700, (short)400, (byte)2, (short)300, (short)575);
  for(byte i = 3; i < 7; i++)
    objects[i].setProperties();
}
void loadLevel2(byte enemySpeed){
    arrowPos[0] = (byte)((arrowPos[0] & -22) | 5);
    groundRef = INSIDE_GROUND;
    pillarRef[0] = INSIDE_PILLAR_TOP;
    pillarRef[1] = INSIDE_PILLAR_STEM;
    zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
    goalCount = 7;
    endPoint = 4;
    if(randomNum > 0 && (oneUpFlash & 64) == 64)
      endPoint++;
    placeTile(1, 10, BG_EXIT, levelData);
    placeHoriz(4, 10, 9, BG_GROUND, levelData);
    placeHoriz(9, 9, 4, BG_GROUND, levelData);
    placeHoriz(10, 8, 3, BG_GROUND, levelData);
    placeHoriz(1, 6, 3, BG_GROUND, levelData);
    placeHoriz(1, 5, 3, BG_COIN, levelData);
    placeHoriz(11, 7, 2, BG_COIN, levelData);
    placeHoriz(11, 7, 2, BG_COIN, levelData);
    placeHoriz(13, 10, 2, BG_COIN, levelData);
    placeTile(3, 7, BG_PILLAR, levelData);
    placeTile(4, 4, BG_VENT, levelData);
    placeTile(10, 4, BG_VENT, levelData);
    objects[0].setProperties(OBJ_ROBOT, (short)50, (short)275, (byte)(enemySpeed & 3), (short)50, (short)150);
    objects[1].setProperties(OBJ_ROBOT, (short)250, (short)475, (byte)(enemySpeed & 3), (short)200, (short)400);
    objects[2].setProperties(OBJ_PLAT_VERT, (short)700,(short)450, (byte)2, (short)400, (short)575);
    objects[3].setProperties(OBJ_PLAT_HORIZ, (short)300,(short)325,(byte)2, (short)250, (short)450);
    objects[4].setProperties(OBJ_ONE_UP, (short)465, (short)200, (byte)1, (short)190, (short)235);
    for(int i = endPoint; i < 7; i++)
      objects[i].setProperties();
}
void loadLevel3(byte enemySpeed){
    endPoint = 6;
    arrowPos[0] = (byte)((arrowPos[0] & -22) | 4);
    groundRef = INSIDE_GROUND;
    pillarRef[0] = INSIDE_PILLAR_TOP;
    pillarRef[1] = INSIDE_PILLAR_STEM;
    zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
    arrowXPos = ARROW_X_LEFT;
    arrowDirection = -ARROW_WIDTH;
    goalCount = 12;
    if(randomNum > 0 && (oneUpFlash & 64) == 64)
      endPoint++;
    placeRect(9, 7, 6, 4, BG_GROUND, levelData);
    placeHoriz(9, 6, 6, BG_COIN, levelData);
    placeHoriz(1, 7, 6, BG_GROUND, levelData);
    placeHoriz(1, 6, 6, BG_COIN, levelData);
    placeHoriz(9, 3, 6, BG_GROUND, levelData);
    placeTile(14, 2, BG_EXIT, levelData);
    placeTile(2, 8, BG_PILLAR, levelData);
    placeTile(4, 8, BG_PILLAR, levelData);
    placeTile(6, 8, BG_PILLAR, levelData);
    placeTile(9, 4, BG_PILLAR, levelData);
    placeTile(11, 4, BG_PILLAR, levelData);
    placeTile(13, 4, BG_PILLAR, levelData);
    placeTile(6, 3, BG_VENT, levelData);
    objects[0].setProperties(OBJ_ROBOT, (short)600, (short)125, (byte)(enemySpeed & 3), (short)475, (short)725);
    objects[1].setProperties(OBJ_ROBOT, (short)250, (short)325, (byte)(enemySpeed & 3), (short)50, (short)300);
    objects[2].setProperties(OBJ_ROCKET, (short)60, (short)250, (byte)((enemySpeed >> 2) & 7), (short)50, (short)725);
    objects[3].setProperties(OBJ_ROCKET, (short)715, (short)225, (byte)(-((enemySpeed >> 2) & 7)), (short)50, (short)725);
    objects[4].setProperties(OBJ_PLAT_VERT, (short)350, (short)200, (byte)2, (short)150, (short)575);
    objects[5].setProperties(OBJ_PLAT_VERT, (short)400, (short)500, (byte)-2, (short)150, (short)575);
    if(endPoint == 7)
      objects[6].setProperties(OBJ_ONE_UP, (short)265, (short)150, (byte)1, (short)140, (short)185);
    else
      objects[6].setProperties();
}
void loadLevel4(){
  arrowPos[0] = (byte)(arrowPos[0] & -22);
  groundRef = INSIDE_GROUND;
  pillarRef[0] = INSIDE_PILLAR_TOP;
  pillarRef[1] = INSIDE_PILLAR_STEM;
  zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
  goalCount = 28;
  endPoint = 2;
  placeHoriz(1, 6, 6, BG_GROUND, levelData);
  placeHoriz(9, 6, 6, BG_GROUND, levelData);
  placeRect(1, 4, 14, 2, BG_COIN, levelData);
  placeTile(2, 7, BG_PILLAR, levelData);
  placeTile(4, 7, BG_PILLAR, levelData);
  placeTile(6, 7, BG_PILLAR, levelData);
  placeTile(9, 7, BG_PILLAR, levelData);
  placeTile(11, 7, BG_PILLAR, levelData);
  placeTile(13, 7, BG_PILLAR, levelData);
  placeTile(4, 3, BG_VENT, levelData);
  placeTile(10, 3, BG_VENT, levelData);
  objects[0].setProperties(OBJ_PLAT_VERT, (short)350, (short)400, (byte)-2, (short)300, (short)575);
  objects[1].setProperties(OBJ_PLAT_VERT, (short)400, (short)400, (byte)-2, (short)300, (short)575);
  for(byte i = 2; i < 7; i++)
    objects[i].setProperties();
}
void loadLevel5(byte enemySpeed){
  arrowPos[0] = (byte)((arrowPos[0] & -22) | 5);
  groundRef = INSIDE_GROUND;
  pillarRef[0] = INSIDE_PILLAR_TOP;
  pillarRef[1] = INSIDE_PILLAR_STEM;
  zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
  goalCount = 9;
  endPoint = 4;
  placeTile(1, 10, BG_GROUND, levelData);
  placeTile(12, 4, BG_GROUND, levelData);
  placeHoriz(12, 10, 3, BG_GROUND, levelData);
  placeHoriz(13, 9, 2, BG_GROUND, levelData);
  placeHoriz(7, 6, 3, BG_GROUND, levelData);
  placeTile(8, 5, BG_EXIT, levelData);
  placeTile(7, 7, BG_PILLAR, levelData);
  placeTile(9, 7, BG_PILLAR, levelData);
  placeTile(12, 5, BG_PILLAR, levelData);
  placeTile(4, 2, BG_VENT, levelData);
  placeTile(8, 2, BG_VENT, levelData);
  placeTile(12, 2, BG_VENT, levelData);
  placeHoriz(1, 5, 6, BG_COIN, levelData);
  placeVert(1, 7, 3, BG_COIN, levelData);
  objects[0].setProperties(OBJ_ROCKET, (short)150,(short)450, (byte)((enemySpeed >> 2) & 7), (short)50, (short)275);
  objects[1].setProperties(OBJ_ROCKET, (short)550,(short)200, (byte)(-(((enemySpeed) >> 2) & 7)), (short)350, (short)575);
  objects[2].setProperties(OBJ_PLAT_HORIZ, (short)200, (short)300, (byte)2, (short)50, (short)350);
  objects[3].setProperties(OBJ_PLAT_VERT, (short)700, (short)300, (byte)2, (short)200, (short)450);
  for(int i = 4; i < 7; i++)
    objects[i].setProperties();
}
void loadLevel6(){
  keyInputs = 0;
  arrowPos[0]|=16;
  groundRef = OUTSIDE_GROUND;
  pillarRef[0] = OUTSIDE_GROUND;
  pillarRef[1] = OUTSIDE_PILLAR_STEM;
  zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
  attractMode = (short)(ENDING_INPUTS[0] & 255);
  bonus[7] = '0';
  bonus[8] = '0';
  time[6] = time[7] = time[8] = '9';
  placeHoriz(1, 5, 4, BG_GROUND, levelData);
  placeHoriz(2, 5, 2, BG_PILLAR, levelData);
  placeVert(0, 5, 2, BG_GROUND, levelData);
  placeVert(5, 5, 2, BG_GROUND, levelData);
  placeHoriz(1, 4, 4, BG_GROUND, levelData);
  placeHoriz(2, 3, 2, BG_GROUND, levelData);
  placeVert(6, 6, 2, BG_GROUND, levelData);
  placeHoriz(10, 8, 3, BG_GROUND, levelData);
  placeTile(11, 8, BG_PILLAR, levelData);
  placeTile(11, 7, BG_GROUND, levelData);
  objects[0].setProperties(OBJ_NONE, WIDTH, (short)525, (byte)-2, (short)-150, (short)825);
  objects[1].setProperties(OBJ_NONE, WIDTH, (short)500, (byte)-2, (short)-150, (short)825);
  for(byte i = 2; i < 7; i++)
    objects[i].setProperties();
}
void loadLevel7(byte speed){
  arrowPos[0] = (byte)((arrowPos[0] & -22) | 4);
  groundRef = INSIDE_GROUND;
  pillarRef[0] = INSIDE_PILLAR_TOP;
  pillarRef[1] = INSIDE_PILLAR_STEM;
  zeroLevel(16, 12, levelData, nonRedColours, arrowPos[0]);
  arrowXPos = ARROW_X_LEFT;
  arrowDirection = -ARROW_WIDTH;
  goalCount = 12;
  endPoint = 5;
  placeTile(7, 10, BG_GROUND, levelData);
  placeTile(8, 10, BG_GROUND, levelData);
  placeTile(8, 9, BG_GROUND, levelData);
  placeTile(9, 9, BG_COIN, levelData);
  placeTile(9, 10, BG_COIN, levelData);
  placeTile(10, 10, BG_GROUND, levelData);
  placeTile(11, 10, BG_GROUND, levelData);
  placeTile(11, 9, BG_GROUND, levelData);
  placeTile(11, 8, BG_COIN, levelData);
  placeTile(12, 8, BG_COIN, levelData);
  placeTile(12, 9, BG_GROUND, levelData);
  placeTile(13, 9, BG_GROUND, levelData);
  placeTile(12, 10, BG_COIN, levelData);
  placeTile(13, 10, BG_COIN, levelData);
  placeTile(11, 6, BG_GROUND, levelData);
  placeTile(12, 6, BG_GROUND, levelData);
  placeTile(11, 7, BG_PILLAR, levelData);
  placeTile(12, 7, BG_PILLAR, levelData);
  placeTile(8, 6, BG_GROUND, levelData);
  placeTile(9, 6, BG_GROUND, levelData);
  placeTile(8, 7, BG_PILLAR, levelData);
  placeTile(9, 7, BG_PILLAR, levelData);
  placeTile(8, 5, BG_COIN, levelData);
  placeTile(9, 5, BG_COIN, levelData);
  placeTile(4, 8, BG_PILLAR, levelData);
  placeTile(5, 8, BG_PILLAR, levelData);
  placeTile(6, 6, BG_COIN, levelData);
  placeTile(4, 7, BG_GROUND, levelData);
  placeTile(5, 7, BG_GROUND, levelData);
  placeTile(1, 4, BG_GROUND, levelData);
  placeTile(1, 5, BG_PILLAR, levelData);
  placeTile(1, 3, BG_COIN, levelData);
  placeHoriz(6, 3, 4, BG_GROUND, levelData);
  placeTile(6, 4, BG_PILLAR, levelData);
  placeTile(9, 4, BG_PILLAR, levelData);
  placeTile(8, 2, BG_COIN, levelData);
  placeTile(9, 2, BG_COIN, levelData);
  placeHoriz(11, 3, 4, BG_GROUND, levelData);
  placeTile(14, 2, BG_EXIT, levelData);
  placeTile(11, 4, BG_PILLAR, levelData);
  placeTile(13, 4, BG_PILLAR, levelData);
  placeTile(3, 2, BG_VENT, levelData);
  placeTile(12, 1, BG_VENT, levelData);
  objects[0].setProperties(OBJ_ROBOT, (short)650, (short)425, (byte)((~(speed & 3))+1), (short)550, (short)700);
  objects[1].setProperties(OBJ_ROBOT, (short)350, (short)125, (byte)(speed & 3), (short)300, (short)500);
  objects[2].setProperties(OBJ_ROCKET, (short)300, (short)250, (byte)((speed >> 2) & 7), (short)100, (short)525);
  objects[3].setProperties(OBJ_PLAT_VERT, (short)700, (short)300, (byte)2, (short)(300), (short)(600));
  objects[4].setProperties(OBJ_PLAT_VERT, (short)150, (short)375, (byte)-2, (short)(200), (short)(375));
  for(byte i = 5; i < 7; i++)
    objects[i].setProperties();
  
}
void oscPlay(Oscillator osc, byte[] timers, byte[] pointers, short[][] freqs, short[][] durs, byte[] arrowPosition, byte mainIndex, byte arrowPosBit, byte soundCount){
  if((arrowPosition[0] & arrowPosBit) == arrowPosBit){
    if((arrowPosition[0] & -128) == 0)
      osc.play();
    timers[mainIndex]++;
    if(timers[mainIndex] >= durs[mainIndex][pointers[mainIndex]]){
      osc.stop();
      timers[mainIndex] = 0;
      pointers[mainIndex]++;
      osc.freq(freqs[mainIndex][pointers[mainIndex]]);
      if(durs[mainIndex][pointers[mainIndex]] == 0 || pointers[mainIndex] >= soundCount){
        arrowPosition[0]&=~(arrowPosBit);
        pointers[mainIndex] = 0;
      }
    }
  }
  if((arrowPosition[0] & -128) == -128)
    osc.stop();
}
void textDraw(char[] text, byte len, short xPos, short yPos, byte size){
  for(byte i = 0; i < len; i++){
    if(text[i] < ' ' || text[i] > 'Z')
      return;
    characters[text[i]-' '].draw(i*size+xPos, yPos, size, size);
      
  }
}

void initPauseSound(){
  sqr.stop();
  soundDurations[0][0] = (short)10;
  soundDurations[0][1] = (short)10;
  soundDurations[0][2] = (short)15;
  frequencies[0][1] = (short)750;
  frequencies[0][0] = (short)1000;
  frequencies[0][2] = (short)1000;
  soundTimers[0] = 0;
  sqr.freq(frequencies[0][0]);
  for(int i = 3; i < 6; i++){
    frequencies[0][i] = 0;
    soundDurations[0][i] = 0;
  }
  soundPointers[0] = 0;
  arrowPos[0]|=64;
}



//Zeros out the background data
void zeroLevel(int sizeX, int sizeY, byte[][] back, byte[] gb, byte arrowPoses){
  scoreQueue.clear();
  arrowXPos = ARROW_X_RIGHT;
  arrowDirection = ARROW_WIDTH;
  for(int i = 0; i < sizeX; i++){
    for(int j = 0; j < sizeY; j++){
      back[i][j]&=BG_NONE;
    }
  }
  switch(arrowPoses & 16){
    case 16:
      gb[0]= (byte)(-92);
      gb[1] = (byte)(-24);
      for(int i = 0; i < sizeX; i++)
        back[i][sizeY-1] = BG_NONE|BG_GROUND;
      break;
    default:
      gb[0]= gb[1] = 0;
     for(int i = 0; i < 16; i++){
       levelData[i][0] = BG_NONE|BG_GROUND;
       levelData[i][11] = BG_NONE|BG_GROUND;
     }
     for(int i = 1; i < 11; i++){
       levelData[0][i] = BG_NONE|BG_GROUND;
       levelData[15][i] = BG_NONE|BG_GROUND;
     }
     break;
  }
     
}

//Functions for assigning background tiles their IDs
void placeTile(int xPos, int yPos, int type, byte[][] back){
  if(xPos < 0)
    xPos = 0;
   else if(xPos >= SCREEN_WIDTH_TILES)
     xPos = SCREEN_WIDTH_TILES-1;
   if(yPos < 0)
    yPos = 0;
   else if(yPos >= SCREEN_HEIGHT_TILES)
     yPos = SCREEN_HEIGHT_TILES-1;
   back[xPos][yPos] = (byte)(type+(((type & 2) == 2) ? 0 : -8));
}

void placeHoriz(int startIndex, int yIndex, int size, int type, byte[][] back){
  if(size > SCREEN_WIDTH_TILES)
    size = SCREEN_WIDTH_TILES;
   else if(size < 1)
     size = 1;
   if(yIndex >= SCREEN_HEIGHT_TILES)
     yIndex = SCREEN_HEIGHT_TILES-1;
   else if(yIndex < 0)
     yIndex = 0;
   //Clamping the start index and the size of the row
   int i = (startIndex >= 0) ? 0 : -startIndex;
   if((startIndex+size) >= SCREEN_WIDTH_TILES)
     size = (startIndex+size-SCREEN_WIDTH_TILES);
     
   for(; i < size; i++){
     back[i+startIndex][yIndex] = (byte)(type+(((type & 2) == 2) ? 0 : BG_NONE));
   }
}

void placeVert(int xIndex, int startIndex, int size, int type, byte[][] back){
  if(size > SCREEN_HEIGHT_TILES)
    size = SCREEN_HEIGHT_TILES;
   else if(size < 1)
     size = 1;
   if(xIndex >= SCREEN_WIDTH_TILES)
     xIndex = SCREEN_WIDTH_TILES-1;
   else if(xIndex < 0)
     xIndex = 0;
   
   //Clamping the start index and the size of the column
   int i = (startIndex >= 0) ? 0 : -startIndex;
   if((startIndex+size) >= SCREEN_HEIGHT_TILES)
     size = (startIndex+size-SCREEN_HEIGHT_TILES);
     
   for(; i < size; i++){
     back[xIndex][i+startIndex] = (byte)(type+(((type & 2) == 2) ? 0 : -8));
   }
}

void placeRect(int startX, int startY, int wid, int heigh, int type, byte[][] back){
  if(wid >= SCREEN_WIDTH_TILES)
    wid = SCREEN_WIDTH_TILES-1;
   else if(wid < 1)
     wid = 1;
   if(heigh >= SCREEN_HEIGHT_TILES)
    heigh = SCREEN_HEIGHT_TILES-1;
   else if(heigh < 1)
     heigh = 1;  
   for(int i = 0; i < wid; i++){
     for(int j = 0; j < heigh; j++){
       if(i >= 0 && i+startX < SCREEN_WIDTH_TILES && j >= 0 && j+startY < SCREEN_HEIGHT_TILES)
         back[i+startX][j+startY] = (byte)(type+(((type & 2) == 2) ? 0 : -8));
     }
   }
}

boolean isTooBig(char[] text, byte size, int startPos, int maxSize){
  int compValue = 0;
  int powerOfTen = 1;
  for(int i = 0; i < size; i++){
    powerOfTen = 1;
    for(int j = 0; j < i; j++)
      powerOfTen*=10;
    compValue+=(text[size-i-1+startPos]-48)*powerOfTen;
  }
  return compValue >= maxSize;
}

//Handles interactions between objects and the level background (REPLACE ALL RECT CALLS FOR CALLS TO ACTUAL GRAPHICS AND DELETE ALL STROKES AND FILLS WHEN DONE)
void drawBack(byte frameCounter, Player currPlayer, TextMod mod, byte[][] background, byte[] coinCount, byte goalCount, char[] text, byte[] arrowPosition, SqrOsc sqr, short[][] soundDur, short[][] freqs, byte[] soundP, byte[] soundTimers){
  currPlayer.setState((byte)((currPlayer.returnState() & -29))); 
  int tileX = 0;
  int tileY = 0;
  
  //This is used to advance the frames of the coins' animation
  if((frameCounter & COIN_FRAME_TRIGGER) == COIN_FRAME_TRIGGER){
    coinFrame++;
    if(coinFrame > MAX_COIN_FRAME)
      coinFrame = 0;
  }
  
  for(int i = 0; i < SCREEN_WIDTH_TILES; i++){
    tileX = TILE_SIZE*i;
    for(int j = 0; j < SCREEN_HEIGHT_TILES; j++){
      tileY = TILE_SIZE*j;
      switch((background[i][j] & 7)){
        case BG_GROUND:
           if(currPlayer.returnY()+25 > tileY && currPlayer.returnY()+25 < tileY+50){
            if(currPlayer.returnX()+50 >= tileX && currPlayer.returnX() <= tileX+25){
              if((currPlayer.returnState() & 2) == 0)
                currPlayer.setState((byte)((currPlayer.returnState() & -17) | 16));
              if((keyInputs & 4) == 0)
              currPlayer.setXSpeed((byte)0);
              currPlayer.setX((short)(tileX-50));
            }
            else if(currPlayer.returnX() <= tileX+50 && currPlayer.returnX()+50 >= tileX+25){
              if((currPlayer.returnState() & 2) == 0)
                currPlayer.setState((byte)((currPlayer.returnState() & -9) | 8));
              if((keyInputs & 8) == 0)
                currPlayer.setXSpeed((byte)0);
              currPlayer.setX((short)(tileX+50));
            }
          }
          if(currPlayer.returnX()+35 >= tileX && currPlayer.returnX() <= tileX+35){
            if(currPlayer.returnY()+50 >= tileY && currPlayer.returnY() < tileY+50){
              if(currPlayer.returnY()+50 <= tileY+25){
                currPlayer.setY((short)(tileY-50));
                currPlayer.setState((byte)((currPlayer.returnState() & -1) | 4));
              }
              else if(currPlayer.returnY() >= tileY+25){
                if((currPlayer.returnState() & 2) == 2)
                  currPlayer.setState((byte)((currPlayer.returnState()) | 1));
                currPlayer.setY((short)(tileY+50));
                currPlayer.setYSpeed((byte)(0));
              }
            }
          } 
          break;
        case BG_COIN:
          characters[coinFrame+COIN_FRAME_ONE].draw(tileX+7, tileY+7, 35, 35);
          if(currPlayer.returnX()+50 >= tileX+7 && currPlayer.returnX() <= tileX+35 && (currPlayer.returnState() & 1) == 0){
            if(currPlayer.returnY()+50 >= tileY+7 && currPlayer.returnY() <= tileY+35){
              background[i][j] = BG_NONE;
              scoreQueue.add(new CoinScoreText(tileX+11, tileY+17));
              sqr.stop();
              soundDur[0][0] = (short)4;
              soundDur[0][1] = (short)10;
              freqs[0][0] = (short)750;
              freqs[0][1] = (short)1000;
              soundTimers[0] = 0;
              sqr.freq(freqs[0][0]);
              for(int s = 2; s < 6; s++){
                freqs[0][s] = 0;
                soundDur[0][s] = 0;
              }
              soundP[0] = 0;
              arrowPosition[0]|=64;
              if(isTooBig(text, (byte)7, 5, 9999975))
                for(int s = 5; s < 12; s++){
                  text[s] = text[s+7];
                }
              else{
                mod.incrementCounter(text, (byte)18, 0, (byte)12);
                mod.incrementCounter(text, (byte)5, 0, (byte)12);
                secondScore+=25;
              }
              coinCount[0]++;
            }
          }
          break;
        case BG_EXIT:
          if(coinCount[0] >= goalCount){
            if(currPlayer.returnX()+50 >= tileX+GOAL_LEFT && currPlayer.returnX() <= tileX+GOAL_RIGHT && currPlayer.returnY()+50 >= tileY+7 && currPlayer.returnY() <= tileY+42)
              arrowPosition[0]|=8;
            background[i][j]+=8;
            if((frameCounter & 31) >= 15)
              characters[55].draw(tileX+arrowXPos, tileY+10, arrowDirection, 25);
          }
          characters[38].draw(tileX+12, tileY+7);
          break;
        case BG_PILLAR:
          characters[pillarRef[0]].draw(tileX, tileY); 
          for(int s = 1; (background[i][s+j] & 7) != 1; s++)
            characters[pillarRef[1]].draw(tileX, (s+j)*50); 
          break;
          
        case BG_VENT:
          characters[61].draw(tileX+11, tileY+11, 14, 14);
          characters[63].draw(tileX+11, tileY+25, 14, 14);
          characters[64].draw(tileX+25, tileY+25, 14, 14);
          characters[62].draw(tileX+25, tileY+11, 14, 14);
          break;
          
        case BG_TELE:
          if(currPlayer.returnX()+50 >= tileX+25 && currPlayer.returnX() <= tileX && currPlayer.returnY()+50 >= tileY+25 && currPlayer.returnY() <= tileY)
            arrowPos[0]|=8;
          break;
      }
    }
  }
  currPlayer.setState((byte)(currPlayer.returnState() & -3));
}

void drawGround(byte[][] background){
  int tileX = 0;
  int tileY = 0;
  for(int i = 0; i < SCREEN_WIDTH_TILES; i++){
    tileX = i*TILE_SIZE;
    for(int j = 0; j < SCREEN_HEIGHT_TILES; j++){
      tileY = j*TILE_SIZE;
      if((background[i][j] & 7) == BG_GROUND)
        characters[groundRef].draw(tileX, tileY, 50, 50);
    }
  }
}

short LSFRShift(short seed){
    if(((seed >> 12) & 15) == (seed & 15) && ((seed >> 8) & 15) == (seed & 15) && ((seed >> 4) & 15) == (seed & 15))
      seed = -21500;
    seed = (short)((seed >> 1) & 32767);
    short newBit = (short)(((((seed & 128) >> 7)^(seed & 1)) << 15) & -32768);
    seed|=newBit;
    return seed;
}

PImage setImage(byte wid, byte heig, short red, short green, short blue){
  red&=255;
  green&=255;
  blue&=255;
  PImage graphic = new PImage(wid, heig, 0);
  graphic.loadPixels();
  for(int i = 0; i < graphic.pixels.length; i++)
    graphic.pixels[i] = 0xFF000000|(red << 16)|(green << 8)|blue;
  graphic.updatePixels();
  return graphic;
}

void initializeGame(){
  red = 0;
  lives[8] = '3';
  oneUpFlash&=-64;
  for(byte i = 5; i < 12; i++)
    score[i] = '0';
  stageStart[7] = '1';
  soundSize&=63;
  for(byte i = 8; i < stageStart.length; i++)
    stageStart[i] = 0;
  coinCounter[0] = 0;
  sqr.stop();
  saw.stop();
  attractMode = 0;
  secondScore = 0;
  arrowPos[0]&=-128;
  for(byte i = 0; i < BONUS_TEXT_LENGTH; i++)
    bonusText[i] = 0;
  currPlayer.setXSpeed((byte)(0));
  currPlayer.setYSpeed((byte)(0));
  currPlayer.setState((byte)(0));
  currPlayer.setY((short)(500));
  if((isSmoothed & 4) == 0){
    levelCount = 0;
    currPlayer.setX(-150);
    loadLevel0();
    gameOverTime = -512;
  }
  else{
    levelCount = 1;
    currPlayer.setX((short)100);
    loadLevel1(enSpeed);
    gameOverTime = 256;
  } 
}

/*
KEY_CODES:
  1 = UP
  2 = DOWN
  4 = LEFT
  8 = RIGHT
  16 = SPACE
  32 = ENTER
  64 = ESC
  -128 = soundOnOff
*/

void keyPressed(){
  switch(key){
    case CODED:
      switch(keyCode){
        case UP:
          keyInputs|=1;
          randomNum+=8;
          break;
        case DOWN:
          keyInputs|=2;
          randomNum+=16;
          break;
        case LEFT:
          keyInputs = (byte)((keyInputs & -13) | 4);
          randomNum+=32;
          break;
        case RIGHT:
          keyInputs = (byte)((keyInputs & -13) | 8);
          randomNum+=64;
          break;
        case ESC:
          keyInputs|=64;
          randomNum+=512;
          break;
      }
      break;
    case ' ':  
      keyInputs|=16;
      randomNum+=128;
      break;
    case '\n':
      keyInputs|=32;
      randomNum+=256;
      break;
    case 'c':
      keyInputs|=-128;
      randomNum+=1024;
      break;
  }
}
void keyReleased(){
  switch(key){
    case CODED:
      switch(keyCode){
        case UP:
          keyInputs&=-2;
          break;
        case DOWN:
          keyInputs&=-3;
          break;
        case LEFT:
          keyInputs&=-5;
          break;
        case RIGHT:
          keyInputs&=-9;
          break;
        case ESC:
          keyInputs&=-65;
          break;
      }
      break;
    case ' ':  
      keyInputs&=-17;
      break;
    case '\n':
      keyInputs&=-33;
      break;
    case 'c':
      keyInputs&=127;
      break;
  }
}
