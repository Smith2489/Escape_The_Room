public final float EPSILON = 0.00001f;
public interface BackgroundObject<E>{
  public void setAttributes(E[] attributes);
  public void setXPos(float x);
  public void setYPos(float y);
  public float getXPos();
  public float getYPos();
  public void interact();
  public BackgroundObject clone();
  public boolean equals(Object o);
}
