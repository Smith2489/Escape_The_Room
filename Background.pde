public static interface Background<E, U>{
  public void setTile(E id, int xPos, int yPos);
  public void setRow(E id, int xPos, int yPos, int rowLen);
  public void setColumn(E id, int xPos, int yPos, int colLen);
  public void setRect(E id, int xPos, int yPos, int rectWidth, int rectHeight);
  public void setAttributeListSize(int size);
  public void setAttribute(U attribute, int index);
  public void setAttribute(U attribute);
  public void zeroBackground();
  public void drawBack();
  public void copy(Object o);
  public boolean equals(Object o);
}
