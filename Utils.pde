import java.util.Collections;

static class Utils {
  static void addCar(Segment s, Car c) {
    insertByOrder(c, s.cars);
    if(c.s != null) removeCar(c.s, c);
    c.s = s;
  }
  
  // add the car to the list in a sorted way.
  // the car with the biggest alpha is the 0th car
  static void insertByOrder(Car c, ArrayList<Car> list) {
    if(list.size() == 0) {list.add(c); return;} // put the first item if list is empty
    for(int i = 0; i < list.size(); i++) {
      if(c.alpha > list.get(i).alpha) {
        list.add(i, c);
        return;
      }
    }
    list.add(c);
  }
  
  static void removeCar(Segment s, Car c) {
    s.cars.remove(c);
  }
  
  static boolean isVectorNear(PVector v1, PVector v2, float dist) {
    return v1.dist(v2) < dist;
  }
  
  static void deleteCar(Car c) {
    removeCar(c.s, c);
  }
}