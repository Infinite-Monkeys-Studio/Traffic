class Junction {
  ArrayList<Segment> segIn;
  ArrayList<Segment> segOut;
  PVector pos;
  float radius;
  
  Junction(PVector p, float r) {
    pos = p; radius = r;
    segIn = new ArrayList<Segment>();
    segOut = new ArrayList<Segment>();
  }
  
  void draw() {
    noStroke();
    fill(#3DA329);  // light green
    ellipseMode(RADIUS);
    ellipse(pos.x, pos.y, radius, radius);
    stroke(128);
    strokeWeight(.5);
    for (Segment s: segIn) line(s.end.x, s.end.y, pos.x, pos.y);
    for (Segment s: segOut) line(s.start.x, s.start.y, pos.x, pos.y);
  }
}