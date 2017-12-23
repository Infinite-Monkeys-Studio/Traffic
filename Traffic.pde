PVector viewPortVec;
float viewZoom;
boolean[] keyList = new boolean[256];


boolean paused = false;
boolean editMode = false;
boolean helpMode = false;
boolean oneway = true;
int numlanes = 1;

Segment newSegment;
World world;

void setup() {
  size(800, 800);
  surface.setResizable(true);
  viewPortVec = new PVector(0, 0);
  viewZoom = 1;
  world = new World();
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
    if(newSegment != null) {
      PVector end = mouseVector();
      line(newSegment.start.x, newSegment.start.y, end.x, end.y);
    }
  }
  world.draw(editMode);
  
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
    case 'q': oneway = !oneway; break;
    case '1':case '2':case '3': numlanes = Character.getNumericValue(k); break;
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
    newSegment = j.addSegOut(new Segment(mv));
  }
}



void mouseReleased() {
  if(editMode) {
    if(newSegment != null) { //make sure we are making a segment
      newSegment.end = mouseVector();
      newSegment.refresh(); // have to refresh to calculate new length
<<<<<<< HEAD
<<<<<<< HEAD
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
      newSegment.startjun = j2;
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
=======
      world.addSegment(newSegment, oneway, numlanes);
>>>>>>> cc887e80bd8b461ba1d8f4dd234562bb64a1e9dd
=======
      world.addSegment(newSegment, oneway, numlanes);
>>>>>>> cc887e80bd8b461ba1d8f4dd234562bb64a1e9dd
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


void createTestCars() {
  
  Car test = new Car();
<<<<<<< HEAD
  //test.driver.naturalSpeed -= .5;
  globalCars.add(test);
  Utils.addCar(globalSegments.get(1), test);
=======
=======
>>>>>>> cc887e80bd8b461ba1d8f4dd234562bb64a1e9dd
  test.driver.goalRate = 1.5;
  // TODO  -- this is ugly!  combine next two lines into single world method.
  world.globalCars.add(test);
  Utils.addCar(world.globalSegments.get(1), test);
<<<<<<< HEAD
>>>>>>> cc887e80bd8b461ba1d8f4dd234562bb64a1e9dd
=======
>>>>>>> cc887e80bd8b461ba1d8f4dd234562bb64a1e9dd
  
  float l = world.globalSegments.get(0).length;
  for(int i = 0; i < 4; i++) {
    Car c = new Car();
    c.alpha = ((i*55)/l);
    world.globalCars.add(c);    
    Utils.addCar(world.globalSegments.get(0), c);   
  } 
}

void createTestSegments() {
  boolean w=false; int n=2;
  PVector a = new PVector(-200, -200);
  PVector b = new PVector(-200, 200);
  PVector c = new PVector(200, 200);
  PVector d = new PVector(200, -200);
  world.addSegment(new Segment(a, b), w, n);
  world.addSegment(new Segment(b, c), w, n);
  world.addSegment(new Segment(c, d), w, n);
  world.addSegment(new Segment(d, a), w, n);
}

// corrects for screen pan and zoom
PVector mouseVector() {
  return PVector.sub(new PVector(mouseX - width/2, mouseY - height/2).mult(1 / viewZoom), viewPortVec);
}