static class JunctionTemplateLoader  {
  static final String JUNCTION_TEMPLATE_FILENAME = "junction_templates.json";
  
  static ArrayList<JunctionTemplate> templates;
  static boolean loaded;
  
  JunctionTemplateLoader(JSONArray jsonArr, Traffic parent) {
   this.loaded = false;
   if(jsonArr != null) loadTemplates(jsonArr, parent);
  }
  
  JunctionTemplateLoader() {
    this(null, null);
  }
  
  void loadTemplates(JSONArray arr, Traffic parent) {
    templates = new ArrayList<JunctionTemplate>();
    for(int i = 0; i < arr.size(); i++) {
      JunctionTemplate temp = parent.new JunctionTemplate(arr.getJSONObject(i));
      templates.add(temp);
    }
    loaded = true;
  }
}

class JunctionTemplate {
  String name;
  int[][] canGo;
  
  JunctionTemplate(JSONObject obj) {
    this.name = obj.getString("name");
    this.canGo = parseCanGo(obj.getJSONArray("stateTable"));
  }
  
  int[][] parseCanGo(JSONArray arr) {
    int size1 = arr.size();
    int size2 = arr.getJSONArray(0).size();
    int[][] tempGo = new int[size1][size2];
    
    for(int i = 0; i < arr.size(); i++) {
      JSONArray state = arr.getJSONArray(i);
      for(int j = 0; j < state.size(); j++) {
        tempGo[i][j] = state.getInt(j);
      }
    }
    
    return tempGo;
  }
}