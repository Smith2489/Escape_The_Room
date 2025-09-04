class NonPlayerEnt extends MovingObject{
  private float bound1, bound2; //Are the bounds for the object that is moving
  byte id = 0;
  NonPlayerEnt(){
    super((short)0, (short)0, (byte)0);
    bound1 = 0;
    bound2 = 0;
    id = -1;
  }
  NonPlayerEnt(short x, short y, byte s, float b1, float b2, byte i){
    super(x, y, s);
    bound1 = b1;
    bound2 = b2;
    id = i;
  }
  
  private void moveVertically(byte heig){
    float newY = yPos;
    newY+=speed;
    if(newY <= bound1){
      newY = bound1;
      speed*=-1;;
    }
    if(newY+heig >= bound2){
      newY = (short)(bound2-heig);
      speed*=-1;
    }
    yPos = newY;
    if(speed < 0)
      dir = -1;
    else
      dir = 1;
  }
  private void moveHorizontally(byte wid){
    float newX = xPos;
    newX+=speed;
    if(newX <= bound1){
      newX = bound1;
      speed*=-1;
    }
    if(newX+wid >= bound2){
      newX = (short)(bound2-wid);
      speed*=-1;
    }
    if(speed < 0)
      dir = -1;
    else
      dir = 1;
    xPos = newX;
  }
  
  private void enemyCollision(Player player, byte arrowPos){
    if(player.returnX()+35 >= xPos && player.returnX()+15 <= xPos+25 && player.returnY()+45 >= yPos && player.returnY()+5 <= yPos+25 && (player.returnState() & 1) == 0){
      if((arrowPos & 16) == 0)
        player.setState((byte)(player.returnState() | 1));
      
    }
  }
  
  int oneUpText(Graphics OneUpGraphic, int pointer, byte index){
    OneUpGraphic.draw(xPos, yPos, 28, 20);
    yPos--;
    if(yPos <= bound2){
      id = -1;
      pointer = (index == pointer-1) ? pointer-1 : pointer;
    }
    return pointer;
  }
  
  void oneUp(TextMod mod, Player player, Graphics oneUpGraphic, char[] livesCounter, byte size, int startPoint){
    moveVertically((byte)25);
    oneUpGraphic.draw(xPos, yPos);
    if(player.returnX()+50 >= xPos && player.returnX() <= xPos+25 && player.returnY()+50 >= yPos && player.returnY() <= yPos+25){
      initPauseSound();
      mod.lockInc(livesCounter, (byte)1, startPoint, size);
      yPos = (bound2+bound1)*0.5f;
      bound2 = yPos-31;
      xPos-=2;
      id = 6;
    }
  }
  void vertPlat(Player player, Graphics platformGraphic){
    if(player.returnY()+62 >= yPos && player.returnY() <= yPos && player.returnX()+42 >= xPos && player.returnX() <= xPos+42 && (player.returnState() & 33) == 0){
      player.setY((short)(yPos-50));
      player.setState((byte)(player.returnState() | 2));
    }
    platformGraphic.draw(xPos, yPos);
    moveVertically((byte)25);
  }
  
  void horizPlat(Player player, Graphics platformGraphic){
    if(player.returnY()+50 >= yPos && player.returnY()+25 <= yPos && player.returnX()+42 >= xPos && player.returnX() <= xPos+42){
      player.setX((short)(player.returnX()+speed));
      player.setY((short)(yPos-50));
      player.setState((byte)(player.returnState() | 2));
    }
    moveHorizontally((byte)50);
    platformGraphic.draw(xPos, yPos);
  }
  void rocket(Player player, Graphics[] enemyGraphic, byte arrowPos){
      moveHorizontally((byte)25);
      if((frameCounter & 15) == 15)
        frameNum = (byte)((frameNum+1) & 1);
      enemyGraphic[frameNum].draw(xPos, yPos, 25*dir, 25);
      enemyCollision(player, arrowPos);
        
  }
  
  void robot(Player player, Graphics enemyGraphic, byte arrowPos){      
      moveHorizontally((byte)25);
      enemyGraphic.draw(xPos, yPos, 25, 25);
      enemyCollision(player, arrowPos);
  }
  
  void setLowerBound(short b){
     bound1 = b; 
  }
  void setHigherBound(short b){
     bound2 = b; 
  }
  float returnLowerBound(){
     return bound1; 
  }
  float returnHigherBound(){
     return bound2; 
  }
  void setID(byte newID){
    id = newID;
  }
  byte returnID(){
    return id;
  }
  void setProperties(byte newID, short x, short y, byte s, short b1, short b2){
    id = newID;
    xPos = x;
    yPos = y;
    setSpeed(s);
    bound1 = b1;
    bound2 = b2;
  }
  void setProperties(){
    id = -1;
    xPos = 0;
    yPos = 0;
    setSpeed((byte)0);
    bound1 = 0;
    bound2 = 0;
  }
}
