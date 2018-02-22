import java.util.Collections;


void drawChevron(PVector start, PVector end, float size) {
  drawChevronAt(PVector.add(end, start).div(2), PVector.sub(end, start), size);
}

void drawChevronAt(PVector at, PVector dir, float size) {
  pushMatrix();
  translate(at.x, at.y); // goto middle of line to put cheveron
  rotate(dir.heading());
  line(2*size, 0, 0, size);
  line(2*size, 0, 0, -size);
  popMatrix();
}

void loadExternalFiles() {
  JunctionTemplateLoader temp = new JunctionTemplateLoader();
  JSONArray templateArray = loadJSONArray(JunctionTemplateLoader.JUNCTION_TEMPLATE_FILENAME);
  temp.loadTemplates(templateArray, this);
}

color rainbow(int n) {
  // returns 12 colors of the rainbow, 0=red, 4=green, 8=blue
  float[] t = {51,0,0,0,51,102,153,204,255,204,153,102,51,0,0,0,51,102,153,204};
  if (n == 12) return color(255);
  int m = Math.abs(n) % 12;
  return color(t[m+8],t[m+4],t[m]);
}



//true if the dist between is less than or equal to dist
boolean isVectorNear(PVector v1, PVector v2, float dist) {
  return v1.dist(v2) <= dist;
}


float turn(PVector a, PVector b) {
  // radians to turn from a to b, negative for LEFT turn
  float x = PVector.angleBetween(a,b);
  float z = a.dot(-b.y, b.x, 0);
  return z < 0 ? x : -x;
}


// Ensure a is between -pi and +pi, add multiples of 2*pi
float fixAngle(float a) {
  float pi = 3.1415926;
  while (a < -pi) a += 2*pi;
  while (a > pi) a -= 2*pi;
  return a;
}


// Ensure a is between 0 and sign * pi
float fixAngle(float a, float sign) {
  float x = 2 * 3.1415926;
  while (sign * a < 0) a += sign * x;
  while (sign * a > x) a -= sign * x;
  return a;
}

// Given b>0, this ensures a is between -b and +b
float clamp(float a, float b) {
  return a > b ? b : a < -b ? -b : a;
}


int growRoads(float len, boolean oneway, int numlanes) {
  // THis is a wierd algorithm to organicly grow the network of roads. First walk in a random
  // direction starting at the origin until we find an empty area. create a junction
  // in that area. Then connect to any other nearby junctions.
  PVector p = findEmptyArea(len * .9);
  return world.connectToNeighbors(p, len * 1.5, oneway, numlanes);
}

PVector findEmptyArea(float r) {
  PVector p = new PVector();
  PVector s = PVector.random2D().mult(1.5*r);
  while (world.hasNeighbors(p, r)) {
    p.add(s);
  }
  return p;
}