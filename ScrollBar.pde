class HScrollbar2 {
  float barWidth;  //Bar's width in pixels
  float barHeight; //Bar's height in pixels
  float xPosition;  //Bar's x position in pixels
  float yPosition;  //Bar's y position in pixels

  float sliderPosition, newSliderPosition;    //Position of slider
  float sliderPositionMin, sliderPositionMax; //Max and min values of slider

  boolean mouseOver;  //Is the mouse over the slider?
  boolean locked;     //Is the mouse clicking and dragging the slider now?
  boolean isScrolling = false;
  boolean isMovingBox = false;

  //Creates a new horizontal scrollbar
  HScrollbar2 (float x, float y, float w, float h) {
    barWidth = w;
    barHeight = h;
    xPosition = x;
    yPosition = y;

    sliderPosition = xPosition + barWidth/2 - barHeight/2;
    newSliderPosition = sliderPosition;

    sliderPositionMin = xPosition;
    sliderPositionMax = xPosition + barWidth - barHeight;
  }

  //Updates the state of the scrollbar according to the mouse movement
  void update() {
    
    if (isMouseOver()) {
      mouseOver = true;
    } else {
      mouseOver = false;
    }
    if (mousePressed && mouseOver && !isMovingBox) {
      locked = true;
      isScrolling = true;
    }
    if (!mousePressed) {
      locked = false;
      isScrolling = false;
      isMovingBox = false;
    }
    if (locked) {
      newSliderPosition = constrain(mouseX - barWidth + 5*width/60, sliderPositionMin, sliderPositionMax);
      
    }
    if (abs(newSliderPosition - sliderPosition) > 1) {
      sliderPosition = sliderPosition + (newSliderPosition - sliderPosition);
    }
  }

  //Clamps the value into the interval
  float constrain(float val, float minVal, float maxVal) {
    return min(max(val, minVal), maxVal);
  }

  //Gets whether the mouse is hovering the scrollbar
  boolean isMouseOver() {
    if (mouseX > xPosition + width/2 && mouseX < xPosition+barWidth + width/2 &&
      mouseY > yPosition + height/2 && mouseY < yPosition+barHeight + height/2) {
      return true;
    } else {
      return false;
    }
  }
  
  //Draws the scrollbar in its current state
  void display() {
    pushStyle();
    noStroke();
    fill(204);
    rect(xPosition, yPosition, barWidth, barHeight);
    if (mouseOver || locked) {
      fill(0, 0, 0);
    } else {
      fill(102, 102, 102);
    }
    rect(sliderPosition, yPosition, barHeight, barHeight);
    popStyle();
  }

  // Gets the slider position
  float getPos() {
    return (sliderPosition - xPosition)/(barWidth - barHeight);
  }
}