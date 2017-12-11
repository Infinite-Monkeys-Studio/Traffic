PVector viewPortVec;
boolean[] keyList = new boolean[255];


ArrayList<Car> globalCars;
ArrayList<Segment> globalSegments;

boolean paused = false;
boolean editMode = false;

Segment newSegment;

void setup() {
  size(800, 800);
  viewPortVec = new PVector(0, 0);
  globalSegments = new ArrayList<Segment>();
  globalCars = new ArrayList<Car>();
  createTestSegments();
  createTestCars();
}


void draw() {
  background(#1D8309);
  translate(viewPortVec.x, viewPortVec.y);
  keys();
  if(editMode) {
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
  } else {
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
  switch(k) {
    case 'p':
      paused = !paused;
      break;
    case 'e':
      if(newSegment != null) break;
      editMode = !editMode;
      paused = editMode;
      break;
    case 'g':
      float dist = 999999999;
      Car newCar = new Car();
      globalCars.add(newCar);
      for(Segment s : globalSegments) {
        float td = s.start.dist(mouseVector());
        if(td < dist){
          dist = td;
          newCar.s = s;
        }
      }
      Utils.addCar(newCar.s, newCar);
      break;
      
  }
}

void keyPressed() {
  keyList[keyCode&255] = true;

  println(keyCode);
}

void keyReleased() {
  keyList[keyCode&255] = false;
}

void keys() {
  int s = 10;
  if(keyList[65] || keyList[97]) viewPortVec.x += s;
  if(keyList[100] || keyList[68]) viewPortVec.x -= s;
  if(keyList[87] || keyList[119]) viewPortVec.y += s;
  if(keyList[83] || keyList[115]) viewPortVec.y -= s;
}

void mousePressed() {
  if(editMode) {
    //check for segment node
    newSegment = new Segment(mouseVector(), mouseVector());
    for(Segment s : globalSegments) {
      if(Utils.isVectorNear(newSegment.start, s.start, 5)) {
        newSegment.start = s.start;
      } else if(Utils.isVectorNear(newSegment.start, s.end, 5)) {
        newSegment.start = s.end;
        s.link(newSegment);
      }
    }
    //check for car
  }
  
}



void mouseReleased() {
  if(editMode) {
    if(newSegment != null) {
      newSegment.end = mouseVector();
      globalSegments.add(newSegment);
      for(Segment s : globalSegments) {
        if(Utils.isVectorNear(newSegment.end, s.start, 5)) {
          newSegment.end = s.start;
          newSegment.link(s);
        }else if(Utils.isVectorNear(newSegment.end, s.end, 5)) {
          newSegment.end = s.end;
        }
      }
      newSegment.refresh();
      newSegment = null;
    }
  }
}

void createTestCars() {
  Car test = new Car();
  test.goalRate = 1.5;
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
  Segment s1 = new Segment(new PVector(100,100), new PVector(400,100));
  globalSegments.add(s1);
  Segment s2 = new Segment(new PVector(400,100), new PVector(400,400));
  globalSegments.add(s2);
  Segment s3 = new Segment(new PVector(400,400), new PVector(100,400));
  globalSegments.add(s3);
  Segment s4 = new Segment(new PVector(100,400), new PVector(100,100));
  globalSegments.add(s4);
  
  s1.link(s2);
  s2.link(s3);
  s3.link(s4);
  s4.link(s1);
}

PVector mouseVector() {
  return PVector.sub(new PVector(mouseX, mouseY), viewPortVec);
}