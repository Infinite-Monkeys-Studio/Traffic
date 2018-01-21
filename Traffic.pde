PVector viewPortVec;
float viewZoom;
boolean[] keyList = new boolean[256];


boolean paused = false;
boolean editMode = false;
boolean helpMode = false;
boolean oneway = true;
int numlanes = 1;
float lanesize = 11;

Segment newSegment;
World world;

void setup() {
  size(1000, 800);
  surface.setResizable(true);
  viewPortVec = new PVector(0, 0);
  viewZoom = 1;
  createTest6();
}


void draw() {
  background(#1D8309);
  pushMatrix();
  translate(width/2, height/2);  // this is so the zoom is at the center
  scale(viewZoom);
  translate(viewPortVec.x, viewPortVec.y);
  keys();//runs keys that are held down
  mouseZoom(); // apply held down stuff
  if(editMode) { //edit mode pauses and draws in a different mode
    if(newSegment != null) {
      PVector end = mouseVector();
      line(newSegment.start.x, newSegment.start.y, end.x, end.y);
    }
  }
  world.draw(editMode);
  popMatrix();
  drawHelp();  
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
      Segment s = world.nearestSegment(mv);
      if (s != null) world.createCar(s, s.nearestAlpha(mv));
      break;
    case 'r':
      world.removeCar(world.nearestCar(mv));
      break;
    case 't':
      world.removeSegment(world.nearestSegment(mv));
      break;
    case 'u':
      new Road(world.nearestSegment(mv)).rebutBothEnds();
      break;
    case '[': world.driveSpeed(1/1.1); break;
    case ']': world.driveSpeed(1.1); break;
    case 'q': oneway = !oneway; break;
    case '1':case '2':case '3': 
      numlanes = Character.getNumericValue(k); break;
    case '4': createTest4(); break;
    case '5': createTest5(); break;
    case '6': createTest6(); break;
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
    "[ ] - slower/faster drivers",
    "g - add car at mouse location",
    "r - remove car",
    "t - remove road segment",
    "u - rebut both ends of road",
    "45.. - load test scenario",
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
    PVector mv = mouseVector();
    Junction j = world.nearestJunction(mv);
    if (j == null) j = world.addJunction(mv);
    newSegment = j.addStarter(new Segment(mv));
  }
}



void mouseReleased() {
  if(editMode) {
    if(newSegment != null) { //make sure we are making a segment
      newSegment.end = mouseVector();
      world.addSegment(newSegment, oneway, numlanes);
      Road r = new Road(newSegment);
      r.rebutBothEnds();
      newSegment = null;
    }
  }
}

float wheelPos = 0;

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  wheelPos += e < 0 ? -1 : e > 0 ? 1 : 0; //<>//
  println(e);
}

void mouseZoom() {
  if (Math.abs(wheelPos)<.1) return;
  wheelPos *= .9;
  float dz = (float) Math.pow(1.05, -wheelPos);
  viewZoom *= dz;
  // zoom toward mouse pointer
  if(dz > 1) {
    PVector mv = new PVector(mouseX - width/2, mouseY - height/2);
    viewPortVec.add(mv.mult(1 - dz));
  }
}


void createTestCars(int m) {
  for(int i = 0; i < m; i++) {
    world.createCar();
  } 
}

void createTest5() {
  world = new World();
  boolean w=false; int n=1;
  PVector a = new PVector(-200, -200);
  PVector b = new PVector(-200, 200);
  world.addSegment(new Segment(a, b), w, n);
  createTestCars(8);
}


void createTest6() {
  world = new World();
  boolean w=false; int n=3;
  // use the z=2.5 to make the junctions a little bigger
  PVector a = new PVector(0, 400, 2.5);
  PVector b = new PVector(400, 400, 2.5);
  PVector c = new PVector(-400, 0, 2.5);
  PVector d = new PVector(0, 0, 2.5);
  PVector e = new PVector(400, 0);
  PVector f = new PVector(0, -400);
  PVector g = new PVector(400, -400, 2.5);
  world.addSegment(new Segment(a, b), w, n);
  world.addSegment(new Segment(a, c), w, n);
  world.addSegment(new Segment(a, d), w, n);
  world.addSegment(new Segment(b, d), w, n);
  world.addSegment(new Segment(b, e), w, n);
  world.addSegment(new Segment(c, d), w, n);
  world.addSegment(new Segment(d, e), w, n);
  world.addSegment(new Segment(d, f), w, n);
  world.addSegment(new Segment(d, g), w, n);
  world.addSegment(new Segment(e, g), w, n);
  world.addSegment(new Segment(f, g), w, n);
  createTestCars(200);
}

void createTest4() {
  world = new World();
  boolean w=false; int n=2;
  PVector a = new PVector(-200, -200);
  PVector b = new PVector(-200, 200);
  PVector c = new PVector(200, 200);
  PVector d = new PVector(200, -200);
  world.addSegment(new Segment(a, b), w, n);
  world.addSegment(new Segment(b, c), w, n);
  world.addSegment(new Segment(c, d), w, n);
  world.addSegment(new Segment(d, a), w, n);
  createTestCars(50);
  
  //for(Junction j:world.globalJunctions) println(j.pos);
}

// corrects for screen pan and zoom //<>//
PVector mouseVector() {
  return PVector.sub(new PVector(mouseX - width/2, mouseY - height/2).mult(1 / viewZoom), viewPortVec);
}