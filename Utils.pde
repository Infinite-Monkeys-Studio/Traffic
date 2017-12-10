import java.util.Collections;

static class Utils {
  static void addCar(Segment s, Car c) {
    insertByOrder(c, s.cars);
    if(c.s != null) removeCar(c.s, c);
    c.s = s;
  }
  
  // add the car to the list in a sorted way.
  // the car with the biggest alpha is the 0th car
  static void insertByOrder(Car c, ArrayList<Car> l) {
    if(l.size() == 0) {l.add(c); return;} // put the first item if list is empty
    for(int i = 0; i < l.size(); i++) {
      if(c.alpha > l.get(i).alpha) {
        l.add(i, c);
        return;
      }
    }
    l.add(c);
  }
  
  static void removeCar(Segment s, Car c) {
    s.cars.remove(c);
  }
}