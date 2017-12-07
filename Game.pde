import processing.video.*;

Mover mover;
PImage processedImg;
PGraphics backScore;
PGraphics topView;
PGraphics scores;
PGraphics barChart;
PGraphics video;
Cylinder cylinder = new Cylinder();
Scores score;
HScrollbar2 scrollBar;
ArrayList<Float> allScores = new ArrayList();

Movie cam;
PVector rotation;
PImage img;
List<PVector> quads;
HoughTransform h = new HoughTransform();

float boxSide = 400;
float boxThickness = 10;
float sphereRadius = 20;
float limitAngle = PI/6;
ArrayList<PVector> cylinders = new ArrayList();
float scoreTot = 0;
float lastScore = 0;

float rotX = 0;
float rotZ = 0;
float speed = 0.5;

float topViewWidth;
float topViewHeight;

int barChartHeight;
int barChartWidth;

double startWidth;
double startHeight;

ImageProcessing imgproc;

PVector rot = new PVector(0, 0, 0);

//set rendering mode
void settings() {
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
  size(700, 700, P3D);
}

//define initial environment properties
void setup() {
  cam = new Movie(this, "testvideo.avi"); //Put the video in the same directory
  cam.loop();

  /*
  String[] cameras = Capture.list();
   if (cameras.length == 0) {
   println("There are no cameras available for capture.");
   exit();
   } else {
   println("Available cameras:");
   for (int i = 0; i < cameras.length; i++) {
   println(cameras[i]);
   }
   
   cam = new Capture(this, cameras[1]);
   cam.start();
   
   }*/

  startWidth = width;
  startHeight = height;
  noStroke();
  score = new Scores();
  mover = new Mover();
  backScore = createGraphics(width, height/5, P2D);
  topView = createGraphics(height/6, height/6, P2D);
  scores = createGraphics(width/6, height/6, P2D);
  barChartHeight = 3*height/24;
  barChartWidth = 36*width/60;
  barChart = createGraphics(barChartWidth, barChartHeight);
  scrollBar = new HScrollbar2(-17*width/60 + height/6, 53*height/120, barChartWidth, barChartHeight/3);

  video = createGraphics(200, 150, P2D);

  imgproc = new ImageProcessing();
  String []args = {"Image processing window"};
  // PApplet.runSketch(args, imgproc);

  missile = loadShape("missile.obj");
  missile.rotateX(PI);
  missile.rotateY(PI/2);
  missile.translate(0, -2.5, 0);
  missile.scale(22);
}

void draw() { 
  lights();
  //directionalLight(200, 20, 25, 0, 1, 0);
  //directionalLight(50, 100, 125, 0, -1, 0);
  //ambientLight(102, 102, 102);
  background(200);
  translate(width/2, height/2, 0);

  if (cam.available() == true) {
    cam.read();
  }
  img = cam.get();
  // quads = imgproc.processIm(img);
  processedImg = imgproc.processIm(img).get();

  image(video, -width/2, -height/2);
  drawVideo();


  //draw all the score related elements + topView
  drawBackScore();
  image(backScore, -width/2, 3*height/10);

  drawTopView();
  topViewWidth = -29*width/60;
  topViewHeight = 19*height/60;
  image(topView, topViewWidth, topViewHeight);

  pushStyle();
  drawScores();
  stroke(0);
  scores.stroke(0);
  image(scores, -28*width/60 + height/6, 19*height/60);
  popStyle();

  score.drawBarChart();
  image(barChart, -17*width/60 + height/6, 19*height/60);

  drawScrollBar(); 

  //add cylinders in the game using shift mode
  if (keyPressed && key == CODED && keyCode == SHIFT) {
    pushStyle();
    fill(255, 255, 255);
    rect(-boxSide/2, -boxSide/2, boxSide, boxSide);
    fill(0);
    ellipse(mover.location.x, mover.location.z, sphereRadius*2, sphereRadius*2);
    popStyle();
    cylinder.displayCylHere();
    cylinder.display();
  } else {

    //compute rotation values
    if (imgproc.getRotation() != null) {
      rot = imgproc.getRotation();
    }
    float rz = map(rot.z, 0, height, 0, PI);
    float rx = map(rot.x, 0, width, 0, PI);
    //keep rotation angle below limitAngle
    if (rz > limitAngle) {
      rz = limitAngle;
    }
    if (rz < -limitAngle) {
      rz = -limitAngle;
    }
    if (rx > limitAngle) {
      rx = limitAngle;
    }
    if (rx < -limitAngle) {
      rx = -limitAngle;
    }

    rotateX(rot.x);
    rotateZ(rot.z);

    //draw the box
    pushStyle();
    fill(115, 250, 70);
    box(boxSide, boxThickness, boxSide);
    popStyle();
    windowSizeChanged();
    cylinder.drawCylinders();

    //move the sphere
    mover.checkEdges((boxSide/2)-sphereRadius, (boxSide/2)-sphereRadius);
    mover.checkCylinderCollision();
    //mover.update(rx, rz);
    mover.update(rot.x, rot.z);
    mover.display();
  }
}

//change rotation using mouseDragged
void mouseDragged() {
  if (!scrollBar.mouseOver && !scrollBar.isScrolling) {
    rotZ += speed * (mouseX - pmouseX);
    rotX -= speed * (mouseY - pmouseY);
    scrollBar.isMovingBox = true;
  }
}

//change speed of rotation using mouseWheel
void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  speed += e/100;
  //keep speed between 0.2 - 2
  if (speed < 0.2) {
    speed = 0.2;
  }
  if (speed > 2) {
    speed = 2;
  }
}

void mouseClicked() {
  boolean spaceFree = true;
  double spaceCyl;
  double spaceSph = Math.sqrt(Math.pow(mouseX -(mover.location.x+width/2), 2)+Math.pow(mouseY -(mover.location.z+height/2), 2));

  //add cylinder in the table of cylinders if all conditions are ok (not on the sphere, not on a cylinder, not out of the box)
  if (keyPressed && key == CODED && keyCode == SHIFT) {
    for (int i = 0; i < cylinders.size(); ++i) {
      spaceCyl = Math.sqrt(Math.pow(mouseX-(cylinders.get(i).x+width/2), 2)+Math.pow(mouseY-(cylinders.get(i).z+height/2), 2));
      if (spaceCyl < cylinderBaseSize*2) {
        spaceFree = false;
      }
    }
    if (spaceSph < cylinderBaseSize + sphereRadius) { 
      spaceFree = false;
    }
    if (spaceFree && !(mouseX+cylinderBaseSize-width/2 > boxSide/2) && !(mouseX-cylinderBaseSize-width/2 < -boxSide/2) && !(mouseY+cylinderBaseSize-height/2 > boxSide/2) && !(mouseY-cylinderBaseSize-height/2 < -boxSide/2)) {
      cylinders.add(new PVector(mouseX-width/2, 0, mouseY-height/2));
    }
  }
}
//method to draw the background for scores, topView, graph, scrollBar
void drawBackScore() {
  backScore.beginDraw();
  backScore.background(250, 220, 111);
  backScore.endDraw();
}
//method to draw topView
void drawTopView() {
  topView.beginDraw();
  topView.background(3, 6, 134);
  topView.fill(248, 252, 31);
  topView.ellipse(((mover.location.x)*(height/(6*boxSide))) + height/12, ((mover.location.z)*(height/(6*boxSide))) + height/12, sphereRadius/2, sphereRadius/2);

  for (int i = 0; i < cylinders.size(); ++i) {
    topView.fill(238, 112, 252);
    topView.ellipse(((cylinders.get(i).x)*(height/(6*boxSide))) + height/12, ((cylinders.get(i).z)*(height/(6*boxSide))) + height/12, 6*cylinderBaseSize/10, 6*cylinderBaseSize/10);
  }
  topView.endDraw();
}
//method to draw the scores
void drawScores() {
  scores.beginDraw();
  scores.background(250, 220, 111);
  scores.stroke(0);
  scores.strokeWeight(5);
  scores.strokeJoin(ROUND);
  scores.fill(87, 234, 242);
  scores.rect(0, 0, scores.width, scores.height, 20);
  scores.textSize(10);
  scores.fill(0);
  scores.text("Total score: " + scoreTot, 5, 30);
  if (mover.velocity.mag() > 0.045) { 
    scores.text("Velocity: " + mover.velocity.mag(), 5, 50);
  } else {
    scores.text("Velocity: " + 0.000, 5, 50);
  }
  scores.text("Last score: " + lastScore, 5, 70);
  scores.endDraw();
}
//method to refresh values if the size of the window changes 
void windowSizeChanged() {
  if (width!=startWidth || height != startHeight) {
    startWidth = width;
    startHeight = height;
    backScore = createGraphics(width, height/5, P2D);
    topView = createGraphics(height/6, height/6, P2D);
    scores = createGraphics(width/6, height/6, P2D);
    barChartHeight = 3*height/24;
    barChartWidth = 36*width/60;
    barChart = createGraphics(barChartWidth, barChartHeight);
    scrollBar = new HScrollbar2(-17*width/60 + height/6, 53*height/120, barChartWidth, barChartHeight/3);
  }
}

void drawVideo() { 
  video.beginDraw();
  processedImg.resize(200, 150);
  video.image(processedImg, 0, 0);
  video.endDraw();
}