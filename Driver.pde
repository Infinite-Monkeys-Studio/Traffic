class Driver {
  //driver stats
  float naturalSpeed; // in px/frame
  float followingTime; // in frames
  float comfAcc; //comfortable breaking acceleration in px/frame/frame
  
  
  Car myCar;
  
  Driver() {
    this.naturalSpeed = 1.46; //about 30mph
    this.followingTime = 120;
    this.comfAcc = 1.77; //about 1g
    myCar = null;
  }
  
  Driver(float naturalSpeed, float followingTime, Car myCar) {
    this.naturalSpeed = naturalSpeed;
    this.followingTime = followingTime;
    this.myCar = myCar;
  }
  
  void link(Car myCar) {
    this.myCar = myCar;
  }
  
  
  float step() {
    if(myCar.alpha > 1) {
      Segment s = findNewRoad();
      if (s == null) return 0;
      s.addCar(myCar);
      return 0;
    }
    
    int myIndex = myCar.index();
    float safeSpeed;
    if(myIndex > 0) {
      // there is a car ahead of me
      Car carAhead = myCar.s.cars.get(myIndex - 1);
      float distanceToObject = carAhead.positionOnRoad() - myCar.positionOnRoad() - 25;

      safeSpeed = naturalSpeed;
      float safeDistance = 40;
      float slowdown = distanceToObject / safeDistance;
      if (slowdown < 1 && carAhead.rate < naturalSpeed) {
        safeSpeed = naturalSpeed * slowdown + carAhead.rate * (1 - slowdown);
        // TRY TO CHANGE TO ANOTHER LANE        
        if (!changeLane(myCar.s.leftside)) 
          changeLane(myCar.s.rightside);
      } //<>//
    } 
    else {
      // I am the lead car
      safeSpeed = naturalSpeed;
    }
    return safeSpeed;
  }

  
  boolean changeLane(Segment s) {
    float a = myCar.alpha + 25 / s.length();
    if (s != null && s.isClearAt(a, 40, 25)) {
      s.addCar(myCar, a);
      return true;
    }        
    return false;
  }
  
  Segment findNewRoad() {
    ArrayList<Segment> openSegs = myCar.s.endjun.openStarters(myCar.s, 25);
    if (openSegs.size() == 0) return null;
    return openSegs.get((int)random(openSegs.size()));
  }
  
  Driver copy() {
    return new Driver(naturalSpeed, followingTime, myCar.copy());
  }
}