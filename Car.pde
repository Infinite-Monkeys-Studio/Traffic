class Car {
  color c;
  Segment s;
  float alpha; // percent of distance along segment
  float rate;
  Driver driver;
  boolean tooClose;    // the car is too close to the one in front of it
  PVector pos;        // this is to draw the graphics
  float heading;
  int easeLen;       // this is to ease the car (graphics) onto the next segment
  int easeIn;
  
  Car() {
    this(color(random(0,255), random(0,255), random(0,255)), null, 0, 0);
    driver.naturalSpeed = random(1.2, 1.9);
  }
  
  Car(color c, Segment s, float alpha, float rate) {
    this(c, s, alpha, rate, new Driver());
  }
  
  Car(color c, Segment s, float alpha, float rate, Driver driver) {
    this.c = c;
    this.s = s;
    this.alpha = alpha;
    this.rate = rate;
    this.driver = driver;
    driver.link(this);
    this.pos = new PVector();
    this.heading = random(-3.14, 3.14);
    this.easeLen = 0;
  }
 
  int index() {
    return s.cars.indexOf(this);
  }
  
  int id() {
    return world.globalCars.indexOf(this);
  }

 
  void draw(boolean editmode) {
    strokeWeight(.5);
    stroke(0);
    if (editmode) noFill(); else fill(c);
    pushMatrix();
    PVector p = pos;
    translate(p.x, p.y);
    rotate(heading);    
    rect(-10, -4, 20, 8);
    if (editmode) {
      rotate(-heading);
      fill(0);
      text(id() + " " + index(),0,0);
    }
    popMatrix();
  }
  
  PVector location() {
    return PVector.lerp(s.start, s.end, alpha);
  }
   //<>//
  void step() {
    tooClose = collisionDetection();
    if (!tooClose) {
      rate = driver.step();
      alpha += rate / s.length(); //advance    
    }
    // Transition to merge car position and heading onto the segment:
    
    if (easeIn >= easeLen) {
      pos = location();
      heading = s.axis().heading();
    } 
    else {
      float t = easeIn++ / (float) easeLen;    // always between 0 and 1
      pos = PVector.lerp(pos, location(), t);
      heading = (1-t) * heading + t * s.axis().heading();
      
      // TODO this flips the cars around funny sometimes
    }
  }
  
  boolean collisionDetection() {
    int i = index();
    if (i == 0) return false;
    Car carAhead = s.cars.get(i - 1);
    float safeAlpha = carAhead.alpha - 25 / s.length();
    if (alpha < safeAlpha) return false;
    float da = alpha - safeAlpha;
    if (da > 2) da /= 2;
    alpha -= da;  // backup the car to a safe distance
    rate = carAhead.rate;
    return true;
  }
  
  float positionOnRoad() {
    return alpha * s.length();
  }
  
  Car copy() { // by value copy
    return new Car(c,s,alpha,rate,driver.copy());
  }
}