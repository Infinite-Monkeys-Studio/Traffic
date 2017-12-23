class Segment {
  ArrayList<Car> cars;
  PVector start;
  PVector end;
  float length; // must be recalculated anytime the start or end change
  Segment leftside;   // cars can change lanes into left or right side (might be null)
  Segment rightside;  // these must be parallel segments in the same direction and distance
  Junction startjun;
  Junction endjun; 
  
  Segment(PVector start) {
    this(start, start.copy().add(0,.1));
  }
  
  Segment(PVector start, PVector end) {
    this.start = start;
    this.end = end;
    this.length = PVector.dist(start, end);    
    cars = new ArrayList<Car>();
  }

  PVector rightDir() {  // return a direction to the RIGHT of cars on this segment
    return new PVector(start.y - end.y, end.x - start.x).normalize();
  }
  
  PVector axis() {
    return PVector.sub(end, start);
  }

  void draw() {
    // Draw a fat gray line for the road
    strokeWeight(11);
    strokeCap(ROUND);
    stroke(100);
    line(start.x,start.y, end.x, end.y);
    
    // Draw white lines on the sides of the road.
    strokeWeight(.5);
    strokeCap(SQUARE);
    stroke(255);
    PVector r = rightDir().mult(5);
    if (leftside==null)  line(start.x-r.x,start.y-r.y,end.x-r.x,end.y-r.y);
    if (rightside!=null) stroke(180);
    line(start.x+r.x,start.y+r.y,end.x+r.x,end.y+r.y);
  }
  
  void drawEditMode() {
    strokeWeight(1);
    strokeCap(SQUARE);
    stroke(0);
    line(start.x,start.y, end.x, end.y);
    pushMatrix();
    fill(255, 0, 0);
    translate(start.x, start.y);
    ellipseMode(RADIUS);
    ellipse(0, 0, 5, 5);
    ellipse(end.x-start.x, end.y-start.y, 5, 5);

    PVector h = PVector.sub(end, start).div(2);
    translate(h.x, h.y); // goto middle of line to put cheveron
    rotate(PVector.sub(end, start).heading());
    line(0, 0, -10, 5);
    line(0, 0, -10, -5);
    popMatrix();
  }
  
  void refresh() {// recalculate length of line
    this.length = PVector.dist(start, end);
  }
  
  void step() {
    Car previousCar = null; //passed to car so they don't have to search
    for(int i = 0; i < cars.size(); i++) {
      Car c = cars.get(i);
      c.step(previousCar);
      previousCar = c;
    }
  }
  
  float nearestAlpha(PVector point) { 
    // returns the alpha 0..1 that is nearest to the point (such as mouse x y)
    if (length < 1e-5) return 0;
    PVector axis = PVector.sub(end, start);
    return Math.min(1, Math.max(0, axis.dot(PVector.sub(point, start)) / axis.dot(axis)));
  }
  
  float distanceToPoint(PVector point) {  // return distance from segment to the point
    float a = nearestAlpha(point);
    PVector axis = PVector.sub(end, start);
    return point.dist(PVector.add(start, axis.mult(a)));
  }
}