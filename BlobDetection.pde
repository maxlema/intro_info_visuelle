import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    // First pass: label the pixels and store labels’ equivalences
    int [] labels= new int [input.width*input.height];
    for (int x = 0; x < input.width; ++x) {
      labels[x] = 0;
    }
    for (int y = 0; y < input.height; ++y) {
      labels[y*input.width] = 0;
    }
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
    labelsEquivalences.add(new TreeSet());
    labelsEquivalences.add(new TreeSet());
    labelsEquivalences.get(1).add(1);

    int currentLabel=1;

    
      for (int y = 1; y < input.height; ++y) {
        for (int x = 1; x < input.width; ++x) {
        if (input.pixels[y*input.width+x] == color(0)) {
          labels[y*input.width+x] = 0;
        } else {
          int min = input.width*input.height;
          int[] vals = new int[4];
          vals[0] = labels[(y-1)*input.width + x-1];
          vals[1] = labels[(y-1)*input.width + x];
          vals[2] = labels[(y-1)*input.width + x+1];
          vals[3] = labels[y*input.width + x-1];
          for (int i = 0; i < vals.length; ++i) {
            if (vals[i]!=0) {
              if (vals[i] < min) {
                min = vals[i];
              }
              for (int j = i+1; j < vals.length; ++j) {
                if (vals[j] != 0 && vals[i]!=vals[j]) {
                  labelsEquivalences.get(vals[i]).addAll(labelsEquivalences.get(vals[j]));
                  labelsEquivalences.get(vals[j]).addAll(labelsEquivalences.get(vals[i]));
                }
              }
            }
          }
          if (min < input.width*input.height) {
            labels[y*input.width+x] = min;
          } else {
            labels[y*input.width+x] = currentLabel;
            labelsEquivalences.add(new TreeSet());
            labelsEquivalences.get(currentLabel).add(currentLabel);
            currentLabel += 1;
          }
        }
      }
    }

    // Second pass: re-label the pixels by their equivalent class
    // if onlyBiggest==true, count the number of pixels for each label
    int[] blobSize = new int[input.width*input.height];
    for (int x = 1; x < input.width; ++x) {
      for (int y = 1; y < input.height; ++y) {
        if (labels[y*input.width+x] != 0) {
          int curLab = labels[y*input.width+x];
          //int labEq = labelsEquivalences.get(labels[y*input.width+x]).first();
          int labEq = labelsEquivalences.get(curLab).first();
          if (curLab != 0 && labEq < curLab) {
            labels[y*input.width+x] = labEq;
          }
          blobSize[labEq] += 1;
        }
      }
    }


    // Finally,
    // if onlyBiggest==false, output an image with each blob colored in one uniform color
    // if onlyBiggest==true, output an image with the biggest blob colored in white and the others in black

    PImage result = createImage(input.width, input.height, RGB);
    int biggest = 1;
    int bigIndex = 1;
    for (int i = 1; i < input.width*input.height; ++i) {
      if (blobSize[i] > biggest) {
        biggest = blobSize[i];
        bigIndex = i;
      }
    }
    for (int x = 0; x < input.width; ++x) {
      for (int y = 0; y < input.height; ++y) {
        if (onlyBiggest) {
          if (labels[y*result.width+x] == bigIndex) {
            result.pixels[y*result.width+x] = color(100, 255, 100);
          } else {
            result.pixels[y*result.width+x] = color(0, 0, 0);
          }
        } else {
          result.pixels[y*result.width+x] = color((255-labels[y*result.width+x]*10)%255, (255-labels[y*result.width+x]*40)%255, (255-labels[y*result.width+x]*20)%255);
        }
      }
    }

    return result;
  }
}