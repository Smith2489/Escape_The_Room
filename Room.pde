//I wish that classes defined in separate PDE files were top-level classes

//Basic level objects
final RoomObject BG_NONE = (RoomObject)null;
final Ground BG_GROUND = new Ground();
final Coin BG_COIN = new Coin();
final Exit BG_EXIT = new Exit();
final Pillar BG_PILLAR = new Pillar();
final Vent BG_VENT = new Vent();
final AutoClear BG_TELE = new AutoClear();



//Indices for referencing specific graphics
final byte INSIDE_GROUND = 32;
final byte OUTSIDE_GROUND = 65;


final byte COIN_FRAME_ONE = 5;
final byte COIN_SCORE = 42;

//Coin animation details
final byte COIN_FRAME_TRIGGER = 15;
final byte MAX_COIN_FRAME = 7;

//Information for positioning and defining the bounding box for the goal
final byte GOAL_RIGHT = GOAL_LEFT+GOAL_WIDTH;



public Graphics[] characters = new Graphics[67]; //0 = space (ASCII 32), 57 = Z (ASCII 90), 2 - 4 and 15 = red characters 1, U, P, : (TAKE UP ASCII 34 - 36 and 47)

public byte coinFrame = COIN_FRAME_ONE;
public byte arrowXPos = ARROW_X_RIGHT;
public byte arrowWidth = ARROW_WIDTH;
public byte groundRef = INSIDE_GROUND;
public byte goalCount = 4;
public class Room extends NameTable<RoomObject, Integer>{
  public int groundRef = OUTSIDE_GROUND;
   public Room(int roomWid, int roomHeig){
     background = new RoomObject[roomWid*roomHeig];
     wid = roomWid;
     heig = roomHeig;
     groundRef = OUTSIDE_GROUND;
   }
   
   public Room(int screenWidth, int screenHeight, int tileWid, int tileHeig){
     tileWidth = tileWid;
     tileHeight = tileHeig;
     wid = screenWidth/tileWidth;
     heig = screenHeight/tileHeight;
     groundRef = OUTSIDE_GROUND;
     background = new RoomObject[wid*heig];
   }
   
   public void setAttributeListSize(int size){
    attributeList = new Integer[size];
  }
  public void setAttribute(int attribute, int index){
     if(index >= 0 && index < attributeList.length)
       attributeList[index] = attribute;
     else{
       System.out.println("ERROR: INDEX "+index+" IS OUT OF RANGE FOR LIST OF LENGTH "+attributeList.length);
       return;
     }
   }
   public void setAttribute(Integer attribute, int index){
     if(index >= 0 && index < attributeList.length)
       attributeList[index] = attribute;
     else{
       System.out.println("ERROR: INDEX "+index+" IS OUT OF RANGE FOR LIST OF LENGTH "+attributeList.length);
       return;
     }
   }
   public void setAttribute(int attribute){
      if(attributeList.length > 0)
       attributeList[0] = attribute;
     else{
       System.out.println("ERROR: ATTRIBUTE LIST IS CURRENTLY LENGTH 0");
       return;
     }
   }
   public void setAttribute(Integer attribute){
      if(attributeList.length > 0)
       attributeList[0] = attribute;
     else{
       System.out.println("ERROR: ATTRIBUTE LIST IS CURRENTLY LENGTH 0");
       return;
     }
   }
  
   public void setTile(RoomObject id, int tileX, int tileY){
    if(tileX >= 0 && tileX < wid && tileY >= 0 && tileY < heig){
      int tileIndex = tileY*wid+tileX;
      background[tileIndex] = id.clone();
      background[tileIndex].setXPos(tileX*tileWidth);
      background[tileIndex].setYPos(tileY*tileHeight);
      background[tileIndex].setAttributes(attributeList);
    }
  }
  
  public void setRow(RoomObject id, int tileX, int tileY, int rowLen){
    //Computing the start position and end position assuming an infinitely long background
    int start = tileX;
    int end = tileX+rowLen;
    
    //Bounding the row to the background's length
    if(end < 0)
      end = 0;
    else if(end > wid)
      end = wid;
      
    if(start < 0)
      start = 0;
    else if(start > wid)
      start = wid;
        
    //Early return if off-screen
    if(start+end == 0 || tileY < 0 || tileY >= heig)
      return;
    
    //Filling out the rows
    for(; start < end; start++){
      int tileIndex = tileY*wid+start;
      background[tileIndex] = id.clone();
      background[tileIndex].setXPos(start*tileWidth);
      background[tileIndex].setYPos(tileY*tileHeight);
      background[tileIndex].setAttributes(attributeList);
    }
  }
  
  public void setColumn(RoomObject id, int tileX, int tileY, int colLen){
    //Computing the start position and end position assuming an infinitely tall background
    int start = tileY;
    int end = tileY+colLen;
    
    //Bounding the column to the background's height
    if(end < 0)
      end = 0;
    else if(end > heig)
      end = heig;
      
    if(start < 0)
      start = 0;
    else if(start > heig)
      start = heig;
    
    //Early return if off-screen
    if(start+end == 0 || tileX < 0 || tileX >= wid)
      return;
    
    //Filling the column
    for(; start < end; start++){
      int tileIndex = start*wid+tileX;
      background[tileIndex] = id.clone();
      background[tileIndex].setXPos(tileX*tileWidth);
      background[tileIndex].setYPos(start*tileHeight);
      background[tileIndex].setAttributes(attributeList);
    }
  }
  
  public void setRect(RoomObject id, int tileX, int tileY, int rectWidth, int rectHeight){
    //Computing the start position and end position assuming an infinitely large background
    int startX = tileX;
    int startY = tileY;
    int endX = tileX+rectWidth;
    int endY = tileY+rectHeight;
    
    //Bounding the rectangle to the background's dimensions
    if(endX < 0)
      endX = 0;
    else if(endX > wid)
      endX = wid;
      
    if(startX < 0)
      startX = 0;
    else if(startX > wid)
      startX = wid;
      
    if(endY < 0)
      endY = 0;
    else if(endY > heig)
      endY = heig;
      
    if(startY < 0)
      startY = 0;
    else if(startY > heig)
      startY = heig;
    
    //Early return if off-screen
    if(startX+endX == 0 || startY+endY == 0)
      return;
      
    //Filling out the rectangle
    for(; startY < endY; startY++){
      for(int i = startX; i < endX; i++){
        int tileIndex = startY*wid+i;
        background[tileIndex] = id.clone();
        background[tileIndex].setXPos(i*tileWidth);
        background[tileIndex].setYPos(startY*tileHeight);
        background[tileIndex].setAttributes(attributeList);
      }
    }
  }
  
  public void drawBack(){
    currPlayer.setState((byte)((currPlayer.returnState() & -29)));
    if((frameCounter & COIN_FRAME_TRIGGER) == COIN_FRAME_TRIGGER){
      coinFrame++;
      if(coinFrame > MAX_COIN_FRAME)
        coinFrame = COIN_FRAME_ONE;
    }
    
    for(RoomObject tile : background){
      if(tile == null)
        continue;
      tile.interact();
    }
    
    currPlayer.setState((byte)(currPlayer.returnState() & -3));
  }
  
  public void drawGround(){
    for(RoomObject tile : background){
      if(tile instanceof Ground)
        characters[groundRef].draw(tile.getXPos(), tile.getYPos());
    }
  }
  
  public void zeroLevelOutside(){
    scoreQueue.clear();
    groundRef = OUTSIDE_GROUND;
    pillarRef[0] = OUTSIDE_GROUND;
    pillarRef[1] = OUTSIDE_PILLAR_STEM;
    for(int i = 0; i < (wid*(heig-1)); i++)
      background[i] = BG_NONE;
    for(int i = 0; i < wid; i++)
      background[i+wid*(heig-1)] = new Ground(i*tileWidth, (heig-1)*tileHeight);
  }
  
  public void zeroLevelInside(){
    scoreQueue.clear();
    groundRef = INSIDE_GROUND;
    pillarRef[0] = INSIDE_PILLAR_TOP;
    pillarRef[1] = INSIDE_PILLAR_STEM;
    for(int i = 1; i < heig-1; i++){
      for(int j = 1; j < wid-1; j++)
        background[i*wid+j] = BG_NONE;
    }
    for(int i = 0; i < wid; i++){
      background[i] = new Ground(i*tileWidth, 0);
      background[i+wid*(heig-1)] = new Ground(i*tileWidth, (heig-1)*tileHeight);
    }
    for(int i = 1; i < heig-1; i++){
      background[wid*i] = new Ground(0, i*tileHeight);
      background[wid*(i+1)-1] = new Ground((wid-1)*tileWidth, i*tileHeight);
    }
  }
  
  public void copy(Object o){
    if(o instanceof Room){
      Room r = (Room)o;
      background = new RoomObject[r.background.length];
      wid = r.wid;
      heig = r.heig;
      tileWidth = r.tileWidth;
      tileHeight = r.tileHeight;
      for(int i = 0; i < background.length; i++)
        background[i] = r.background[i].clone();
    }
  }
  
  public void copy(Room r){
    background = new RoomObject[r.background.length];
    wid = r.wid;
    heig = r.heig;
    tileWidth = r.tileWidth;
    tileHeight = r.tileHeight;
    for(int i = 0; i < background.length; i++)
      background[i] = r.background[i].clone();
  }
  
  public boolean equals(Object o){
    if(o instanceof Room){
      Room r = (Room)o;
      boolean isEquals = super.equals(r);
      for(int i = 0; i < r.background.length; i++)
        isEquals&=(background[i].equals(r.background[i]));
      return isEquals;
    }
    return false;
  }
  
  public boolean equals(Room r){
    boolean isEquals = super.equals(r);
    for(int i = 0; i < r.background.length; i++)
      isEquals&=(background[i].equals(r.background[i]));
    return isEquals;
  }
  
}
