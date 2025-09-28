final byte INSIDE_PILLAR_TOP = 59;
final byte INSIDE_PILLAR_STEM = 60;
final byte OUTSIDE_PILLAR_STEM = 66;
public int[] pillarRef = {INSIDE_PILLAR_TOP, INSIDE_PILLAR_STEM};
public class Pillar extends RoomObject{
  private int pillarHeight = 1;
  public Pillar(){
    xPos = 0;
    yPos = 0;
    pillarHeight = 1;
    tileWidth = TILE_SIZE;
    tileHeight = TILE_SIZE;
  }
  public Pillar(float x, float y){
    xPos = x;
    yPos = y;
    pillarHeight = 1;
    tileWidth = TILE_SIZE;
    tileHeight = TILE_SIZE;
  }
  
  public Pillar(float x, float y, int newHeight){
    xPos = x;
    yPos = y;
    pillarHeight = newHeight;
    tileWidth = TILE_SIZE;
    tileHeight = TILE_SIZE;
  }
  
  public void setAttributes(Integer[] attributes){
    if(attributes.length < 1)
      return;
    pillarHeight = attributes[0];
  }
  
  public void interact(){
    if(pillarHeight < 1)
      return;
    characters[pillarRef[0]].draw(xPos, yPos);
    for(int i = 1; i < pillarHeight; i++)
      characters[pillarRef[1]].draw(xPos, yPos+(i*tileHeight));
    
  }
  
  public Pillar clone(){
    return new Pillar(xPos, yPos, pillarHeight);
  }
  public boolean equals(Object o){
    if(o instanceof Pillar){
      Pillar p = (Pillar)o;
      return Math.abs(xPos - p.xPos) <= EPSILON && Math.abs(yPos - p.yPos) <= EPSILON && pillarHeight == p.pillarHeight;
    }
    return false;
  }
  
  public boolean equals(Pillar p){
    return Math.abs(xPos - p.xPos) <= EPSILON && Math.abs(yPos - p.yPos) <= EPSILON && pillarHeight == p.pillarHeight;
  }
}
