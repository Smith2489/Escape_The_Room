class Player extends MovingObject{
  private final float MAX_X_SPEED = 3.5f;
  private final float BACK_X_AIR_SPEED = 1.5f;
  private final float ACC_FRICTION = 0.1875f;
  private final float ACC_STAND_STILL = 0.125f;
  private final float ACC_BACK_GROUND = 0.25f;
  private final float ACC_Y = 0.25f;
  private final float Y_SPEED_INIT = 5.875f;
  private final float Y_MAX_SPEED = 10;
  /*
  state: Stores the state of the player; 
  1 = has died,  (0 if alive, 1 if dead)
  2 = on a platform, (0 if off platform, 1 if on platform)
  4 = on the ground,  (0 if off ground, 1 if on ground)
  8 = cannot move left, (0 if can move left, 1 if cannot move left)
  16 = cannot move right, (0 if can move right, 1 if cannot move right)
  32 = is jumping, 
  64 = spaceLock, 
  -128 = sprite direction (0 if right, 1 if left)
  
  frameNum: stores the current frame of player animation
  lives: stores the player's number of lives
  ySpeed: stores the speed of the player along the y-axis
  
  */
  private float ySpeed = 0;
  private byte state = 0, lives = 0, startFrame = 0;
  private byte deathTime = 0, flashCount = 0;
  Player(){
    super();
    state = 0;
    ySpeed = 0;
    lives = 0;
    startFrame = 0;
  }
  Player(float x, float y){
    super(x, y, (byte)0);
    state = 0;
    ySpeed = 0;
    lives = 0;
    startFrame = 0;
  }
  
  void setNewStartFrame(byte newStart){
    startFrame = newStart;
  }
  byte returnStartFrame(){
    return startFrame;
  }
  
  void controlPlayer(TextMod mod, Graphics[] frames, byte inputs, char[] livesCounter, byte size, byte digit, int startPoint, SawOsc saw, short[] sawDurs, short[] sawFreqs, byte[] pointers, byte[] timers, byte[] arrowPos, char[] time, char[] max){
    if((state & 6) != 0 && (state & 1) == 0){
      if((state & -128) == -128)
        startFrame = 3;
      else
         startFrame = 0;
      if((inputs & 12) != 0 && (inputs & 12) != 12 && (state & 24) == 0){
        if((frameCounter & 7) == 7){
          frameNum++;
          if(frameNum >= startFrame+3)
            frameNum = startFrame;
        }
      }
      else
        frameNum = startFrame;
    }
    else{
      if((state & 1) == 1){
        saw.freq(100);
        state|=88;
        deathTime++;
        speed = 0;
        frameNum = 10;
        if(deathTime >= 60){
          deathTime = 0;
          flashCount++;
        }
        if(deathTime >= 15 && deathTime <= 20 && (arrowPos[0] & -128) == 0)
          saw.play();
        else
          saw.stop();
        if(flashCount >= 4){
          saw.stop();
          state&=126;
          deathTime = 0;
          flashCount = 0;
          xPos = 100;
          yPos = 500;
          decLives(mod, (byte)1, livesCounter, size, digit, startPoint);
          if((arrowPos[0] & 4) == 0){
            arrowPos[0]|=8;
            gameOverTime = 0;
          }
          if(mod.digitEqual(time, 6, (byte)0, (byte)3)){
            time[6] = max[0];
            time[7] = max[1];
            time[8] = max[2];
          }
        }
      }
      else{
        deathTime = 0;
        flashCount = 0;
        saw.stop();
        if((state & -128) == -128){
         if((state & 32) == 32)
            frameNum = 9;
          else
            frameNum = 7;
        }
        else{
          if((state & 32) == 32)
            frameNum = 8;
          else
            frameNum = 6;
        }
      }
    }
    
    if((inputs & 12) == 0){
      if(speed > 0){
         speed-=ACC_FRICTION;
         if(speed < 0)
           speed = 0;
      }
      else if(speed < 0){
        speed+=ACC_FRICTION;
        if(speed > 0)
          speed = 0;
      }
    }
    if((inputs & 4) == 4){
      if((state & 6) != 0)
        state|=-128;
      if((state & 8) == 0){
        if((state & -128) == 0)
          speed = -BACK_X_AIR_SPEED;
        else{
          if((state & 6) != 0){
            if(speed <= 0){
              speed-=ACC_STAND_STILL;
              if(speed <= -MAX_X_SPEED)
                speed = -MAX_X_SPEED;
            }
            else
              speed-=ACC_BACK_GROUND;
          }
           else
            speed = -MAX_X_SPEED;
        }
      }
    }
    else if((inputs & 8) == 8){
      if((state & 6) != 0)
        state&=127;
      if((state & 16) == 0){
        if((state & -128) == 0){
          if((state & 6) != 0){
            if(speed >= 0){
              speed+=ACC_STAND_STILL;
              if(speed >= MAX_X_SPEED)
                speed = MAX_X_SPEED;
            }
            else
              speed+=ACC_BACK_GROUND;
          }
          else
            speed = MAX_X_SPEED;
        }
        else
          speed = BACK_X_AIR_SPEED;
      }
    }
    xPos+=speed;
    if((inputs & 17) != 0 || (state & 6) == 0){
      if((state & 64) == 0){
        if((inputs & 17) != 0){
          ySpeed = -Y_SPEED_INIT;
          if((arrowPos[0] & -128) == 0){
            saw.stop();
            sawFreqs[0] = 500;
            sawFreqs[1] = 700;
            sawFreqs[2] = 1000;
            sawFreqs[3] = 700;
            sawDurs[0] = 5;
            sawDurs[1] = 5;
            sawDurs[2] = 7;
            sawDurs[3] = 10;
            pointers[1] = 0;
            timers[1] = 0;
            arrowPos[0]|=32;
            for(int i = 4; i < 6; i++){
              sawFreqs[i] = 0;
              sawDurs[i] = 0;
            }
          }
        }
        state = (byte)((state & -39) | 96);
      }
    }
    else
       state&=-65;
    //Code for controlling motion along the y-axis
    if((state & 6) == 0 && xPos >= 0 && xPos <= 750){
      if(ySpeed <= Y_MAX_SPEED)
        ySpeed+=ACC_Y;
      else
        ySpeed = 10;
    }
    else
      ySpeed = 0;

    if((state & 32) == 32){
      if(ySpeed >= 0 || (inputs & 17) == 0){
        state&=-33;
        ySpeed = 0;
      }
    }
    yPos+=ySpeed;
    if((state & 1) == 0 || (deathTime >= 15 && deathTime <= 30))
      frames[frameNum].draw(xPos, yPos);
  }
  void setLives(byte newLife){
    lives = newLife;
  }
  void setState(byte newState){
    state = newState;
  }

  void incLives(TextMod mod, byte incAmount, char[] livesCounter, byte size, byte digit, int startPoint){
    if(incAmount > 9)
      incAmount = 9;
    if(digit > 15)
      digit = 15;
    incAmount|=((digit << 4) & -16);
    mod.incrementCounter(livesCounter, incAmount, startPoint, size);
  }
  void decLives(TextMod mod, byte decAmount, char[] livesCounter, byte size, byte digit, int startPoint){
    if(decAmount > 9)
      decAmount = 9;
    if(digit > 15)
      digit = 15;
    decAmount|=((digit << 4));
    mod.decrementCounter(livesCounter, decAmount, startPoint, size);
  }
  byte returnLives(){
    return lives;
  }
  byte returnState(){
     return state; 
  }
  //Tracks what the x and y-position on the next frame will be
  float returnNextX(){
    return xPos+speed;
  }
  float returnNextY(){
    return yPos+ySpeed;
  }
  
  //Getter and mutator functions for the death timer
  int returnDeathTime(){
    return deathTime*flashCount;
  }
  void resetDeathTime(){
    deathTime = 0;
    flashCount = 0;
  }
  
  //Returns the whole number portion of the speed
  float returnXSpeed(){
    return speed;
  }
  float returnYSpeed(){
    return ySpeed;
  }
  
  //Sets the speeds
  void setXSpeed(float newSpeed){
    speed = newSpeed;
  }
  void setYSpeed(float newSpeed){
    ySpeed = newSpeed;
  }
  
}
