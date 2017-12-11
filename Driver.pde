class Driver {
  
  float goalRate; // rates are in px/s
  
  Driver() {
    this.goalRate = 2;
  }
  
  Driver(float goalRate) {
    this.goalRate = goalRate;
  }
  
  float step(float distanceToObject, float speedOfObject) {
    float rate = goalRate; // else follow //<>//
    if(speedOfObject < 0) {// -1 is the intersection flag
      if(distanceToObject > 70) {
        rate = goalRate;
      } else {
        rate = goalRate*distanceToObject/70 + .1;
        if(rate > goalRate) rate = goalRate;
      }
    } else {
      if(distanceToObject > 70) {//if safe, drive fast
        rate = goalRate;
      } else if(distanceToObject < 40) {
        rate = speedOfObject;
      } else if(distanceToObject < 50 && rate > 0) { // if close slow down
        rate -= .1;
      } else if(distanceToObject < 40) { // if too close stop
        rate = 0;
      }
    }
    
    return rate;
  }
  
  Driver copy() {
    return new Driver(goalRate);
  }
}