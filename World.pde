
class World {
  
  ArrayList<Car> globalCars;
  ArrayList<Segment> globalSegments;
  ArrayList<Junction> globalJunctions;  // todo these should be private

  float lanesize = 11;

  World() {
    globalSegments = new ArrayList<Segment>();
    globalJunctions = new ArrayList<Junction>();
    globalCars = new ArrayList<Car>();
  }    
    
  void createCar(Segment s, float alpha) {      
    Car newCar = new Car();
    globalCars.add(newCar);
    Utils.addCar(s, newCar);
    newCar.alpha = alpha;
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
    float r = 15 * numlanes * (oneway?1:2);
    PVector pos = newSegment.axis().normalize().mult(r*0.1);
    if (newSegment.startjun == null) { //<>//
      Junction j1 = nearestJunction(newSegment.start);
      if (j1 == null) {
        j1 = new Junction(PVector.sub(newSegment.start, pos), r);
        globalJunctions.add(j1);
      }
      j1.addSegOut(newSegment);
    }
    Junction j2 = nearestJunction(newSegment.end);
    if (j2 == null || j2 == newSegment.startjun) {
      j2 = new Junction(PVector.add(newSegment.end, pos), r);
      globalJunctions.add(j2);
    }
    j2.addSegIn(newSegment);
      
    // Add more lanes
    Segment seg = newSegment;
    for (int i=1; i<numlanes; ++i)
      seg = createParallelLane(seg);
    if (!oneway) {
      seg = createOppositeLane(newSegment);
      for (int i=1; i<numlanes; ++i)
        seg = createParallelLane(seg);
    }    
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
    c.addSegOut(seg);
    d.addSegIn(seg);
    return seg;
  }
  
  void removeSegment(Segment s1) {
    if (s1 == null) return;
    for (Car c1:s1.cars) globalCars.remove(c1);
    if (s1.leftside != null) s1.leftside.rightside = null;
    if (s1.rightside != null) s1.rightside.leftside = null;
    s1.endjun.segIn.remove(s1);
    s1.startjun.segOut.remove(s1);
    globalSegments.remove(s1);
  }

  
  void draw(boolean editMode) {
    if(editMode) { //edit mode pauses and draws in a different mode
      for(Car c : globalCars) {
        c.draw();
      }
      for(Segment s : globalSegments) {
        s.drawEditMode();
      }      
    } else { //run mode just simulates.
      for(Segment s : globalSegments) {
        s.draw();
        if(!paused) s.step();
      }
      
      for(Car c : globalCars) {
        c.draw();
      }
    }
    for (Junction j : globalJunctions) {
      j.draw();
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
    return nearestJunction(p, 30);
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