class Segment {
  ArrayList<Car> cars;
  PVector start;
  PVector end;
  Segment leftside;   // cars can change lanes into left or right side (might be null)
  Segment rightside;  // these must be parallel segments in the same direction and distance
  Junction startjun;
  Junction endjun; 
  int group;
  int dir;   // 1=right, 2=straight, 4=left
  
  Segment(PVector start) {
    this(start, start.copy().add(0,.1));
  }
  
  Segment(PVector start, PVector end) {
    this.start = start.copy();
    this.end = end.copy();
    cars = new ArrayList<Car>();
    dir = 7;
  }

  PVector rightDir() {  // return a direction to the RIGHT of cars on this segment
    return new PVector(start.y - end.y, end.x - start.x).normalize();
  }
  
  PVector axis() {
    return PVector.sub(end, start);
  }

  PVector location(float alpha) {
    return PVector.lerp(start, end, alpha);
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

    // for debug lane changes
    //strokeWeight(4); stroke(255,0,0); 
    //PVector e1=PVector.lerp(start,end,b1);
    //PVector e2=PVector.lerp(start,end,b2);
    //if (b1!=0) line(e1.x,e1.y,e2.x,e2.y);
    //if (!paused) b1=0;
    
    drawSignal();
    drawArrow();
    
    // Draw white lines on the sides of the road.
    strokeWeight(.5);
    strokeCap(SQUARE);
    stroke(255);
    PVector r = rightDir().mult(5);
    if (leftside==null)  line(start.x-r.x,start.y-r.y,end.x-r.x,end.y-r.y);
    if (rightside!=null) stroke(180);
    line(start.x+r.x,start.y+r.y,end.x+r.x,end.y+r.y);
  }
  
  void drawSignal() {
    if (endjun.canGo == null) return;
    int sig = endjun.getSignal(group);
    int c = #00ff00;
    if (sig == 0) c = #ff0000;
    else if (endjun.isYellow()) c = #ffff00; 
    PVector p = axis().normalize().mult(15).add(end);
    if (sig == 7 || sig == 0) {
      fill(c);
      noStroke();
      ellipse(p.x, p.y, 2, 2);
    }
    else {
      stroke(c);
      strokeWeight(1);
      PVector e = PVector.sub(p,end).mult(.35);
      PVector h = new PVector(-e.y, e.x);
      if ((sig & 1)==1) {
        drawChevronAt(p,h,2,1.3);  // right
      }
      if ((sig & 2) == 2) {
        drawChevronAt(p.add(e),e,2,1.3);  // straight
      }
      if ((sig & 4) == 4) {
        drawChevronAt(p.add(e),h.mult(-1),2,1.3);  // left
      }
    }
  }
  
  void drawArrow() {
    if (dir > 6) return;
    noFill();
    stroke(#ffffff);
    strokeWeight(1);
    PVector p = axis().normalize().mult(-40).add(end);
    PVector e = PVector.sub(p,end).mult(-.1*lanesize/11);
    PVector h = new PVector(-e.y, e.x);
    float a = axis().heading();
    if ((dir & 1) == 1) { // right turn
      p.add(h);
      arc(p.x,p.y,4,4,a-1.7,a);
      drawChevronAt(p.copy().add(e),h,1,1.5);
      p.sub(h);
    }
    if ((dir & 2) == 2) {
      PVector t = e.copy().mult(2.5).add(p);
      line(p.x,p.y,t.x,t.y);
      drawChevronAt(t,e,1,1.5);
    }
    if ((dir & 4) == 4) {  // left turn 
      p.sub(h);
      arc(p.x,p.y,4,4,a,a+1.7);
      drawChevronAt(p.copy().add(e),h.mult(-1),1,1.5);
    }
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
  
  
  float nearestAlpha(PVector point) { 
    // returns the alpha 0..1 that is nearest to the point (such as mouse x y)
    PVector axis = axis();
    float d = axis.dot(axis);
    if (d < 1e-5) return 0;
    return Math.min(1, Math.max(0, axis.dot(PVector.sub(point, start)) / d));
  }
  
  float distanceToPoint(PVector point) {  // return distance from segment to the point
    float a = nearestAlpha(point);
    PVector axis = axis();
    return point.dist(PVector.add(start, axis.mult(a)));
  }  
  
  //add OR MOVE a car to a new road.
  void addCar(Car c, float alpha) {
    if (c.s != null) c.s.cars.remove(c);//take the car off the old road
    float d = c.pos.dist(location(alpha));
    c.snap = alpha;
    c.alpha = c.snap - d / length();
    insertByOrder(c); //put it on the new road
    c.s = this;       //tell the car what road he's on
  }

  void addCar(Car c) {
    addCar(c, 0);
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
  
  
  boolean isClearAt(float alpha, float distBack, float distForward) {
    // return true if the segment has no cars around "alpha"
    if (cars.size() == 0) return true;
    float a1 = alpha - distBack / length();
    float a2 = alpha + distForward / length();
//    b1=0;
    for (Car c: cars) if (c.alpha > a1 && c.alpha < a2) return false;
//    b1=a1;b2=a2; paused=true;
    return true;
  }
  
}