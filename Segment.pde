class Segment {
  ArrayList<Car> cars;
  PVector start;
  PVector end;
  Segment leftside;   // cars can change lanes into left or right side (might be null)
  Segment rightside;  // these must be parallel segments in the same direction and distance
  Junction startjun;
  Junction endjun; 
  
  Segment(PVector start) {
    this(start, start.copy().add(0,.1));
  }
  
  Segment(PVector start, PVector end) {
    this.start = start.copy();
    this.end = end.copy();
    cars = new ArrayList<Car>();
  }

  PVector rightDir() {  // return a direction to the RIGHT of cars on this segment
    return new PVector(start.y - end.y, end.x - start.x).normalize();
  }
  
  PVector axis() {
    return PVector.sub(end, start);
  }


  float length() {
    return PVector.dist(start, end);
  }

  void draw(boolean editmode) {
    if (editmode) { drawEditMode(); return; }
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
    popMatrix();
    drawChevron(start, end, 5);
  }  
  
  void step() {
    for(int i = 0; i < cars.size(); i++) {
      Car c = cars.get(i);
      c.step();
    }
  }
  
  float nearestAlpha(PVector point) { 
    // returns the alpha 0..1 that is nearest to the point (such as mouse x y)
    PVector axis = PVector.sub(end, start);
    float d = axis.dot(axis);
    if (d < 1e-5) return 0;
    return Math.min(1, Math.max(0, axis.dot(PVector.sub(point, start)) / d));
  }
  
  float distanceToPoint(PVector point) {  // return distance from segment to the point
    float a = nearestAlpha(point);
    PVector axis = PVector.sub(end, start);
    return point.dist(PVector.add(start, axis.mult(a)));
  }  
  
  //add OR MOVE a car to a new road.
  void addCar(Car c, float alpha) {
    if (c.s != null) c.s.cars.remove(c);//take the car off the old road
    c.alpha = alpha;
    insertByOrder(c); //put it on the new road
    c.s = this; //tell the car what road he's on
  }

  void addCar(Car c) {
    // compute negative alpha (give the car time to get to the start)
    float d = c.pos.dist(start);
    c.easeIn = (int) (30 / c.driver.naturalSpeed); 
    addCar(c, -.4 * d / length());
  }
  
  // add the car to the list in a sorted way.
  // the car with the biggest alpha is the 0th car
  void insertByOrder(Car c) {
    if (cars.size() > 0) {
      for (int i = 0; i < cars.size(); i++) {
        if (c.alpha > cars.get(i).alpha) {
          cars.add(i, c);    // add at i
          return;
        }
      }
    }
    cars.add(c);  // add at the end
  }

  boolean isClear(float dist) {
    // return true if the starting end of the segment does not have any cars on it
    if (cars.size() == 0) return true;
    float a = cars.get(cars.size() - 1).alpha;
    return a * length() > dist;
  }
  
}