class Car {
  color c;
  Segment s;
  float alpha; // percent of distance along segment
  float rate;
  Driver driver;
  
  Car() {
    this(color(random(0,255), random(0,255), random(0,255)), null, 0, 0);
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
  }
 
  void draw(boolean editmode) {
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
  
  void step() {
    alpha += rate / s.length; //advance    
    rate = driver.step();
  }
  
  float positionOnRoad() {
    return alpha * s.length;
  }
  
  Car copy() { // by value copy
    return new Car(c,s,alpha,rate,driver.copy());
  }
}