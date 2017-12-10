ArrayList<Car> globalCars;
ArrayList<Segment> globalSegments;

void setup() {
  size(800, 800);
  globalSegments = new ArrayList<Segment>();
  globalCars = new ArrayList<Car>();
  createTestSegments();
  createTestCars();
}


void draw() {
  background(#1D8309);
  for(Car c : globalCars) {
    c.draw();
  }
  
  for(Segment s : globalSegments) {
    s.draw();
    s.step();
  }
}

void createTestCars() {
  Car test = new Car();
  test.goalRate = .007;
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