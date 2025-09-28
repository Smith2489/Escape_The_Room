//Information for the sizing and position of the goal
final byte GOAL_WIDTH = 25;
final byte GOAL_HEIGHT = 35;
final byte GOAL_LEFT = 12;
final byte GOAL_TOP = 7;

//Information for the position of the arrow that shows up pointing to the goal
final byte ARROW_WIDTH = 50;
final byte ARROW_HEIGHT = 25;
final byte ARROW_Y_POS = 3;
final byte ARROW_X_RIGHT = GOAL_LEFT+GOAL_WIDTH;
final byte ARROW_X_LEFT = GOAL_LEFT-ARROW_WIDTH-18;
final byte ARROW_POINT_LEFT = 1;
final byte ARROW_POINT_RIGHT = -1;
final byte ARROW_ANIM_TIME = 31;


public class Exit extends RoomObject{
  private int arrowX = 35;
  private int arrowDir = 1;
  public Exit(){
    xPos = GOAL_LEFT;
    yPos = GOAL_TOP;
    arrowX = ARROW_X_RIGHT;
    arrowDir = 1;
    tileWidth = GOAL_WIDTH;
    tileHeight = GOAL_HEIGHT;
  }
  
  public Exit(float x, float y){
    xPos = x+GOAL_LEFT;
    yPos = y+GOAL_TOP;
    arrowX = ARROW_X_RIGHT;
    arrowDir = 1;
  }
  
  public Exit(float x, float y, int newArrowX, int newArrowDir){
    xPos = x;
    yPos = y;
    arrowX = newArrowX;
    arrowDir = newArrowDir;
    
  }
  
  public void setXPos(float x){
    xPos = x+GOAL_LEFT;
  }
  public void setYPos(float y){
    yPos = y+GOAL_TOP;
  }
  
  public void setAttributes(Integer[] attributes){
    if(attributes.length < 2)
      return;
    arrowX = attributes[0];
    arrowDir = attributes[1]*ARROW_WIDTH;
  }
  
  public void interact(){
    if(coinCounter[0] >= goalCount){
      if(currPlayer.returnX()+50 >= xPos && currPlayer.returnX() <= xPos+GOAL_WIDTH && currPlayer.returnY()+50 >= yPos && currPlayer.returnY() <= yPos+GOAL_HEIGHT)
        arrowPos[0]|=8;
        if((frameCounter & ARROW_ANIM_TIME) >= 15)
          characters[55].draw(xPos+arrowX, yPos+ARROW_Y_POS, arrowDir, ARROW_HEIGHT);
     }
     characters[38].draw(xPos, yPos);
  }
  
  public Exit clone(){
    return new Exit(xPos, yPos, arrowX, arrowDir);
  }
  
  public boolean equals(Object o){
    if(o instanceof Exit){
      Exit e = (Exit)o;
      return (Math.abs(xPos - e.xPos) <= EPSILON && Math.abs(yPos - e.yPos) <= EPSILON && arrowX == e.arrowX && arrowDir == e.arrowDir);
    }
    return false;
    
  }
  
  public boolean equals(Exit e){
    return (Math.abs(xPos - e.xPos) <= EPSILON && Math.abs(yPos - e.yPos) <= EPSILON && arrowX == e.arrowX && arrowDir == e.arrowDir);
  }
}
