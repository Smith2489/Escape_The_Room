class Graphics{
  PGraphics image = (PGraphics)null;
  Graphics(PImage graphic){
    image = createGraphics(graphic.width, graphic.height);
    image.noSmooth();
    image.beginDraw();
    image.background(0xFFFF00FF);
    image.image(graphic, 0, 0);
    image.loadPixels();
    for(int i = 0; i < graphic.height; i++){
      for(int j = 0; j < graphic.width; j++){
         int pixelPos = j+graphic.width*i; 
         if(((image.pixels[pixelPos] >>> 16) & 0xFF) == 255 && ((image.pixels[pixelPos] >>> 8) & 0xFF) == 0 && (image.pixels[pixelPos] & 0xFF) == 255)
            image.pixels[pixelPos] = 0x00FFFFFF;
      }
    }
    image.updatePixels();
    image.endDraw();
  }
  Graphics(PImage graphic, short[] minRemoval, short[] maxRemoval){
    image = createGraphics(graphic.width, graphic.height);
    image.noSmooth();
    image.beginDraw();
    image.background(minRemoval[0], minRemoval[1], minRemoval[2]);
    image.image(graphic, 0, 0);
    image.loadPixels();
    for(int i = 0; i < graphic.height; i++){
      for(int j = 0; j < graphic.width; j++){
         int pixelPos = j+graphic.width*i; 
         int[] brokenUpColour = {(image.pixels[pixelPos] >>> 16) & 0xFF,
                                 (image.pixels[pixelPos] >>> 8) & 0xFF,
                                 image.pixels[pixelPos] & 0xFF};
         if(brokenUpColour[0] >= minRemoval[0] && brokenUpColour[0] <= maxRemoval[0] && brokenUpColour[1] >= minRemoval[1] && brokenUpColour[1] <= maxRemoval[1] && brokenUpColour[2] >= minRemoval[2] && brokenUpColour[2] <= maxRemoval[2])
           image.pixels[pixelPos] = 0x00FFFFFF;
      }
    }
    image.updatePixels();
    image.endDraw();
    
  }
  Graphics(PImage graphic, short[] minRemoval, short[] maxRemoval, boolean hasInvisPixels, boolean smooth){
    image = createGraphics(graphic.width, graphic.height);
    if(smooth)
      image.smooth();
    else
      image.noSmooth();
        image.beginDraw();
    image.background(minRemoval[0], minRemoval[1], minRemoval[2]);
    image.image(graphic, 0, 0);
    image.loadPixels();
    if(hasInvisPixels){
      for(int i = 0; i < graphic.height; i++){
        for(int j = 0; j < graphic.width; j++){
           int pixelPos = j+graphic.width*i; 
           int[] brokenUpColour = {(image.pixels[pixelPos] >>> 16) & 0xFF,
                                   (image.pixels[pixelPos] >>> 8) & 0xFF,
                                   image.pixels[pixelPos] & 0xFF};
           if(brokenUpColour[0] >= minRemoval[0] && brokenUpColour[0] <= maxRemoval[0] && brokenUpColour[1] >= minRemoval[1] && brokenUpColour[1] <= maxRemoval[1] && brokenUpColour[2] >= minRemoval[2] && brokenUpColour[2] <= maxRemoval[2])
             image.pixels[pixelPos] = 0x00FFFFFF;
        }
      }
    }
    if(smooth){
      for(int i = 0; i < graphic.height; i++){
        for(int j = 0; j < graphic.width; j++){
          int[][] colours = {getColour(image.pixels, Math.max(j-1, 0), Math.max(i-1, 0), graphic.width), getColour(image.pixels, j, Math.max(i-1, 0), graphic.width), getColour(image.pixels, Math.min(j+1, graphic.width), Math.max(i-1, 0), graphic.width),
                             getColour(image.pixels, Math.max(j-1, 0), i, graphic.width), getColour(image.pixels, j, i, graphic.width), getColour(image.pixels, Math.min(j+1, graphic.width), i, graphic.width),
                             getColour(image.pixels, Math.max(j-1, 0), Math.min(i+1, graphic.height), graphic.width), getColour(image.pixels, j, Math.min(i+1, graphic.height), graphic.width), getColour(image.pixels, Math.min(j+1, graphic.width), Math.min(i+1, graphic.height), graphic.width)};
          int[] brokenUpColour = {image.pixels[i*graphic.width+j] >>> 24,
                                  colours[0][1]+colours[1][1]+colours[2][1]+colours[3][1]+colours[4][1]+colours[5][1]+colours[6][1]+colours[7][1]+colours[8][1],
                                  colours[0][2]+colours[1][2]+colours[2][2]+colours[3][2]+colours[4][2]+colours[5][2]+colours[6][2]+colours[7][2]+colours[8][2],
                                  colours[0][3]+colours[1][3]+colours[2][3]+colours[3][3]+colours[4][3]+colours[5][3]+colours[6][3]+colours[7][3]+colours[8][3]};
           brokenUpColour[1] = (int)Math.min(255, brokenUpColour[1]*0.11111111111111111f);
           brokenUpColour[2] = (int)Math.min(255, brokenUpColour[2]*0.11111111111111111f);
           brokenUpColour[3] = (int)Math.min(255, brokenUpColour[3]*0.11111111111111111f);
           image.pixels[i*graphic.width+j] = (brokenUpColour[0] << 24)|(brokenUpColour[1] << 16)|(brokenUpColour[2] << 8)|brokenUpColour[3]; 
        }
      }
    }
    image.updatePixels();
    image.endDraw();
  }
  private int[] getColour(int[] pixels, int x, int y, int wid){
    int pixelPos = x+wid*y;
    int[] brokenUpColour = {pixels[pixelPos] >>> 24,
                           (pixels[pixelPos] >>> 16) & 0xFF,
                           (pixels[pixelPos] >>> 8) & 0xFF,
                            pixels[pixelPos] & 0xFF};
    if(brokenUpColour[0] <= 0){
       brokenUpColour[0] = 0;
       brokenUpColour[1] = 0;
       brokenUpColour[2] = 0;
       brokenUpColour[3] = 0;
    }
    return brokenUpColour;
  }
  
  void draw(float x, float y){
    image(image, x, y);
  }
  
  void draw(float x, float y, int wid, int heig){
    if(wid > 0 && heig > 0)
      image(image, x, y, wid, heig);
    else{
      int xDir = (wid < 0) ? -1 : 1;
      int yDir = (heig < 0) ? -1 : 1;
      scale(xDir, yDir);
      if(xDir < 0)
        x-=wid;
      if(yDir < 0)
        y-=heig;
      image(image, x*xDir, y*yDir, Math.abs(wid), Math.abs(heig));
      scale(xDir, yDir);
    }
  }
  
  
  
}
