float cylinderBaseSize = 25;
float cylinderHeight = 50;
int cylinderResolution = 80;
PShape missile; 

class Cylinder {

  PShape openCylinder = new PShape();

  PShape cylinder() {
    float angle;
    float[] x = new float[cylinderResolution + 1];
    float[] y = new float[cylinderResolution + 1];

    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / cylinderResolution) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], -5, y[i]);
      openCylinder.vertex(x[i], -cylinderHeight, y[i]);
    }
    //draw the top and bottom of the cylinder
    for (int i = 0; i < x.length; ++i) {
      openCylinder.vertex(0, -5, 0);
      openCylinder.vertex(x[i], -5, y[i]);
      openCylinder.vertex(0, -cylinderHeight, 0);
      openCylinder.vertex(x[i], -cylinderHeight, y[i]);
    }

    openCylinder.endShape();

    return openCylinder; // return a PSshape we can draw afterwards
  }

  //draw the sphere around the mouse in shift mode
  void display() {
    translate(mouseX-width/2, mouseY-height/2);
    pushStyle();
    fill(0);
    ellipse(0, 0, cylinderBaseSize*2, cylinderBaseSize*2);
    popStyle();
  }

  //draw all the cylinders from the table in the shift mode
  void displayCylHere() {   
    pushStyle();
    fill(255, 0, 255); 
    for (int i = 0; i < cylinders.size(); ++i) {
      pushMatrix();
      translate(cylinders.get(i).x, cylinders.get(i).z, 0);
      ellipse(0, 0, cylinderBaseSize*2, cylinderBaseSize * 2);
      popMatrix();
    } 
    popStyle();
  }

  //draw all the cylinders in the table in the normal mode
  void drawCylinders() {
    for (int i = 0; i < cylinders.size(); ++i) {
      PVector cyl = cylinders.get(i);
      pushMatrix();
      translate(cyl.x, 0, cyl.z);
      shape(missile);
      popMatrix();
    }
  }
}