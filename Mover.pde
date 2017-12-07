class Mover {
  PVector location;
  PVector velocity;
  PVector gravityForce;
  PVector friction;

  final float normalForce = 1;
  float mu = 0.01;
  float frictionMagnitude = normalForce * mu;
  final float gravityConstant = 0.1; //9.81;

  final double minVelocity = 0.1;

  //mover builder of the sphere
  Mover() {
    location = new PVector(0, -25, 0);
    velocity = new PVector(0, 0, 0);
    gravityForce = new PVector(0, 0, 0);
    friction = new PVector(0, 0, 0);
  }

  //update PVectors of the sphere
  void update(float rx, float rz) {
    friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    gravityForce.x = sin(rz)*gravityConstant;
    gravityForce.z = -sin(rx)*gravityConstant;
    velocity.add(gravityForce);
    velocity.add(friction);
    location.add(velocity);
  }

  //translate the sphere using udpate location
  void display() {
    pushStyle();
    fill(70, 200, 250);
    translate(location.x, location.y, location.z);
    sphere(sphereRadius);
    popStyle();
  }

  //keep sphere on plate of width w and heigth h
  void checkEdges(float w, float h) {
    //check width
    if (location.x > w) {
      location.x = w;
      velocity.x = -abs(velocity.x);
      score.updateScore(-velocity.mag());
    } else if (location.x < -w) {
      location.x = -w;
      velocity.x = abs(velocity.x);
      score.updateScore(-velocity.mag());
    }
    //check heigth
    if (location.z > h) {
      location.z = h;
      velocity.z = -abs(velocity.z);
      score.updateScore(-velocity.mag());
    } else if (location.z < -h) {
      location.z = -h;
      velocity.z = abs(velocity.z);
      score.updateScore(-velocity.mag());
    }
  }

  //compute the collisions between the ball and the cylinders
  void checkCylinderCollision() {
    pushMatrix();
    for (int i = 0; i < cylinders.size(); ++i) {
      PVector cyl = cylinders.get(i);
      float magVelocity = velocity.mag();

      PVector futureLoc = new PVector(location.x, location.y, location.z).add(velocity);
      float norm = sqrt(pow((futureLoc.x-cyl.x), 2) + pow((futureLoc.z-cyl.z), 2));

      if (norm < cylinderBaseSize + sphereRadius && magVelocity > minVelocity) {
        PVector normal = new PVector(location.x-cyl.x, 0, location.z-cyl.z).normalize();
        velocity.sub(normal.mult(2*normal.dot(velocity)));
        score.updateScore(magVelocity);
      }
      //make sure the ball can't enter in cylinders with a small speed
      PVector futLoc = new PVector(futureLoc.x, futureLoc.y, futureLoc.z).add(velocity);
      float futNorm = sqrt(pow((futLoc.x-cyl.x), 2) + pow((futLoc.z-cyl.z), 2));
      if (norm < cylinderBaseSize + sphereRadius && magVelocity < minVelocity && futNorm < norm) {
        PVector loc = new PVector(location.x, location.y, location.z).sub(velocity);
        location = loc;
        velocity = new PVector(0, 0, 0).sub(gravityForce).sub(friction);
      }
    }
    popMatrix();
  }
}