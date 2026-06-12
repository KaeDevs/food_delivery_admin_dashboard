import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/restaurant.dart';
import '../data/mock/mock_restaurants.dart';
import '../core/constants/app_constants.dart';

final restaurantProvider = StateNotifierProvider<RestaurantListNotifier, List<Restaurant>>((ref) {
  return RestaurantListNotifier();
});

class RestaurantListNotifier extends StateNotifier<List<Restaurant>> {
  RestaurantListNotifier() : super(MockRestaurants.restaurants);

  void updateRestaurant(String id, Restaurant updated) {
    state = state.map((r) => r.id == id ? updated : r).toList();
  }

  void toggleOnline(String id) {
    final idx = state.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    state = [...state]..[idx] = state[idx].copyWith(isOnline: !state[idx].isOnline);
  }
}

final restaurantsBelowRatingProvider = Provider<List<Restaurant>>((ref) {
  return ref.watch(restaurantProvider)
    .where((r) => r.rating > 0 && r.rating < AppConstants.restaurantRatingThreshold)
    .toList();
});

final activeRestaurantsProvider = Provider<List<Restaurant>>((ref) {
  return ref.watch(restaurantProvider)
    .where((r) => r.status == RestaurantStatus.active && r.isOnline)
    .toList();
});
