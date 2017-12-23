class Junction {
  private ArrayList<Segment> enders;
  private ArrayList<Segment> starters;
  PVector pos;
  float radius;
  
  Junction(PVector p, float r) {
    pos = p.copy(); radius = r;
    enders = new ArrayList<Segment>();
    starters = new ArrayList<Segment>();
  }
  
  Junction(PVector p) {
    this(p, 30);
  }
  
  Segment addStarter(Segment s) {
    s.startjun = this;
    starters.add(s);
    return s;
  }
  
  Segment addEnder(Segment s) {
    s.endjun = this;
    enders.add(s);
    return s;
  }
  
  void draw(boolean editmode) {
   // noStroke();
   stroke(70);
   noFill();
   // fill(#3DA329);  // light green
    ellipseMode(RADIUS);
    ellipse(pos.x, pos.y, radius, radius);
    strokeWeight(.5);
    for (Segment s: enders) {
      line(s.end.x, s.end.y, pos.x, pos.y);
      drawChevron(s.end, pos, 3);
    }
    stroke(0);
    for (Segment s: starters) {
      line(s.start.x, s.start.y, pos.x, pos.y);
      drawChevron(pos, s.start, 3);
    }
  }
}