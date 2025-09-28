final int COIN_POS_OFFSET = 7;
public class Coin extends RoomObject{
  private boolean isActive = true;
  public Coin(){
    tileWidth = 35;
    tileHeight = 35;
    xPos = COIN_POS_OFFSET;
    yPos = COIN_POS_OFFSET;
    isActive = true;
  }
  
  public Coin(float x, float y){
    tileWidth = 35;
    tileHeight = 35;
    xPos = x+COIN_POS_OFFSET;
    yPos = y+COIN_POS_OFFSET;
    isActive = true;
  }
  public Coin(float x, float y, boolean active){
    tileWidth = 35;
    tileHeight = 35;
    xPos = x;
    yPos = y;
    isActive = active;
  }
  
  public void setXPos(float x){
    xPos = x+COIN_POS_OFFSET;
  }
  public void setYPos(float y){
    yPos = y+COIN_POS_OFFSET;
  }
  
  public void interact(){
    if(!isActive)
      return;
      
    characters[coinFrame].draw(xPos, yPos, tileWidth, tileHeight);
    if(currPlayer.returnX()+50 >= xPos && currPlayer.returnX() <= xPos+tileWidth && (currPlayer.returnState() & 1) == 0){
      if(currPlayer.returnY()+50 >= yPos && currPlayer.returnY() <= yPos+tileHeight){
        isActive = false;
        scoreQueue.add(new CoinScoreText(xPos+5, yPos+10));
        sqr.stop();
        soundDurations[0][0] = (short)4;
        soundDurations[0][1] = (short)10;
        frequencies[0][0] = (short)750;
        frequencies[0][1] = (short)1000;
        soundTimers[0] = 0;
        sqr.freq(frequencies[0][0]);
        for(int s = 2; s < 6; s++){
          frequencies[0][s] = 0;
          soundDurations[0][s] = 0;
        }
        soundPointers[0] = 0;
        arrowPos[0]|=64;
        if(isTooBig(score, (byte)7, 5, 9999975))
          for(int s = 5; s < 12; s++){
            score[s] = score[s+7];
           }
           else{
             wrapper.incrementCounter(score, (byte)18, 0, (byte)12);
             wrapper.incrementCounter(score, (byte)5, 0, (byte)12);
             secondScore+=25;
           }
           coinCounter[0]++;
      }
    }
  }
  
  public Coin clone(){
    return new Coin(xPos, yPos, isActive);
  }
  
  public boolean equals(Object o){
    if(o instanceof Coin){
      Coin c = (Coin)o;
      return xPos == c.xPos && yPos == c.yPos && isActive == c.isActive;
    }
    return false;
  }
  
  public boolean equals(Coin c){
    return xPos == c.xPos && yPos == c.yPos && isActive == c.isActive;
  }
  
}
