class BoardDetection {

  PImage thresholdUp(PImage img, int threshold) {
    // create a new, initially transparent, ’result’ image
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if ((threshold <= brightness(img.pixels[i]))) {
        result.pixels[i] = color(255, 255, 255);
      } else {
        result.pixels[i] = color(0, 0, 0);
      }
    }
    return result;
  }

  PImage thresholdDown(PImage img, int threshold) {
    // create a new, initially transparent, ’result’ image
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      if (!(threshold <= brightness(img.pixels[i]))) {
        result.pixels[i] = color(255, 255, 255);
      } else {
        result.pixels[i] = color(0, 0, 0);
      }
    }
    return result;
  }

  PImage hueImg(PImage img, float min, float max) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      float hueP = hue(img.pixels[i]);
      if (min <= hueP && hueP <= max) {
        result.pixels[i] = img.pixels[i];
      } else { 
        result.pixels[i] = color(0, 0, 0);
      }
    }
    return result;
  }

  PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      float pixH = hue(img.pixels[i]);
      float pixS = saturation(img.pixels[i]);
      float pixB = brightness(img.pixels[i]);
      if (minH <= pixH && pixH <= maxH && minS <= pixS && pixS <= maxS && minB <= pixB && pixB <= maxB)
        result.pixels[i] = color(255, 255, 255);
      else
        result.pixels[i] = color(0, 0, 0);
    }
    return result;
  }

  /*boolean imagesEqual(PImage img1, PImage img2) {
   if (img1.width != img2.width || img1.height != img2.height) 
   return false;
   for (int i = 0; i < img1.width*img1.height; i++)
   //assuming that all the three channels have the same value
   if (red(img1.pixels[i]) != red(img2.pixels[i])) {
   //println("Pixel " + i);
   return false;
   }
   return true;
   }*/

  PImage convolute(PImage img) {
    float[][] kernel = { 
      { 9, 12, 9 }, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }};
    float normFactor = 99.f; //1.f;
    int N = 3; //N is kernel size
    PImage result = createImage(img.width, img.height, ALPHA);
    for (int x = 1; x < img.width-1; ++x) {
      for (int y = 1; y < img.height-1; ++y) {
        int tot = 0;
        int xMat = 0;
        for (int xPix = x-N/2; xPix <= x+N/2; ++xPix) {
          int yMat = 0;
          for (int yPix = y-N/2; yPix <= y+N/2; ++yPix) {
            tot += brightness(img.pixels[yPix * img.width + xPix])*kernel[xMat][yMat];
            yMat++;
          }
          xMat++;
        }
        result.pixels[y * img.width + x] = color((int) (tot/normFactor));
      }
    }
    return result;
  }

  PImage scharr(PImage img) {
    float[][] vKernel = {
      { 3, 0, -3 }, 
      { 10, 0, -10 }, 
      { 3, 0, -3 } };
    float[][] hKernel = {
      { 3, 10, 3 }, 
      { 0, 0, 0 }, 
      { -3, -10, -3 } };
    int N = 3; //N is kernel size !
    float normFactor = 1.f;
    PImage result = createImage(img.width, img.height, ALPHA);

    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max = 0;
    float[] buffer = new float[img.width * img.height];
    // *************************************
    for (int x = 1; x < img.width-1; ++x) {
      for (int y = 1; y < img.height-1; ++y) {
        int sum_v = 0;
        int sum_h = 0;
        int xMat = 0;
        for (int xPix = x-N/2; xPix <= x+N/2; ++xPix) {
          int yMat = 0;
          for (int yPix = y-N/2; yPix <= y+N/2; ++yPix) {
            sum_v += (brightness(img.pixels[yPix * img.width + xPix])*vKernel[xMat][yMat])/normFactor;
            sum_h += (brightness(img.pixels[yPix * img.width + xPix])*hKernel[xMat][yMat])/normFactor;
            yMat++;
          }
          xMat++;
        }
        float sum = sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        if (sum > max) max = sum;
        buffer[y * img.width + x] = sum;
      }
    }
    // *************************************
    for (int y = 2; y < img.height - 2; y++) { // Skip top and bottom edges
      for (int x = 2; x < img.width - 2; x++) { // Skip left and right
        int val=(int) ((buffer[y * img.width + x] / max)*255);
        result.pixels[y * img.width + x]=color(val);
      }
    }
    return result;
  }
}