class MovingObject{
  protected float speed = 0, xPos = 0, yPos = 0;
  protected byte frameNum = 0;
  protected short dir = 1;
  MovingObject(){
    xPos = 0;
    yPos = 0;
    speed = 0;
    frameNum = 0;
  }
  MovingObject(float x, float y, byte sX){
    xPos = x;
    yPos = y;
    speed = sX;
    if(sX < 0)
      dir = -1;
    else
      dir = 1;
    frameNum = 0;
  }
  
  void setSpeed(byte newS){
    speed = newS;
  }
  float returnSpeed(){
    return speed;
  }
  void setX(float newX){
    xPos = newX;
  }
  void setY(float newY){
    yPos = newY;
  }
  float returnX(){
    return xPos;
  }
  float returnY(){
     return yPos; 
  }
  void setFrame(byte newFrame){
    frameNum = newFrame;
  }

  byte returnFrame(){
    return frameNum;
  }
}
