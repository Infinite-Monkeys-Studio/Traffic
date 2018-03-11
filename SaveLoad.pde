


void SaveMap(World w, String filename)
{
  JSONObject data = new JSONObject();
  JSONArray poslist = new JSONArray();
  int i = 0;
  for (Junction j : w.junList) {
    JSONArray pair = new JSONArray();
    pair.setFloat(0, j.pos.x);
    pair.setFloat(0, j.pos.y);
    poslist.setJSONArray(i++, pair);
  }
  
  // TODO convert segments to roads and save them.
}


World LoadMap(String filename)
{
  World w = new World();
  if (filename==null) return w;
  JSONObject data = loadJSONObject(filename);
  // LOAD ALL THE POSITION OF THE JUNCTIONS
  JSONArray poslist = data.getJSONArray("pos-list");
  ArrayList<PVector> veclist = new ArrayList<PVector>();
  for (int i = 0; i < poslist.size(); ++i) {
    JSONArray pair = poslist.getJSONArray(i);
    veclist.add(new PVector(pair.getFloat(0), pair.getFloat(1)));
  }
  // LOAD ALL THE ROADS
  JSONArray waylist = data.getJSONArray("way-list");
  for (int i = 0; i < waylist.size(); ++i) {
    JSONObject way = waylist.getJSONObject(i);
    Segment s = new Segment(veclist.get(way.getInt("from")),veclist.get(way.getInt("to")));
    w.addSegment(s, way.getBoolean("oneway"), way.getInt("numlanes"));
  }
  return w;
}  