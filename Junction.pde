class Junction {
  private ArrayList<Segment> segIn;
  private ArrayList<Segment> segOut;
  PVector pos;
  float radius;
  
  Junction(PVector p, float r) {
    pos = p; radius = r;
    segIn = new ArrayList<Segment>();
    segOut = new ArrayList<Segment>();
  }
  
  Junction(PVector p) {
    this(p, 30);
  }
  
  Segment addSegOut(Segment s) {
    s.startjun = this;
    segOut.add(s);
    return s;
  }
  
  Segment addSegIn(Segment s) {
    s.endjun = this;
    segIn.add(s);
    return s;
  }
  
  void draw() {
   // noStroke();
   stroke(100);
   noFill();
   // fill(#3DA329);  // light green
    ellipseMode(RADIUS);
    ellipse(pos.x, pos.y, radius, radius);
    stroke(128);
    strokeWeight(.5);
    for (Segment s: segIn) line(s.end.x, s.end.y, pos.x, pos.y);
    for (Segment s: segOut) line(s.start.x, s.start.y, pos.x, pos.y);
  }
}