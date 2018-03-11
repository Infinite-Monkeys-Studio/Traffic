

  
void saveMap() {
  selectOutput("Select a file to save map:", "saveCallback");
}

void loadMap() {
  selectInput("Select a file to load map:", "loadCallback");
}

// CALLBACK FUNCTION
void saveCallback(File selection) {
  if (selection != null) saveMapFile(world, selection.getAbsolutePath());
}

// CALLBACK FUNCTION
void loadCallback(File selection) {
  if (selection != null) world = loadMapFile(selection.getAbsolutePath());
}


void saveMapFile(World w, String filename)
{
  JSONObject data = new JSONObject();
  data.setInt("version", 1);
  data.setString("timestamp", timestamp());
  data.setInt("numcars",w.carList.size());
  data.setFloat("viewx",viewPortVec.x);
  data.setFloat("viewy",viewPortVec.y);
  data.setFloat("viewz",viewZoom);
  data.setFloat("lanesize",lanesize);  
  data.setJSONArray("nodelist",getJunctions(w));
  data.setJSONArray("waylist",getSegments(w));
  saveJSONObject(data, filename);
}

JSONArray getJunctions(World w)
{
  JSONArray nodelist = new JSONArray();
  int i = 0;
  for (Junction j : w.junList) {
    JSONObject node = new JSONObject();
    node.setInt("id",i);
    node.setFloat("x", j.pos.x);
    node.setFloat("y", j.pos.y);
    node.setFloat("r", j.radius);
    if (j.templateName != null) 
      node.setString("tn", j.templateName);
    nodelist.setJSONObject(i, node);
    j.id = i++;
  }
  return nodelist;
}

JSONArray getSegments(World w)
{
  int i = 0;
  JSONArray waylist = new JSONArray();
  for (Junction j1 : w.junList) {
    for (Junction j2 : j1.neighbors(1)) {
      int lanes = j1.countSegments(j2);
      boolean oneway = lanes != j2.countSegments(j1);
      if (oneway || j1.id < j2.id) {
        JSONObject seg = new JSONObject();
        seg.setBoolean("oneway", oneway);
        seg.setInt("numlanes", lanes);
        seg.setInt("from",j1.id);
        seg.setInt("to",j2.id);
        waylist.setJSONObject(i++, seg);
      }
    }    
  }
  return waylist;
}

World loadMapFile(String filename)
{
  if (filename==null) return null;
  World w = new World();
  w.filename = filename;
  JSONObject data = loadJSONObject(filename);
  int version = data.getInt("version",0);
  String timestamp = data.getString("timestamp","");  
  viewPortVec.x = data.getFloat("viewx",viewPortVec.x);
  viewPortVec.y = data.getFloat("viewy",viewPortVec.y);
  viewZoom = data.getFloat("viewz",viewZoom);
  lanesize = data.getFloat("lanesize",lanesize);
  //-------------------
  // LOAD ALL THE JUNCTIONS
  JSONArray nodelist = data.getJSONArray("nodelist");
  ArrayList<PVector> veclist = new ArrayList<PVector>();
  for (int i = 0; i < nodelist.size(); ++i) {
    JSONObject node = nodelist.getJSONObject(i);
    veclist.add(new PVector(node.getFloat("x"), node.getFloat("y")));
    // Todo-- create junctions here?
  }
  //-------------------
  // LOAD ALL THE ROADS
  JSONArray waylist = data.getJSONArray("waylist");
  for (int i = 0; i < waylist.size(); ++i) {
    JSONObject way = waylist.getJSONObject(i);
    Segment s = new Segment(veclist.get(way.getInt("from")),veclist.get(way.getInt("to")));
    w.addSegment(s, way.getBoolean("oneway"), way.getInt("numlanes"));
  }
  //-----------------
  // make some random cars
  int n = data.getInt("numcars",0);
  for (int i = 0; i < n; ++i)   w.createCar();
  return w;
}  