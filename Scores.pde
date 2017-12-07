class Scores {
  int s = 0;
  int a;
  float highScore = 0;

  //update the score if the ball touch the edges of the box, or a cylinder
  void updateScore(float magVelocity) {
    //we update only if the speed is high enough
    if (abs(magVelocity) > mover.minVelocity + 0.3) {
      lastScore = magVelocity;
      scoreTot+=lastScore;
      if (scoreTot > highScore) {
        highScore = scoreTot;
      }
    }
  }

  //draw the graph of the score
  void drawBarChart() {
    s = second();
    float squareSize = 10*(scrollBar.getPos() + width/5000) + 1;
    float space = 2*(scrollBar.getPos() + width/5000);
    float squareValue = squareSize*highScore/(barChartHeight-5*space); 

    //stop the graph when press shift
    if (a!=s && !(keyPressed && key == CODED && keyCode == SHIFT)) {
      a = s;
      allScores.add(scoreTot);
    }

    barChart.beginDraw();
    barChart.background(250, 243, 183);
    
    //draw columns of square to symbolise the score, change column every second
    for (int i = 0; i < allScores.size(); ++i) {
      float score = allScores.get(i);
      for (int j = 0; score > 0; j+= (squareSize)) {
        if (squareValue == 0) {
          squareValue = .1;
        }
        score -= squareValue;
        barChart.rect(i*(squareSize+space), barChartHeight-j, squareSize-space, squareSize-space);
      }
    }
    barChart.endDraw();
  }
}

// draw the scrollBar
void drawScrollBar() {
  scrollBar.update();
  scrollBar.display();
}