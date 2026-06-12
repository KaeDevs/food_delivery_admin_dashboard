import 'dart:math';
import '../models/order.dart';

class MockOrders {
  static List<Order> orders = [];

  static void seed() {
    final now = DateTime.now();
    final rng = Random(42);
    final zones = ['koramangala', 'whitefield', 'indiranagar', 'hsr_layout', 'electronic_city', 'jayanagar'];
    final channels = ['upi', 'card', 'wallet', 'netBanking', 'cod'];
    final customerIds = List.generate(30, (i) => 'cust-${(i + 1).toString().padLeft(3, '0')}');
    final restaurantIds = List.generate(20, (i) => 'rest-${(i + 1).toString().padLeft(3, '0')}');
    final riderIds = List.generate(25, (i) => 'rider-${(i + 1).toString().padLeft(3, '0')}');

    final menuItems = [
      'Chicken Biryani', 'Paneer Butter Masala', 'Margherita Pizza', 'Caesar Salad',
      'Veg Fried Rice', 'Butter Chicken', 'Masala Dosa', 'Pasta Alfredo',
      'Chocolate Cake', 'Garlic Naan', 'Fish Curry', 'Mushroom Soup',
      'Tandoori Chicken', 'Spring Rolls', 'Ice Cream Sundae',
    ];

    orders = [];

    // 20 delivered today orders
    for (int i = 0; i < 20; i++) {
      final placedAt = now.subtract(Duration(hours: rng.nextInt(10) + 1, minutes: rng.nextInt(60)));
      final deliveryTime = placedAt.add(Duration(minutes: 25 + rng.nextInt(20)));
      final promisedTime = placedAt.add(const Duration(minutes: 40));
      final isBreach = deliveryTime.isAfter(promisedTime.add(const Duration(minutes: 10)));
      final value = 200.0 + rng.nextInt(800).toDouble();
      orders.add(Order(
        id: 'ORD-${(i + 1).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(riderIds.length)],
        status: OrderStatus.delivered,
        items: [
          OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1 + rng.nextInt(3), price: value * 0.6),
          OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value * 0.4),
        ],
        totalValue: value,
        paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt,
        promisedDeliveryAt: promisedTime,
        actualDeliveryAt: deliveryTime,
        zoneId: zones[rng.nextInt(zones.length)],
        isSlaBreached: isBreach,
      ));
    }

    // 10 recently delivered (last 2 hours)
    for (int i = 20; i < 30; i++) {
      final placedAt = now.subtract(Duration(minutes: 30 + rng.nextInt(90)));
      final deliveryTime = placedAt.add(Duration(minutes: 20 + rng.nextInt(25)));
      final promisedTime = placedAt.add(const Duration(minutes: 40));
      final value = 250.0 + rng.nextInt(600).toDouble();
      orders.add(Order(
        id: 'ORD-${(i + 1).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(riderIds.length)],
        status: OrderStatus.delivered,
        items: [
          OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value),
        ],
        totalValue: value,
        paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt,
        promisedDeliveryAt: promisedTime,
        actualDeliveryAt: deliveryTime,
        zoneId: zones[rng.nextInt(zones.length)],
        isSlaBreached: false,
      ));
    }

    // 5 SLA breached orders (active)
    for (int i = 30; i < 35; i++) {
      final placedAt = now.subtract(Duration(minutes: 60 + rng.nextInt(30)));
      final promisedTime = placedAt.add(const Duration(minutes: 35));
      final value = 300.0 + rng.nextInt(500).toDouble();
      final statuses = [OrderStatus.onTheWay, OrderStatus.pickedUp, OrderStatus.riderAssigned, OrderStatus.preparing, OrderStatus.onTheWay];
      orders.add(Order(
        id: 'ORD-${(i + 1).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(15)],
        status: statuses[i - 30],
        items: [
          OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1 + rng.nextInt(2), price: value),
        ],
        totalValue: value,
        paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt,
        promisedDeliveryAt: promisedTime,
        zoneId: zones[rng.nextInt(zones.length)],
        isSlaBreached: true,
      ));
    }

    // 3 cancelled orders with different reasons
    orders.add(Order(
      id: 'ORD-0036', customerId: 'cust-005', restaurantId: 'rest-003',
      status: OrderStatus.cancelled, items: [OrderItem(menuItemId: 'menu-1', name: 'Chicken Biryani', quantity: 2, price: 450)],
      totalValue: 450, paymentChannel: 'upi', placedAt: now.subtract(const Duration(hours: 3)),
      zoneId: 'koramangala', cancellationReason: CancellationReason.customerPrePrep,
    ));
    orders.add(Order(
      id: 'ORD-0037', customerId: 'cust-012', restaurantId: 'rest-008',
      status: OrderStatus.cancelled, items: [OrderItem(menuItemId: 'menu-5', name: 'Veg Fried Rice', quantity: 1, price: 280)],
      totalValue: 280, paymentChannel: 'card', placedAt: now.subtract(const Duration(hours: 4)),
      zoneId: 'indiranagar', cancellationReason: CancellationReason.restaurantRejection,
    ));
    orders.add(Order(
      id: 'ORD-0038', customerId: 'cust-020', restaurantId: 'rest-014',
      status: OrderStatus.cancelled, items: [OrderItem(menuItemId: 'menu-11', name: 'Fish Curry', quantity: 1, price: 520)],
      totalValue: 520, paymentChannel: 'wallet', placedAt: now.subtract(const Duration(hours: 5)),
      zoneId: 'electronic_city', cancellationReason: CancellationReason.riderUnavailable,
    ));

    // 2 failed orders
    orders.add(Order(
      id: 'ORD-0039', customerId: 'cust-008', restaurantId: 'rest-004',
      status: OrderStatus.failed, items: [OrderItem(menuItemId: 'menu-3', name: 'Margherita Pizza', quantity: 1, price: 399)],
      totalValue: 399, paymentChannel: 'netBanking', placedAt: now.subtract(const Duration(hours: 2)),
      zoneId: 'whitefield',
    ));
    orders.add(Order(
      id: 'ORD-0040', customerId: 'cust-015', restaurantId: 'rest-011',
      status: OrderStatus.failed, items: [OrderItem(menuItemId: 'menu-1', name: 'Chicken Biryani', quantity: 3, price: 750)],
      totalValue: 750, paymentChannel: 'upi', placedAt: now.subtract(const Duration(hours: 6)),
      zoneId: 'hsr_layout',
    ));

    // Active orders in various statuses
    // placed
    for (int i = 0; i < 3; i++) {
      final placedAt = now.subtract(Duration(minutes: 5 + rng.nextInt(10)));
      final value = 200.0 + rng.nextInt(500).toDouble();
      orders.add(Order(
        id: 'ORD-${(41 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        status: OrderStatus.placed,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 45)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // restaurantAccepted
    for (int i = 0; i < 2; i++) {
      final placedAt = now.subtract(Duration(minutes: 10 + rng.nextInt(10)));
      final value = 300.0 + rng.nextInt(400).toDouble();
      orders.add(Order(
        id: 'ORD-${(44 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        status: OrderStatus.restaurantAccepted,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 40)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // preparing
    for (int i = 0; i < 3; i++) {
      final placedAt = now.subtract(Duration(minutes: 15 + rng.nextInt(10)));
      final value = 250.0 + rng.nextInt(450).toDouble();
      orders.add(Order(
        id: 'ORD-${(46 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        status: OrderStatus.preparing,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1 + rng.nextInt(2), price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 40)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // ready
    for (int i = 0; i < 2; i++) {
      final placedAt = now.subtract(Duration(minutes: 20 + rng.nextInt(10)));
      final value = 350.0 + rng.nextInt(300).toDouble();
      orders.add(Order(
        id: 'ORD-${(49 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        status: OrderStatus.ready,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 35)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // riderAssigned
    for (int i = 0; i < 2; i++) {
      final placedAt = now.subtract(Duration(minutes: 22 + rng.nextInt(10)));
      final value = 280.0 + rng.nextInt(400).toDouble();
      orders.add(Order(
        id: 'ORD-${(51 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(riderIds.length)],
        status: OrderStatus.riderAssigned,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 40)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // riderAtRestaurant
    for (int i = 0; i < 2; i++) {
      final placedAt = now.subtract(Duration(minutes: 25 + rng.nextInt(10)));
      final value = 320.0 + rng.nextInt(350).toDouble();
      orders.add(Order(
        id: 'ORD-${(53 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(riderIds.length)],
        status: OrderStatus.riderAtRestaurant,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 38)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // pickedUp
    for (int i = 0; i < 2; i++) {
      final placedAt = now.subtract(Duration(minutes: 30 + rng.nextInt(10)));
      final value = 400.0 + rng.nextInt(300).toDouble();
      orders.add(Order(
        id: 'ORD-${(55 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(riderIds.length)],
        status: OrderStatus.pickedUp,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 40)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // onTheWay
    for (int i = 0; i < 3; i++) {
      final placedAt = now.subtract(Duration(minutes: 32 + rng.nextInt(10)));
      final value = 350.0 + rng.nextInt(350).toDouble();
      orders.add(Order(
        id: 'ORD-${(57 + i).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(riderIds.length)],
        status: OrderStatus.onTheWay,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: placedAt.add(const Duration(minutes: 40)),
        zoneId: zones[rng.nextInt(zones.length)],
      ));
    }

    // Fill to 60 with more delivered orders
    while (orders.length < 60) {
      final idx = orders.length;
      final placedAt = now.subtract(Duration(hours: 6 + rng.nextInt(18)));
      final deliveryTime = placedAt.add(Duration(minutes: 25 + rng.nextInt(20)));
      final promisedTime = placedAt.add(const Duration(minutes: 40));
      final value = 200.0 + rng.nextInt(600).toDouble();
      orders.add(Order(
        id: 'ORD-${(idx + 1).toString().padLeft(4, '0')}',
        customerId: customerIds[rng.nextInt(customerIds.length)],
        restaurantId: restaurantIds[rng.nextInt(restaurantIds.length)],
        riderId: riderIds[rng.nextInt(riderIds.length)],
        status: OrderStatus.delivered,
        items: [OrderItem(menuItemId: 'menu-${rng.nextInt(40) + 1}', name: menuItems[rng.nextInt(menuItems.length)], quantity: 1, price: value)],
        totalValue: value, paymentChannel: channels[rng.nextInt(channels.length)],
        placedAt: placedAt, promisedDeliveryAt: promisedTime, actualDeliveryAt: deliveryTime,
        zoneId: zones[rng.nextInt(zones.length)],
        isSlaBreached: deliveryTime.isAfter(promisedTime.add(const Duration(minutes: 10))),
      ));
    }

    // Link some support tickets
    orders[30] = orders[30].copyWith(supportTicketId: 'tkt-001');
    orders[31] = orders[31].copyWith(supportTicketId: 'tkt-005');
  }
}
