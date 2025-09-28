public class AutoClear extends RoomObject{
  public AutoClear(){
    xPos = 0;
    yPos = 0;
    tileWidth = TILE_SIZE;
    tileHeight = TILE_SIZE;
  }
  
  public AutoClear(float x, float y){
    xPos = x;
    yPos = y;
    tileWidth = TILE_SIZE;
    tileHeight = TILE_SIZE;
  }
  
  public void interact(){
    if(currPlayer.returnX()+50 >= xPos+(tileWidth >>> 1) && currPlayer.returnX() <= xPos && currPlayer.returnY()+50 >= yPos+(tileHeight >>> 1) && currPlayer.returnY() <= yPos)
      arrowPos[0]|=8;
  }
  public AutoClear clone(){
    return new AutoClear(xPos, yPos);
  }
}
