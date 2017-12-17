class Car {
  color c;
  Segment s;
  float alpha; // percent of distance along segment
  float rate;
  Driver driver;
  
  Car() {
    c = color(random(0,255), random(0,255), random(0,255));
    rate = 0;
    alpha = 0;
    driver = new Driver();
  }
  
  Car(color c, Segment s, float alpha, float goalRate, float rate) {
    this.c = c;
    this.s = s;
    this.alpha = alpha;
    this.rate = rate;
    this.driver = new Driver(goalRate);
  }
  
  Car(color c, Segment s, float alpha, float rate, Driver driver) {
    this.c = c;
    this.s = s;
    this.alpha = alpha;
    this.rate = rate;
    this.driver = driver;
  }
 
  void draw() {
    strokeWeight(.5);
    stroke(0);
    fill(c);
    pushMatrix();
    PVector p = location();
    float heading = PVector.sub(s.end, s.start).heading();
    translate(p.x, p.y);
    rotate(heading);    
    rect(-10, -4, 20, 8);
    popMatrix();
  }
  
  PVector location() {
    return PVector.lerp(s.start, s.end, alpha);
  }
  
  void step(Car carAhead) {
    alpha += rate / s.length; //advance
    float dist;
    float speed;
    
    if(alpha>=1) {findNewRoads(); return;} // if I over shot, find a new road
    if(carAhead  == null) {
      dist = s.length - (s.length * alpha);
      speed = -1;
    } else {     
      float aheadPos = s.length * carAhead.alpha;
      float myPos = s.length * alpha;
      dist = aheadPos - myPos;
      speed = carAhead.rate;
    }
    
    rate = driver.step(dist, speed);
  }
  
  void findNewRoads() {
    int count = s.segments.size(); //<>//
    if(count == 0) { // no new roads to go too. 
      alpha = 0; // TODO delete car instead of looping them on the same road
      return;
    }
    int i = floor(random(0,count));
    Segment newSegment = s.segments.get(i);
    alpha = 0; //must set alpha before sorting
    Utils.addCar(newSegment, this);
  }
  
  Car copy() { // by value copy
    return new Car(c,s,alpha,rate,driver.copy());
  }
}