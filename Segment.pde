class Segment {
  ArrayList<Car> cars;
  ArrayList<Segment> segments; //list of roads a car can goto from this one. not sorted
  PVector start;
  PVector end;
  float length; // must be recalculated anytime the start or end change
  
  Segment(PVector start, PVector end) {
    this.start = start;
    this.end = end;
    this.length = PVector.dist(start, end);
    
    cars = new ArrayList<Car>();
    segments = new ArrayList<Segment>();
  }
  
  void draw() {
    pushMatrix();
    translate(start.x, start.y);
    line(0,0, end.x-start.x, end.y-start.y);
    popMatrix();
  }
  
  void drawEditMode() {
    pushMatrix();
    fill(255, 0, 0);
    translate(start.x, start.y);
    ellipse(0, 0, 10, 10);
    ellipse(end.x-start.x, end.y-start.y, 10, 10);

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
  
  void link(Segment s) { //add s to the list of segments that a car can goto after this one
    segments.add(s);
  }
  
  float nearestAlpha(PVector point) { 
    // returns the alpha 0..1 that is nearest to the point (such as mouse x y)
    if (length < 1e-5) return 0;
    PVector axis = PVector.sub(end, start);
    return Math.min(1, Math.max(0, axis.dot(PVector.sub(point, start)) / axis.dot(axis)));
  }
  
  float distanceToPoint(PVector point) {
    float a = nearestAlpha(point);
    PVector axis = PVector.sub(end, start);
    return point.dist(PVector.add(start, axis.mult(a)));
  }
}