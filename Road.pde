
class Road {
  
  // This is a TEMPORARY object so you can deal with a group of 
  // segments that have the same start and end junctions
  
  // startjun[0] is the start of all seg in list[0], etc
  // list[0] are going opposite direction to list[1]
  
  ArrayList<Segment>[] list;
  Junction[] startjun;
    
  Road(Segment s) {
    list = new ArrayList[2];
    list[0] = new ArrayList<Segment>();
    list[1] = new ArrayList<Segment>();
    startjun = new Junction[] { s.startjun, s.endjun };
    
    // create a new road using all the neighbors of the segment
    for (Segment i = rightmost(s); i != null; i = i.leftside) list[0].add(i);
    for (Segment i = leftmost(opposite(s)); i != null; i = i.rightside) list[1].add(i);
  }
  
  Segment leftmost(Segment s) {
    if (s != null)
      while (s.leftside != null) s = s.leftside;
    return s;
  }
  
  Segment rightmost(Segment s) {
    if (s != null)
      while (s.rightside != null) s = s.rightside;
    return s;
  }
  
  // get ANY segment that is going the opposite way from s (start end are reversed)
  Segment opposite(Segment s) {
    for (Segment i: s.endjun.starters) {
      if (i.endjun == s.startjun) return i;
    }
    return null; // none found!
  }
  
  // set a=0 or 1, to tell which end of the road to rebut
  void rebut(int a) {
    if (list[a].size()==0) return;
    int n = list[a].size() + list[1-a].size();
    PVector p = startjun[a].pos.copy();
    PVector axis = PVector.sub(startjun[1-a].pos, p).normalize();
    PVector perp = new PVector(axis.y, -axis.x).mult(lanesize * 2 * (0.5 - a));
    p.add(axis.mult(startjun[a].radius));
    p.sub(PVector.mult(perp, (n - 1)*0.5 + 1));
    for (Segment s: list[0]) {
      (a==0 ? s.start : s.end).set(p.add(perp).copy());
    }
    for (Segment s: list[1]) {
      (a==1 ? s.start : s.end).set(p.add(perp).copy());
    }
  }
  
  void rebutBothEnds() {
    rebut(0);
    rebut(1);
  }  
}