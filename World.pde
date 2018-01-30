
class World {
  
  private ArrayList<Car> carList;
  private ArrayList<Segment> segList;
  private ArrayList<Junction> junList;

  World() {
    segList = new ArrayList<Segment>();
    junList = new ArrayList<Junction>();
    carList = new ArrayList<Car>();
  }    
    
    
  Car createCar(PVector v) {
    Segment s = nearestSegment(v);
    if (s == null) return null;
    Car newCar = new Car();
    newCar.pos = v.copy();
    newCar.heading = random(6.28);
    carList.add(newCar);
    s.addCar(newCar, s.nearestAlpha(v));
    return newCar;
  }
  
  Car createCar(Segment s, float alpha) {      
    Car newCar = new Car();
    newCar.pos = s.axis().mult(alpha).add(s.start);
    newCar.heading = s.axis().heading();
    carList.add(newCar);
    s.addCar(newCar, alpha);
    return newCar;
  }
  
  int getid(Car c) {
    return carList.indexOf(c);
  }
  
  Car createCar() {
    return createCar(segList.get((int)random(segList.size())), random(1));
  }
  
  void removeCar(Car c) {
    if (c == null) return;
    carList.remove(c);
    c.s.cars.remove(c);
  }
  
  // change natural speed of all the drivers
  void driveSpeed(float f) {
    for (Car c: carList) {
      c.driver.naturalSpeed *= f;
    }
  }
  
  // The input to this function is a segment with start/end set, but nothing else
  // This will find which start/end JUNCTIONS  it belongs to, and attach them
  // also it will add extra lanes.
  void addSegment(Segment newSegment, boolean oneway, int numlanes) {
    segList.add(newSegment);
    float r = lanesize * numlanes * (oneway?1:2) * 0.5;
    if (newSegment.startjun == null) {
      Junction j1 = nearestJunction(newSegment.start);
      if (j1 == null) {
        float z = newSegment.start.z < .01 ? 1.0 : newSegment.start.z;
        j1 = new Junction(newSegment.start, r * z);
        junList.add(j1);
      }
      j1.addStarter(newSegment);
    }
    Junction j2 = nearestJunction(newSegment.end);
    if (j2 == null || j2 == newSegment.startjun) {
      float z = newSegment.end.z < .01 ? 1.0 : newSegment.end.z;
      j2 = new Junction(newSegment.end, r * z);
      junList.add(j2);
    }
    j2.addEnder(newSegment);
      
    // Add more lanes
    Segment seg = newSegment;
    for (int i=1; i<numlanes; ++i)
      seg = createParallelLane(seg);
    if (!oneway) {
      seg = createOppositeLane(newSegment);
      for (int i=1; i<numlanes; ++i)
        seg = createParallelLane(seg);
    }    
    
    // Rebut the two ends of the road
    Road road = new Road(newSegment);
    road.rebutBothEnds();
  }
  
  Junction addJunction(PVector v) {
    Junction j = new Junction(v);
    junList.add(j);
    return j;
  }
  
  // Creates another lane on the RIGHT side of s, same direction and same distance
  Segment createParallelLane(Segment s) {
    PVector perp = s.rightDir().mult(lanesize); // rotated 90 CW 
    Segment seg = addSegment(PVector.add(s.start,perp), PVector.add(s.end,perp), s.startjun, s.endjun);
    seg.leftside = s;
    s.rightside = seg;
    return seg;
  }
  
  // Creates another lane on the LEFT side of s, opposite direction and same distance
  Segment createOppositeLane(Segment s) {
    PVector perp = s.rightDir().mult(-lanesize); // rotated 90 CCW 
    return addSegment(PVector.add(s.end,perp), PVector.add(s.start,perp), s.endjun, s.startjun);
  }

  Segment addSegment(PVector a, PVector b, Junction c, Junction d) {
    Segment seg = new Segment(a, b);
    segList.add(seg);
    c.addStarter(seg);
    d.addEnder(seg);
    return seg;
  }
  
  void removeSegment(Segment s1) {
    if (s1 == null) return;
    for (Car c1:s1.cars) carList.remove(c1);
    if (s1.leftside != null) s1.leftside.rightside = null;
    if (s1.rightside != null) s1.rightside.leftside = null;
    s1.endjun.enders.remove(s1);
    s1.startjun.starters.remove(s1);
    removeIfEmpty(s1.endjun);
    removeIfEmpty(s1.startjun);
    segList.remove(s1);
  }


  void removeIfEmpty(Junction j) {
    if (j.enders.size() == 0 && j.starters.size() == 0) {
      junList.remove(j);
    }
  }
  
  void draw(boolean editMode) {
    for (Junction j : junList) {
      j.draw(editMode);
    }
    for(Segment s : segList) {
      s.draw(editMode);
    }
    for(Car c : carList) {
      c.draw(editMode);
    }
  }
  
  
  void step() {
    for(Car c:carList) 
      c.step();    
  }

  
  
  Car nearestCar(PVector p) {
    float dist = 1e9;
    Car car = null;
    for(Car c : carList) {
      float td = c.pos.dist(p);
      if (car == null || td < dist){
        dist = td;
        car = c;
      }
    }
    return car;
  }
  
  Segment nearestSegment(PVector p) {
    float dist = 1e9;
    Segment seg = null;
    for(Segment s : segList) {
      float td = s.distanceToPoint(p);
      if(seg == null || td < dist){
        dist = td;
        seg = s;
      }
    }
    return seg;
  }
  
  Junction nearestJunction(PVector p) {
    return nearestJunction(p, 40);
  }
  
  Junction nearestJunction(PVector p, float dist) {
    Junction jun = null;
    for(Junction j : junList) {
      float td = PVector.dist(j.pos, p);
      if(td < dist){
        dist = td;
        jun = j;
      }
    }
    return jun;
  }  
  
  boolean hasNeighbors(PVector p, float dist) {
    for (Junction j : junList) {
      float td = PVector.dist(j.pos, p);
      if(td < dist) return true;
    }
    return false;
  }
  
  
  int connectToNeighbors(PVector p, float dist, boolean oneway, int numlanes) {
    int i=0;
    for (Junction j : junList) {
      float td = PVector.dist(j.pos, p);
      if(td < dist) {
        Segment s = ((++i & 1) == 0) ? new Segment(p, j.pos):new Segment(j.pos, p);
        addSegment(s, oneway, numlanes);
      }
    }
    return i;
  }
  
}