PVector viewPortVec;
float viewZoom;
boolean[] keyList = new boolean[256];


ArrayList<Car> globalCars;
ArrayList<Segment> globalSegments;

boolean paused = false;
boolean editMode = false;
boolean helpMode = false;

Segment newSegment;

void setup() {
  size(800, 800);
  surface.setResizable(true);
  viewPortVec = new PVector(0, 0);
  viewZoom = 1;
  globalSegments = new ArrayList<Segment>();
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
  if(editMode) { //edit mode pauses and draws in a different mode
    for(Car c : globalCars) {
      c.draw();
    }
    
    for(Segment s : globalSegments) {
      s.draw();
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
    case 'g': // find the nearest start of a road and make a car on it.
      Segment s = nearestSegment(mv);
      if (s == null) break;
      Car newCar = new Car();
      globalCars.add(newCar);
      Utils.addCar(s, newCar);
      newCar.alpha = s.nearestAlpha(mv);
      break;
    case 'r':
      Car c = nearestCar(mv);
      if (c == null) break;
      globalCars.remove(c);
      c.s.cars.remove(c);
      break;
    case 't':
      Segment s1 = nearestSegment(mv);
      if (s1 == null) break;
      for (Car c1:s1.cars) globalCars.remove(c1);
      globalSegments.remove(s1);
      break;
    case '/': case '?':
      helpMode = !helpMode; break;
  }
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
    "In edit mode, click and drag to create a road."
  };
  int ts = (int)(height / 50);
  textSize(ts);
  fill(200);
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
  int s = 10;
  if(keyList[65] || keyList[97]) viewPortVec.x += s; //a or A
  if(keyList[100] || keyList[68]) viewPortVec.x -= s; //d or D
  if(keyList[87] || keyList[119]) viewPortVec.y += s; //w or W
  if(keyList[83] || keyList[115]) viewPortVec.y -= s; //s or S
  if(keyList[88]) viewZoom *= 1.02; //x 
  if(keyList[90]) viewZoom /= 1.02; //z 
}

void mousePressed() {
  if(editMode) {
    //check for segment node
    newSegment = new Segment(mouseVector(), mouseVector());
    for(Segment s : globalSegments) {
      if(Utils.isVectorNear(newSegment.start, s.start, 5)) { //find a segment start to snap too
        newSegment.start = s.start;
      } else if(Utils.isVectorNear(newSegment.start, s.end, 5)) {
        newSegment.start = s.end;
        s.link(newSegment);
      }
    }
  }
}



void mouseReleased() {
  if(editMode) {
    if(newSegment != null) { //make sure we are making a segment
      newSegment.end = mouseVector();
      globalSegments.add(newSegment);
      for(Segment s : globalSegments) {
        if(Utils.isVectorNear(newSegment.end, s.start, 5)) {// snap to nearby segments
          newSegment.end = s.start;
          newSegment.link(s);
        }else if(Utils.isVectorNear(newSegment.end, s.end, 5)) {
          newSegment.end = s.end;
        }
      }
      newSegment.refresh(); // have to refresh to calculate new length
      newSegment = null;
    }
  }
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