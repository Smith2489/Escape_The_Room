public class Ground extends RoomObject{
  int halfWidth = 25;
  int halfHeight = 25;
  
  public Ground(){
    xPos = 0;
    yPos = 0;
    tileWidth = TILE_SIZE;
    tileHeight = TILE_SIZE;
    halfWidth = (TILE_SIZE >>> 1);
    halfHeight = (TILE_SIZE >>> 1);
  }
  public Ground(float x, float y){
    xPos = x;
    yPos = y;
    tileWidth = TILE_SIZE;
    tileHeight = TILE_SIZE;
    halfWidth = (TILE_SIZE >>> 1);
    halfHeight = (TILE_SIZE >>> 1);
  }
  
  public void interact(){
    if(currPlayer.returnY()+25 > yPos && currPlayer.returnY()+25 < yPos+tileHeight){
      if(currPlayer.returnX()+50 >= xPos && currPlayer.returnX() <= xPos+halfWidth){
        if((currPlayer.returnState() & 2) == 0)
          currPlayer.setState((byte)((currPlayer.returnState() & -17) | 16));
        if((keyInputs & 4) == 0)
          currPlayer.setXSpeed(0);
          currPlayer.setX(xPos-50);
        }
        else if(currPlayer.returnX() <= xPos+tileWidth && currPlayer.returnX()+50 >= xPos+halfWidth){
          if((currPlayer.returnState() & 2) == 0)
            currPlayer.setState((byte)((currPlayer.returnState() & -9) | 8));
          if((keyInputs & 8) == 0)
            currPlayer.setXSpeed(0);
          currPlayer.setX(xPos+50);
          }
        }
        if(currPlayer.returnX()+35 >= xPos && currPlayer.returnX() <= xPos+(halfWidth+10)){
          if(currPlayer.returnY()+50 >= yPos && currPlayer.returnY() < yPos+tileHeight){
            if(currPlayer.returnY()+50 <= yPos+halfHeight){
              currPlayer.setY(yPos-50);
              currPlayer.setState((byte)(currPlayer.returnState() | 4));
            }
            else if(currPlayer.returnY() >= yPos+halfHeight){
              if((currPlayer.returnState() & 2) == 2)
                currPlayer.setState((byte)(currPlayer.returnState() | 1));
              currPlayer.setY(yPos+50);
              currPlayer.setYSpeed(0);
          }
      }
    }
  }
  
  public Ground clone(){
    return new Ground(xPos, yPos);
  }
}
