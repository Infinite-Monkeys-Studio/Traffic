class Car {
  color c;
  Segment s;
  float alpha;
  float goalRate;
  float rate;
  
  Car() {
    c = color(random(0,255), random(0,255), random(0,255));
    goalRate = .01;
    rate = goalRate;
    alpha = 0;
  }
  
  Car(color c, Segment s, float alpha, float goalRate, float rate) {
    this.c = c;
    this.s = s;
    this.alpha = alpha;
    this.goalRate = goalRate;
    this.rate = rate;
  }
 
  void draw() {
    pushMatrix();
    fill(c);
    PVector p = PVector.lerp(s.start, s.end, alpha);
    float heading = PVector.sub(s.end, s.start).heading();
    translate(p.x, p.y);
    rotate(heading);
    
    rect(-10, -5, 20, 10);
    
    popMatrix();
  }
  
  void step(Car carAhead) {
    alpha += rate; //advance
    if(alpha>=1) {findNewRoads(); return;} // if I over shot, find a new road
    if(carAhead == null) {rate = goalRate; return;} // no one ahead of me, drive fast
    float myPos = s.length * alpha;
    float aheadPos;
    float dist;
    
    aheadPos = s.length * carAhead.alpha;
    dist = aheadPos - myPos;
    
    if(rate < 0) {rate = 0; return;} // if reversing stop.
    if(dist > 70) {rate = goalRate; return;} //if safe, drive fast
    if(dist < 50 && rate > 0) {rate -= .001; return;} // if close slow down //<>//
    if(dist < 40) {rate = 0; return;} // if too close stop
    rate = carAhead.rate; // else follow
  }
  
  void findNewRoads() {
    int cou = s.segments.size(); //<>//
    if(cou == 0) {
      alpha = 0;
      return;
    }
    int ch = floor(random(0,cou));
    Segment co = s.segments.get(ch);
    alpha = 0; //must set alpha before sorting
    Utils.addCar(co, this);
  }
  
  Car copy() {
    return new Car(c,s,alpha,goalRate,rate);
  }
}