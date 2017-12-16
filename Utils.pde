import java.util.Collections;

static class Utils {
  //add OR MOVE a car to a new road.
  static void addCar(Segment s, Car c) {
    if (c.s != null) removeCar(c.s, c);//take the car off the old road
    insertByOrder(c, s.cars); //put it on the new road
    c.s = s; //tell the car what road he's on
  }

  // add the car to the list in a sorted way.
  // the car with the biggest alpha is the 0th car
  static void insertByOrder(Car c, ArrayList<Car> list) {
    if (list.size() == 0) {
      list.add(c); 
      return;
    } // put the first item if list is empty
    for (int i = 0; i < list.size(); i++) {
      if (c.alpha > list.get(i).alpha) {
        list.add(i, c);
        return;
      }
    }
    list.add(c);
  }

  //Takes a car off a road.
  static void removeCar(Segment s, Car c) {
    s.cars.remove(c);
  }
  
  //TODO remove cars from all lists. global, and segments
  static void deleteCar(Car c) {
    removeCar(c.s, c);
  }
  
  //true if the dist between is less than or equal to dist
  static boolean isVectorNear(PVector v1, PVector v2, float dist) {
    return v1.dist(v2) <= dist;
  }

}