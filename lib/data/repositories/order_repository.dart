import '../models/order.dart';
import '../mock/mock_orders.dart';

class OrderRepository {
  static List<Order> getAll() => MockOrders.orders;

  static List<Order> getByStatus(OrderStatus status) =>
      MockOrders.orders.where((o) => o.status == status).toList();

  static List<Order> getDelayed() =>
      MockOrders.orders.where((o) => o.isSlaBreached).toList();

  static Order? getById(String id) {
    try {
      return MockOrders.orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Order> getByRestaurant(String restaurantId) =>
      MockOrders.orders.where((o) => o.restaurantId == restaurantId).toList();

  static List<Order> getByCustomer(String customerId) =>
      MockOrders.orders.where((o) => o.customerId == customerId).toList();

  static List<Order> getByRider(String riderId) =>
      MockOrders.orders.where((o) => o.riderId == riderId).toList();

  static List<Order> getActiveOrders() =>
      MockOrders.orders.where((o) =>
          o.status != OrderStatus.delivered &&
          o.status != OrderStatus.cancelled &&
          o.status != OrderStatus.failed).toList();

  static void updateStatus(String id, OrderStatus newStatus) {
    final idx = MockOrders.orders.indexWhere((o) => o.id == id);
    if (idx != -1) {
      MockOrders.orders[idx] = MockOrders.orders[idx].copyWith(status: newStatus);
    }
  }
}
