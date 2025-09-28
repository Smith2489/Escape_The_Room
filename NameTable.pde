public abstract class NameTable<E, U> implements Background<E, U>{
  protected E[] background = (E[])(new Object[0]);
  protected U[] attributeList = (U[])(new Object[0]);
  protected int wid = 0;
  protected int heig = 0;
  protected int tileWidth = 8;
  protected int tileHeight = 8;
  
  public NameTable(){
    background = null;
    wid = 0;
    heig = 0;
    tileWidth = 0;
    tileHeight = 0;
  }
  
  public NameTable(int backWid, int backHeig){
    background =  (E[])(new Object[backWid*backHeig]);
    wid = backWid;
    heig = backHeig;
  }
  public NameTable(int screenWidth, int screenHeight, int tileWid, int tileHeig){
    tileWidth = tileWid;
    tileHeight = tileHeig;
    wid = screenWidth/tileWidth;
    heig = screenHeight/tileHeight;
    background = (E[])(new Object[wid*heig]);
  }
  
  public void setAttributeListSize(int size){
    attributeList = (U[])(new Object[size]);
  }
  
  public void zeroBackground(){
    for(int i = 0; i < background.length; i++)
      background[i] = null;
  }
  
  public void setBackgroundDim(int newWidth, int newHeight){
    background = (E[])(new Object[newWidth*newHeight]);
  }
  public void setBackgroundDim(int screenWidth, int screenHeight, int newTileWidth, int newTileHeight){
    tileWidth = newTileWidth;
    tileHeight = newTileHeight;
    wid = screenWidth/tileWidth;
    heig = screenHeight/tileHeight;
    background = (E[])(new Object[wid*heig]);
  }
  
  public int returnWidth(){
    return wid;
  }
  public int returnHeight(){
    return heig;
  }
  
  public int returnTileWidth(){
    return tileWidth;
  }
  public int returnTileHeight(){
    return tileHeight;
  }
  

  
  public boolean equals(Object o){
    if(o instanceof NameTable){
      NameTable n = (NameTable)o;
      if(background.length != n.background.length)
        return false;
      boolean isEquals = wid == n.wid;
      isEquals&=(heig == n.heig);
      isEquals&=(tileWidth == n.tileWidth);
      isEquals&=(tileHeight == n.tileHeight);
      return isEquals;
    
    }
    return false;
  }
  public boolean equals(NameTable n){
    if(background.length != n.background.length)
      return false;
    boolean isEquals = wid == n.wid;
    isEquals&=(heig == n.heig);
    isEquals&=(tileWidth == n.tileWidth);
    isEquals&=(tileHeight == n.tileHeight);
    return isEquals;
  }
  

   
  
}
