
class Road {
  
  // This is a TEMPORARY object so you can deal with a group of 
  // segments that have the same start and end junctions
  
  // list[0] are going opposite direction to list[1]
  
  ArrayList<Segment>[] list;
    
  Road(Segment s) {
    list = new ArrayList[2];
    list[0] = new ArrayList<Segment>();
    list[1] = new ArrayList<Segment>();
    
    // create a new road using all the neighbors of the segment
    for (Segment i = leftmost(s); i != null; i = i.rightside) list[0].add(i);
    for (Segment i = leftmost(opposite(s)); i != null; i = i.rightside) list[1].add(i);
  }
  
  Segment leftmost(Segment s) {
    while (s.leftside != null) s = s.leftside;
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
    //int n = list[a].size() + list[1-a].size();
    
  }
  
  void rebutEnd() {
  }
  
}
    