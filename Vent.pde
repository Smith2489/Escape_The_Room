//Information for the postitioning and graphics for the vent
public final float VENT_OFFSET = 11;
public final byte VENT_TOP_LEFT = 61;
public final byte VENT_BOTTOM_LEFT = 63;
public final byte VENT_TOP_RIGHT = 62;
public final byte VENT_BOTTOM_RIGHT = 64;

public class Vent extends RoomObject{
  public Vent(){
    xPos = VENT_OFFSET;
    yPos = VENT_OFFSET; 
    tileWidth = 14;
    tileHeight = 14;
  }
  
  public Vent(float x, float y){
    xPos = x;
    yPos = y;
    tileWidth = 14;
    tileHeight = 14;
  }
  
  public void setXPos(float x){
    xPos = x+VENT_OFFSET;
  }
  public void setYPos(float y){
    yPos = y+VENT_OFFSET;
  }
  
  public void interact(){
    characters[VENT_TOP_LEFT].draw(xPos, yPos, tileWidth, tileHeight);
    characters[VENT_BOTTOM_LEFT].draw(xPos, yPos+tileHeight, tileWidth, tileHeight);
    characters[VENT_TOP_RIGHT].draw(xPos+tileWidth, yPos, tileWidth, tileHeight);
    characters[VENT_BOTTOM_RIGHT].draw(xPos+tileWidth, yPos+tileHeight, tileWidth, tileHeight);
  }
  public Vent clone(){
    return new Vent(xPos, yPos);
  }
}
