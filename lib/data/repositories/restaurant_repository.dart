import '../models/restaurant.dart';
import '../mock/mock_restaurants.dart';

class RestaurantRepository {
  static List<Restaurant> getAll() => MockRestaurants.restaurants;
  static Restaurant? getById(String id) {
    try { return MockRestaurants.restaurants.firstWhere((r) => r.id == id); } catch (_) { return null; }
  }
  static List<Restaurant> getByZone(String zoneId) => MockRestaurants.restaurants.where((r) => r.zoneId == zoneId).toList();
  static List<Restaurant> getByStatus(RestaurantStatus status) => MockRestaurants.restaurants.where((r) => r.status == status).toList();
  static List<Restaurant> getBelowRatingThreshold(double threshold) => MockRestaurants.restaurants.where((r) => r.rating > 0 && r.rating < threshold).toList();
  static List<Restaurant> getActive() => MockRestaurants.restaurants.where((r) => r.status == RestaurantStatus.active && r.isOnline).toList();
}
