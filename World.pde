
class World {
  
  ArrayList<Car> globalCars;
  ArrayList<Segment> globalSegments;
  ArrayList<Junction> globalJunctions;  // todo these should be private

  World() {
    globalSegments = new ArrayList<Segment>();
    globalJunctions = new ArrayList<Junction>();
    globalCars = new ArrayList<Car>();
  }    
    
  Car createCar(Segment s, float alpha) {      
    Car newCar = new Car();
    globalCars.add(newCar);
    s.addCar(newCar, alpha);
    return newCar;
  }
  
  Car createCar() {
    return createCar(globalSegments.get((int)random(globalSegments.size())), random(1));
  }
  
  void removeCar(Car c) {
    if (c == null) return;
    globalCars.remove(c);
    c.s.cars.remove(c);
  }
  
  // The input to this function is a segment with start/end set, but nothing else
  // This will find which start/end JUNCTIONS  it belongs to, and attach them
  // also it will add extra lanes.
  void addSegment(Segment newSegment, boolean oneway, int numlanes) {
    globalSegments.add(newSegment);
    float r = lanesize * numlanes * (oneway?1:2) * 0.8;
    if (newSegment.startjun == null) {
      Junction j1 = nearestJunction(newSegment.start);
      if (j1 == null) {
        j1 = new Junction(newSegment.start, r);
        globalJunctions.add(j1);
      }
      j1.addStarter(newSegment);
    }
    Junction j2 = nearestJunction(newSegment.end);
    if (j2 == null || j2 == newSegment.startjun) {
      j2 = new Junction(newSegment.end, r);
      globalJunctions.add(j2);
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
    globalJunctions.add(j);
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
    globalSegments.add(seg);
    c.addStarter(seg);
    d.addEnder(seg);
    return seg;
  }
  
  void removeSegment(Segment s1) {
    if (s1 == null) return;
    for (Car c1:s1.cars) globalCars.remove(c1);
    if (s1.leftside != null) s1.leftside.rightside = null;
    if (s1.rightside != null) s1.rightside.leftside = null;
    s1.endjun.enders.remove(s1);
    s1.startjun.starters.remove(s1);
    removeIfEmpty(s1.endjun);
    removeIfEmpty(s1.startjun);
    globalSegments.remove(s1);
  }


  void removeIfEmpty(Junction j) {
    if (j.enders.size() == 0 && j.starters.size() == 0) {
      globalJunctions.remove(j);
    }
  }
  
  void draw(boolean editMode) {
    for (Junction j : globalJunctions) {
      j.draw(editMode);
    }
    for(Segment s : globalSegments) {
      s.draw(editMode);
      if(!paused) s.step();
    }
    for(Car c : globalCars) {
      c.draw(editMode);
    }
  }
  
  
  
  Car nearestCar(PVector p) {
    float dist = 1e9;
    Car car = null;
    for(Car c : globalCars) {
      float td = c.location().dist(p);
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
    for(Segment s : globalSegments) {
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
    for(Junction j : globalJunctions) {
      float td = PVector.dist(j.pos, p);
      if(td < dist){
        dist = td;
        jun = j;
      }
    }
    return jun;
  }  
}