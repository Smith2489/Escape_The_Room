public abstract class RoomObject implements BackgroundObject<Integer>{
  protected float xPos = 0;
  protected float yPos = 0;
  public int tileWidth = 8;
  public int tileHeight = 8;
  
  
  public void setAttributes(Integer[] attributes){
    if(attributes.length < 2)
      return;
    tileWidth = attributes[0];
    tileHeight = attributes[1];
  }
  
  //Override if the object is not the full tile size
  public void setXPos(float x){
    xPos = x;
  }
  public void setYPos(float y){
    yPos = y;
  }
  public float getXPos(){
    return xPos;
  }
  public float getYPos(){
    return yPos;
  }
  
  public boolean equals(Object o){
    if(o instanceof RoomObject){
      RoomObject r = (RoomObject)o;
      return Math.abs(xPos - r.xPos) <= EPSILON && Math.abs(yPos - r.yPos) <= EPSILON && tileWidth == r.tileWidth && tileHeight == r.tileHeight;
    }
    return false;
  }
  
  public boolean equals(RoomObject r){
    return Math.abs(xPos - r.xPos) <= EPSILON && Math.abs(yPos - r.yPos) <= EPSILON && tileWidth == r.tileWidth && tileHeight == r.tileHeight;
  }
  public String toString(){
    return tileWidth+" "+tileHeight;
  }
  
  public abstract RoomObject clone();
}
