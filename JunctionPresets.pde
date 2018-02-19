final class JunctionTemplateLoader {
  static final String JUNCTION_TEMPLATE_FILENAME = "junction_templates.json";
  
  ArrayList<JunctionTemplate> templates;
  
  JunctionTemplateLoader(String filename) {
    loadTemplates(filename);
  }
  
  JunctionTemplateLoader() {
    this(JUNCTION_TEMPLATE_FILENAME);
  }
  
  void loadTemplates(String filename) {
    templates = new ArrayList<JunctionTemplate>();
    JSONArray arr = loadJSONArray(filename);
    for(int i = 0; i < arr.size(); i++) {
      JunctionTemplate temp = new JunctionTemplate(arr.getJSONObject(i));
      templates.add(temp);
    }
  }
  
  void loadTemplates() {
    loadTemplates(JUNCTION_TEMPLATE_FILENAME);
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