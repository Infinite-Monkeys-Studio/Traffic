class Junction {
  private ArrayList<Segment> enders;
  private ArrayList<Segment> starters;
  PVector pos;
  float radius;
  boolean seen;   // temp flag to avoid infinite loops while walking the graph
  int state;
  int stateCounter;
  // map the state + group into value 0..7, in which 1=can go right, 2=straight, 4=left
  int [][] canGo;
  String templateName;
  
  Junction(PVector p, float r) {
    pos = p.copy(); 
    radius = r;
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
    if (editmode) {
      stroke(70);
      noFill();
      // fill(#3DA329);  // light green
      ellipseMode(RADIUS);
      ellipse(pos.x, pos.y, radius, radius);
      strokeWeight(.5);
      for (Segment s : enders) {
        line(s.end.x, s.end.y, pos.x, pos.y);
        drawChevron(s.end, pos, 3);
      }
      stroke(0);
      for (Segment s : starters) {
        line(s.start.x, s.start.y, pos.x, pos.y);
        drawChevron(pos, s.start, 3);
      }
    } else {           // NON EDIT MODE
      fill(90);
      noStroke();
      ellipseMode(RADIUS);
      float r = 1.3 * radius;
      ellipse(pos.x, pos.y, r, r);
      fill(100);
      ellipse(pos.x, pos.y, radius, radius);
    }
  }
  
  
  void step() {
    // change state every few seconds
    if (stateCounter++ > 300) {
      stateCounter = 0;
      state = (state + 1) & 3;
    }
  }


  boolean isYellow() { 
    return stateCounter > 240; 
  }

  ArrayList<Segment> openStarters(Segment ender, float dist) {
    ArrayList<Segment> temp = new ArrayList<Segment>();
    int sig = getSignal(ender.group);
    if (sig == 0)   // RED LIGHT
      return temp;
    PVector a = ender.axis();
    for (Segment s: starters) {
      if (s.isClear(dist)) {
        if (sig == 7) {
          temp.add(s);
        } 
        else {
          float t = turn(a, s.axis());
          // dir is 1=right, 2=straight, 4=left
          int dir = (Math.abs(t) < 0.1) ? 2 : t < 0 ? 4 : 1;
          if ((dir & sig) == dir)
            temp.add(s);
        }
      }
    }
    return temp;
  }
   
  
  
  int getSignal(int group) {
    // gets the value of the signal, 0=red light, 7=green light
    if (canGo == null) 
      return 7;
    if (state < canGo.length && group < canGo[state].length) {
      return canGo[state][group];
    }
    return 0;
  }
  
  
  void setupControl() {
    if(templateName == null) { //get a random name incase we don't have one
      int size = JunctionTemplateLoader.templateNames.size();
      templateName = JunctionTemplateLoader.templateNames.get((int)random(0, size-1));
    }
    
    if(canGo != null) {
      //warn about an overwrite?
    }
    
    //get template
    JunctionTemplate temp = JunctionTemplateLoader.templates.get(templateName);
    this.canGo = temp.canGo;
    
    for (Segment e : enders) {
      PVector a = e.axis();
      if (Math.abs(a.x) > Math.abs(a.y))
        e.group = a.x > 0 ? 2 : 0; 
      else
        e.group = a.y > 0 ? 3 : 1;
    }  
  }
  
  ArrayList<Junction> neighbors() {
    ArrayList<Junction> temp = new ArrayList<Junction>();
    for (Segment s: starters) 
      if (!temp.contains(s.endjun)) temp.add(s.endjun);
    for (Segment e: enders) 
      if (!temp.contains(e.startjun)) temp.add(e.startjun);
    return temp;
  }
  
  void rebut() {
    ArrayList<Junction> temp = new ArrayList<Junction>();
    for (Segment s: starters) 
      if (!temp.contains(s.endjun)) {
        temp.add(s.endjun);
        new Road(s).rebutBothEnds();
      }
    for (Segment e: enders) 
      if (!temp.contains(e.startjun)) {
        temp.add(e.startjun);
        new Road(e).rebutBothEnds();
      }
  }
  
  
}