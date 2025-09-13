final int SCORE_WIDTH = 28;
final int SCORE_HEIGHT = 20;
final int MAX_HEIGHT = 31;
//A class for holding the '25' which shows up upon collecting a coin
//Instances of this class should go in a linked list
public class CoinScoreText{
  private float xPos = 0;
  private float yPos = 0;
  private float offSet = 0;
  
  public CoinScoreText(){
    xPos = 0;
    yPos = 0;
    offSet = 0;
  }
  public CoinScoreText(float x, float y){
    xPos = x;
    yPos = y;
    offSet = 0;
  }
  
  public void raise(Graphics score){
    score.draw(xPos, yPos-offSet, SCORE_WIDTH, SCORE_HEIGHT);
    offSet+=0.25f;
  }
  
  //Remove from the linked list if the offset exceeds the maximum
  public boolean shouldDelete(){
    return offSet >= MAX_HEIGHT;
  }
}
