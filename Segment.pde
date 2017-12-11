class Segment {
  ArrayList<Car> cars;
  ArrayList<Segment> segments;
  PVector start;
  PVector end;
  float length;
  
  Segment(PVector start, PVector end) {
    this.start = start;
    this.end = end;
    this.length = PVector.dist(start, end);
    
    cars = new ArrayList<Car>();
    segments = new ArrayList<Segment>();
  }
  
  void draw() {
    pushMatrix();
    translate(start.x, start.y);
    line(0,0, end.x-start.x, end.y-start.y);
    popMatrix();
  }
  
  void drawEditMode() {
    pushMatrix();
    fill(255, 0, 0);
    translate(start.x, start.y);
    ellipse(0, 0, 10, 10);
    ellipse(end.x-start.x, end.y-start.y, 10, 10);

    PVector h = PVector.sub(end, start).div(2);
    translate(h.x, h.y);
    rotate(PVector.sub(end, start).heading());
    line(0, 0, -10, 5);
    line(0, 0, -10, -5);
    popMatrix();
  }
  
  void refresh() {
    this.length = PVector.dist(start, end);
  }
  
  void step() {
    Car previousCar = null;
    
    for(int i = 0; i < cars.size(); i++) {
      Car c = cars.get(i);
      c.step(previousCar);
      
      previousCar = c;
    }
  }
  
  void link(Segment s) {
    segments.add(s);
  }
}