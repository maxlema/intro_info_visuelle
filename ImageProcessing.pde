import processing.video.*;
import gab.opencv.*;
class ImageProcessing {
  Capture cam;

  OpenCV opencv;
  PImage img;
  PImage imgThresholded;
  PImage imgBlurred;
  List<PVector> list;
  BoardDetection detection = new BoardDetection();
  QuadGraph quadG = new QuadGraph();
  HScrollbar thresholdBar1;
  HScrollbar thresholdBar2;
  BlobDetection blob = new BlobDetection();
  HoughTransform h = new HoughTransform();
  TwoDThreeD t = new TwoDThreeD(800, 600, 30);  

  /*void settings() {
   System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
   size(1280, 480);
   }
   void setup() {
   String[] cameras = Capture.list();
   if (cameras.length == 0) {
   println("There are no cameras available for capture.");
   exit();
   } else {
   println("Available cameras:");
   for (int i = 0; i < cameras.length; i++) {
   println(cameras[i]);
   }
   cam = new Capture(this, cameras[4]);
   cam.start();
   }
   //img = loadImage("board4.jpg");
   //opencv = new OpenCV(this, 100, 100);
   
   //thresholdBar1 = new HScrollbar(0, 419, 640, 30);
   //thresholdBar2 = new HScrollbar(0, 450, 640, 30);
   }
   void draw() {
   if (cam.available() == true) {
   cam.read();
   }*/

  PGraphics processIm(PImage img) {
    // img = cam.get();

    PGraphics vid = createGraphics(img.width, img.height);

    //PImage img2 = detection.thresholdHSB(img, 80, 150, 80, 255, 30, 180);
    PImage img2 = detection.thresholdHSB(img, 80, 130, 43, 255, 50, 250);

    PImage img3 = blob.findConnectedComponents(img2, true);

    PImage img4 = detection.convolute(img3);

    PImage img5 = detection.scharr(img4);

    PImage img6 = detection.thresholdUp(img5, 50);

    list = h.hough(img6);  

    // image(img, 0, 0);
    //h.plotLines(list, img6);

    // image(img2, img.width, 0);
    //image(img3, img.width, 0);
    //image(img5, 2*img.width, 0);

    List<PVector> quad = quadG.findBestQuad(list, img.width, img.height, img.height*img.height, 25, false);
    /*
    for (int i = 0; i < quad.size(); ++i) {
     pushStyle();
     fill(0);
     ellipse(quad.get(i).x, quad.get(i).y, 15, 15);
     popStyle();
     }
     */
    for (int i = 0; i < quad.size(); ++i) {
      quad.get(i).z = 1;
    }
    if (quad.size()>=4) {
      rotation = t.get3DRotations(quad);
      rotation.x+=PI;

      //println("rx = " + degrees(rotation.x));
      //println("ry = " + degrees(rotation.y));
      // println("rz = " + degrees(rotation.z));
    }
    /*
    thresholdBar1.display();
     thresholdBar1.update();
     thresholdBar2.display();
     thresholdBar2.update();
     */

    vid.beginDraw();
    vid.image(img, 0, 0);

    //draw the lines
    h.plotLines(list, img, vid);

    //draw the corners
    for (int i = 0; i < quad.size(); ++i) {
      vid.pushStyle();
      vid.fill(color(220, 30, 30));
      vid.ellipse(quad.get(i).x, quad.get(i).y, 50, 50);
      vid.popStyle();
    }

    vid.endDraw();

    return vid;
  }


  PVector getRotation() {
    return rotation;
  }

  List<PVector> getList() {
    return list;
  }
}