import java.util.List;
import java.util.Collections;

class HoughTransform {

  PImage houghImg;

  List<PVector> hough(PImage edgeImg) {
    float discretizationStepsPhi = 0.06f;
    float discretizationStepsR = 2.5f;
    int minVotes=200;
    // dimensions of the accumulator
    int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
    //The max radius is the image diagonal, but it can be also negative
    int rDim = (int) ((sqrt(edgeImg.width*edgeImg.width +
      edgeImg.height*edgeImg.height) * 2) / discretizationStepsR +1);
    // our accumulator
    int[] accumulator = new int[phiDim * rDim];

    // pre-compute the sin and cos values
    float[] tabSin = new float[phiDim];
    float[] tabCos = new float[phiDim];
    float ang = 0;
    float inverseR = 1.f / discretizationStepsR;
    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }


    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {

          for (int phi = 0; phi < phiDim; ++phi) {
            //ligne avant optimisation
            int r = (int) round((x*tabCos[phi]) + (y*tabSin[phi]) + rDim/2f);
            accumulator[phi * rDim + r] += 1;
          }
        }
      }
    }
    ArrayList<PVector> lines=new ArrayList<PVector>();
    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();
    int regionSize = 1;
    for (int idx = 0; idx < accumulator.length; idx++) {
      if (accumulator[idx] > minVotes) {
        // first, compute back the (r, phi) polar coordinates:

        boolean best = true;
        int i = idx-regionSize/2;
        if (i < 0) {
          i = 0;
        }
        int j = idx+regionSize/2 + 1;
        if (j > accumulator.length) {
          j = accumulator.length;
        }
        for (int k = i; k < j; ++k) {
          if (accumulator[idx] < accumulator[i]) {
            best = false;
          }
          if (best) {
            bestCandidates.add(idx);
          }
        }
      }
    }

    Collections.sort(bestCandidates, new HoughComparator(accumulator));
    ArrayList<PVector> bestLines = new ArrayList<PVector>();
    for (int i = 0; i < 5; ++i) {
      if (i < bestCandidates.size()) {
        int idx = bestCandidates.get(i);
        int accPhi = (int) (idx / (rDim));
        int accR = idx - (accPhi) * (rDim);
        float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
        float phi = accPhi * discretizationStepsPhi;
        lines.add(new PVector(r, phi));
      }
    }

    houghImg = createImage(rDim, phiDim, ALPHA);
    for (int i = 0; i < accumulator.length; i++) {
      houghImg.pixels[i] = color(min(255, accumulator[i]));
    }
    // You may want to resize the accumulator to make it easier to see:
    houghImg.resize(400, 400);
    houghImg.updatePixels();

    return lines;
  }

  void plotLines(List<PVector> lines, PImage edgeImg, PGraphics vid) {
    for (int idx = 0; idx < lines.size(); idx++) {
      PVector line=lines.get(idx);
      float r = line.x;
      float phi = line.y;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      pushMatrix();
      translate(-width/2, -height/2);
     //x1 = x1*200/width;
     //y1 = y1*150/height;
      // Finally, plot the lines
      vid.stroke(204, 102, 0);
      if (y0 > 0) {
        if (x1 > 0)
          vid.line(x0, y0, x1, y1);
        else if (y2 > 0)
          vid.line(x0, y0, x2, y2);
        else
          vid.line(x0, y0, x3, y3);
      } else {
        if (x1 > 0) {
          if (y2 > 0)
            vid.line(x1, y1, x2, y2);
          else
            vid.line(x1, y1, x3, y3);
        } else
          vid.line(x2, y2, x3, y3);
      }
      popMatrix();
    }
  }
}