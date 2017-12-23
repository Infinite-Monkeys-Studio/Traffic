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
  
  //float step(float distanceToObject, float speedOfObject) {
  //  return naturalSpeed;
  //}
  
  float step() {
    if(myCar.alpha > 1) {
      Segment nseg = findNewRoad();
      Utils.addCar(nseg, myCar);
      myCar.alpha = 0;
      return 0;
    }
    
    int myIndex = myCar.s.cars.indexOf(myCar);
    float safeSpeed;
    if(myIndex > 0) {
      // there is a car ahead of me
      Car carAhead = myCar.s.cars.get(myIndex - 1);
      float distanceToObject = myCar.positionOnRoad() - carAhead.positionOnRoad();
      float Vm = myCar.rate;
      float Vt = carAhead.rate;
      float followingDist = followingTime * Vt;
      float dist = distanceToObject - followingDist;
      if(dist < 0) dist = 0;
      
      float acc = (sq(Vm) - sq(Vt)) / 2*dist; 
      
      if(abs(acc) > comfAcc) {
        safeSpeed = myCar.rate + acc;
        if(safeSpeed < 0) safeSpeed = 0;
      } else {
        safeSpeed = naturalSpeed;
      }
    } else {
      // I am the lead car
      safeSpeed = naturalSpeed;
    }
    
    return safeSpeed;
  }
  
  Segment findNewRoad() {
    ArrayList<Segment> openSegs = myCar.s.endjun.openStarters(myCar.s);
    int i = int(random(0, openSegs.size()));
    return openSegs.get(i);
  }
  
  Driver copy() {
    return new Driver(naturalSpeed, followingTime, myCar.copy());
  }
}