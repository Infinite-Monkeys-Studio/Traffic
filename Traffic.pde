PVector viewPortVec;
float viewZoom;
boolean[] keyList = new boolean[256];


ArrayList<Car> globalCars;
ArrayList<Segment> globalSegments;
ArrayList<Junction> globalJunctions;

boolean paused = false;
boolean editMode = false;
boolean helpMode = false;
boolean oneway = true;
int numlanes = 1;

Segment newSegment;

void setup() {
  size(800, 800);
  surface.setResizable(true);
  viewPortVec = new PVector(0, 0);
  viewZoom = 1;
  globalSegments = new ArrayList<Segment>();
  globalJunctions = new ArrayList<Junction>();
  globalCars = new ArrayList<Car>();
  createTestSegments();
  createTestCars();
}


void draw() {
  background(#1D8309);
  drawHelp();
  translate(width/2, height/2);  // this is so the zoom is at the center
  scale(viewZoom);
  translate(viewPortVec.x, viewPortVec.y);
  keys();//runs keys that are held down
  mouseZoom(); // apply held down stuff
  if(editMode) { //edit mode pauses and draws in a different mode
    for(Car c : globalCars) {
      c.draw();
    }
    for(Segment s : globalSegments) {
      s.drawEditMode();
    }
    
    if(newSegment != null) {
      PVector end = mouseVector();
      line(newSegment.start.x, newSegment.start.y, end.x, end.y);
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
  
}

void keyTyped() {
  char k = key;
  PVector mv = mouseVector();
  switch(k) {
    case 'p':
      paused = !paused;
      break;
    case 'e': //enter edit mode
      if(newSegment != null) break; // don't let them leave edit mode if they are making a new road.
      editMode = !editMode;
      paused = editMode;
      break;
    case 'g': 
      Segment s = nearestSegment(mv);
      if (s != null) createCar(s, s.nearestAlpha(mv));
      break;
    case 'r':
      removeCar(nearestCar(mv));
      break;
    case 't':
      removeSegment(nearestSegment(mv));
      break;
    case 'q': oneway = !oneway; break;
    case '1':case '2':case '3': numlanes = Character.getNumericValue(k); break;
    case '/': case '?':
      helpMode = !helpMode; break;
  }
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

void removeSegment(Segment s1) {
  if (s1 == null) return;
  for (Car c1:s1.cars) globalCars.remove(c1);
  if (s1.leftside != null) s1.leftside.rightside = null;
  if (s1.rightside != null) s1.rightside.leftside = null;
  globalSegments.remove(s1);
}

void drawHelp() {
  String[] list = {
    "Traffic Simulator", 
    "by Infinite Monkeys Studio","",
    "---- KEYS ----",
    "wasd - pan the world",
    "zx - zoom the world",
    "e - edit mode",
    "p - pause simulation",
    "g - add car at mouse location",
    "r - remove car",
    "t - remove road segment",
    "? - show help",
    "Esc - exit",
    "", 
    "In edit mode, click and drag to create a road.",
    "123 - one, two, three lane road",
    "q - toggle one, two way"
  };
  int ts = (int)(height / 50);
  textSize(ts);
  fill(200);
  if (editMode) {
    text(numlanes + " lane " + (oneway?"one-way":"each way"),ts,ts);
  }
  if (!helpMode) {
    text("? for Help",ts/2,height-ts/3);
    return;
  }
  int x = ts*10;
  int y = ts*5;
  for (String s : list) {
    text(s,x,y+=ts);
  }
}

void keyPressed() {
  //println(keyCode);
  keyList[keyCode&255] = true;
}

void keyReleased() {
  keyList[keyCode&255] = false;
}

void keys() {
  float s = 10 / viewZoom;
  if(keyList[65] || keyList[97]) viewPortVec.x += s; //a or A
  if(keyList[100] || keyList[68]) viewPortVec.x -= s; //d or D
  if(keyList[87] || keyList[119]) viewPortVec.y += s; //w or W
  if(keyList[83] || keyList[115]) viewPortVec.y -= s; //s or S
  if(keyList[88]) viewZoom *= 1.02; //x 
  if(keyList[90]) viewZoom /= 1.02; //z 
}

void mousePressed() {
  if(editMode) {
    newSegment = new Segment(mouseVector());
  }
}



void mouseReleased() {
  if(editMode) {
    if(newSegment != null) { //make sure we are making a segment
      newSegment.end = mouseVector();
      newSegment.refresh(); // have to refresh to calculate new length
      globalSegments.add(newSegment);
      float r = 30 * numlanes * (oneway?1:2);
      PVector pos = newSegment.axis().normalize().mult(r*0.7);
      Junction j1 = nearestJunction(newSegment.start);
      if (j1 == null) {
        j1 = new Junction(PVector.sub(newSegment.start, pos), r);
        globalJunctions.add(j1);
      }
      j1.segOut.add(newSegment);
      Junction j2 = nearestJunction(newSegment.end);
      if (j2 == null || j1 == j2) {
        j2 = new Junction(PVector.add(newSegment.end, pos), r);
        globalJunctions.add(j2);
      }
      newSegment.junction = j2;
      j2.segIn.add(newSegment);
        
      // Add more lanes
      Segment seg = newSegment;
      for (int i=1; i<numlanes; ++i)
        seg = createParallelLane(seg);
      if (!oneway) {
        seg = createOppositeLane(newSegment);
        for (int i=1; i<numlanes; ++i)
          seg = createParallelLane(seg);
      }    
      newSegment = null;
    }
  }
}

float wheelPos = 0;

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  wheelPos += e < 0 ? -1 : 1;
}

void mouseZoom() {
  if (Math.abs(wheelPos)<.1) return;
  wheelPos *= 0.5;
  float dz = (float) Math.pow(1.01, -wheelPos);
  viewZoom *= dz;
  // zoom toward mouse pointer
  PVector mv = new PVector(mouseX - width/2, mouseY - height/2);
  viewPortVec.add(mv.mult(1 - dz));
}

float lanesize = 11;

// Creates another lane on the RIGHT side of s, same direction and same distance
Segment createParallelLane(Segment s) {
  PVector perp = s.rightDir().mult(lanesize); // rotated 90 CW 
  Segment seg = new Segment(PVector.add(s.start,perp),PVector.add(s.end,perp));
  globalSegments.add(seg);
  seg.leftside = s;
  s.rightside = seg;
  return seg;
}

// Creates another lane on the LEFT side of s, opposite direction and same distance
Segment createOppositeLane(Segment s) {
  PVector perp = s.rightDir().mult(-lanesize); // rotated 90 CCW 
  Segment seg = new Segment(PVector.add(s.end,perp),PVector.add(s.start,perp));
  globalSegments.add(seg);
  // todo link up
  return seg;
}

void createTestCars() {
  Car test = new Car();
  test.driver.goalRate = 1.5;
  globalCars.add(test);
  Utils.addCar(globalSegments.get(1), test);
  
  float l = globalSegments.get(0).length;
  for(int i = 0; i < 4; i++) {
    Car c = new Car();
    c.alpha = ((i*55)/l);
    globalCars.add(c);    
    Utils.addCar(globalSegments.get(0), c);   
  } 
}

void createTestSegments() {
  Segment s1 = new Segment(new PVector(-200,-200), new PVector(-200,200));
  globalSegments.add(s1);
  Segment s2 = new Segment(new PVector(-200,200), new PVector(200,200));
  globalSegments.add(s2);
  Segment s3 = new Segment(new PVector(200,200), new PVector(200,-200));
  globalSegments.add(s3);
  Segment s4 = new Segment(new PVector(200,-200), new PVector(-200,-200));
  globalSegments.add(s4);
  
  s1.link(s2);
  s2.link(s3);
  s3.link(s4);
  s4.link(s1);
}

// corrects for screen pan and zoom
PVector mouseVector() {
  return PVector.sub(new PVector(mouseX - width/2, mouseY - height/2).mult(1 / viewZoom), viewPortVec);
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
  float dist = 1e9;
  Junction jun = null;
  for(Junction j : globalJunctions) {
    float td = PVector.dist(j.pos, p);
    if(jun == null || td < dist){
      dist = td;
      jun = j;
    }
  }
  return jun;
}