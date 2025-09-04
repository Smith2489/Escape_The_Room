class TextMod{
  //Increments a counter that is stored as an array of bytes and immediately converts it into the characters for that value
  void incrementCounter(char[] num, byte val, int startIndex, byte size){
      if(size > 16)
          size = 16;
      //First nibble of val stores the index (backwards), second nibble stores the increment value
      if((val & 15) > 9)
          val = (byte)((val & -16) + 9);
      //Limits the index
      val = (byte)((val & 15) | (((size-((val >> 4) & 15) - 1) << 4) & -16));
      if(((val >> 4) & 15) >= size)
          val = (byte)((val & 15) | (((size-1) << 4) & -16));
      else if(((val >> 4) & 15) < 0)
          val = (byte)(val & 15);
      //Sets a digit that is a character that is less than 48 (0) to 48; same thing for digits that are greater than 57 (9)
      startIndex+=((val >> 4) & 15);
      if(num[startIndex] < 48)
          num[startIndex] = 48;
      if(num[startIndex] > 57)
          num[startIndex] = 57;
      //Adds the actual value and performs any necessary carries
      num[startIndex]+=(val & 15);
      while(num[startIndex] >= 58){
          num[startIndex] = (char)(num[startIndex]-10);
          if(((val >> 4) & 15) > 0 && startIndex > 0)
              num[startIndex-1]++; 
          val-=16;
          if(startIndex > 0)
            startIndex--;
      }
  }
  
  //Decrements a counter that is stored as an array of bytes and immediately converts it into the characters for that array
  void decrementCounter(char[] num, byte val, int startIndex, byte size){
      if(size > 16)
          size = 16;
      //First nibble of val stores the index (backwards), second nibble stores the decrement value
      if((val & 15) > 9)
          val = (byte)((val & -16) + 9);
      //Extracts the index and limits it
      byte index = (byte)((size-((val >> 4) & 15)-1));
      if(index >= size)
          index = (byte)(size-1);
      else if(index < 0)
          index = 0;
      //Set a digit that is less than 48 (0) to 48; same thing for digits that are greater than 57 (9)
      if(num[index+startIndex] < 48)
          num[index+startIndex] = 48;
      if(num[index+startIndex] > 57)
          num[index+startIndex] = 57;
      //Copies the current index from the lower half to the upper half; do the same for the decrement value
      index|=((index << 4) & -16);
      val = (byte)((val & 15) | ((val << 4) & -16));
      //Higher nibble in val now stores the target value
      /*
      Runs through the array and subtracts one from the higher digits if the difference between the digit of focus and the
      decrement value is less than zero; Modifies the target value to be 1; Adds 10 to the digit of focus
      */
      while((index & 15) > 0){
          if(num[(index & 15)+startIndex]-48 < ((val >> 4) & 15)){
              num[(index & 15)+startIndex]+=10;
              num[(index & 15)-1+startIndex]--;
              val = (byte)((val & 15) | ((((num[(index & 15)-1+startIndex] < 48) ? 1 : 0) << 4) & -16));
          }
          else
            break;
          index--;
      }
      //Subtracts the decrement value from the target digit and sets any digits that are greater than 9 or less than 0 to 9
      num[((index >> 4) & 15)+startIndex]-=(val & 15);
      for(int i = 0; i < size; i++){
          if(num[i+startIndex] > 57)
              num[i+startIndex] = 57;
          else if(num[i+startIndex] < 48){
              for(int j = 0; j < size; j++)
                  num[j+startIndex] = 57;
              return;
          }
      }
  }
  
  boolean digitEqual(char[] num, int startIndex, byte compVal, byte size){
    for(int i = startIndex; i < startIndex+size; i++){
      if(num[i]-48 != compVal)
        return false;
    }
    return true;
  }
  
  //Locks an incremented number to the maximum number of 9s
  void lockInc(char[] num, byte val, int startIndex, byte size){
    char[] initNum = new char[size];
    char[] secondNum = new char[size];
    for(byte i = 0; i < size; i++){
      initNum[i] = num[startIndex+i];
      secondNum[i] = num[startIndex+i];
    }
    incrementCounter(secondNum, val, 0, size);
    for(byte i = 0; i < size; i++){
      if(i > 0 && secondNum[i-1] > num[i-1])
        continue;
      if(secondNum[i] < initNum[i] && ((i > 0 && secondNum[i-1] == num[i-1]) || i <= 0)){
        for(byte j = 0; j < size; j++){
            num[startIndex+j] = '9';
        }
        return;
      }
      num[i+startIndex] = secondNum[i];
    }
  }
  
  //Locks a decremented number to the maximum number of 0s
  void lockDec(char[] num, byte val, int startIndex, byte size){
    char[] initNum = new char[size];
    char[] secondNum = new char[size];
    for(byte i = 0; i < size; i++){
      initNum[i] = num[startIndex+i];
      secondNum[i] = num[startIndex+i];
    }
    decrementCounter(secondNum, val, 0, size);
    for(byte i = 0; i < size; i++){
      if(secondNum[i] > initNum[i] && ((i > 0 && secondNum[i-1] == num[i-1]) || i <= 0)){
        for(byte j = 0; j < size; j++){
            num[startIndex+j] = '0';
        }
        return;
      }
      num[i+startIndex] = secondNum[i];
    }
  }
}
