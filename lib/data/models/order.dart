enum OrderStatus {
  placed,
  restaurantAccepted,
  preparing,
  ready,
  riderAssigned,
  riderAtRestaurant,
  pickedUp,
  onTheWay,
  delivered,
  cancelled,
  failed,
}

enum CancellationReason {
  customerPrePrep,
  customerPostPrep,
  restaurantRejection,
  riderUnavailable,
  paymentFailure,
  systemError,
}

class OrderItem {
  final String menuItemId;
  final String name;
  final int quantity;
  final double price;

  const OrderItem({
    required this.menuItemId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  OrderItem copyWith({
    String? menuItemId,
    String? name,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      menuItemId: menuItemId ?? this.menuItemId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}

class Order {
  final String id;
  final String customerId;
  final String restaurantId;
  final String? riderId;
  final OrderStatus status;
  final List<OrderItem> items;
  final double totalValue;
  final String paymentChannel;
  final DateTime placedAt;
  final DateTime? promisedDeliveryAt;
  final DateTime? actualDeliveryAt;
  final String zoneId;
  final CancellationReason? cancellationReason;
  final bool isSlaBreached;
  final String? supportTicketId;

  const Order({
    required this.id,
    required this.customerId,
    required this.restaurantId,
    this.riderId,
    required this.status,
    required this.items,
    required this.totalValue,
    required this.paymentChannel,
    required this.placedAt,
    this.promisedDeliveryAt,
    this.actualDeliveryAt,
    required this.zoneId,
    this.cancellationReason,
    this.isSlaBreached = false,
    this.supportTicketId,
  });

  Order copyWith({
    String? id,
    String? customerId,
    String? restaurantId,
    String? riderId,
    OrderStatus? status,
    List<OrderItem>? items,
    double? totalValue,
    String? paymentChannel,
    DateTime? placedAt,
    DateTime? promisedDeliveryAt,
    DateTime? actualDeliveryAt,
    String? zoneId,
    CancellationReason? cancellationReason,
    bool? isSlaBreached,
    String? supportTicketId,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      restaurantId: restaurantId ?? this.restaurantId,
      riderId: riderId ?? this.riderId,
      status: status ?? this.status,
      items: items ?? this.items,
      totalValue: totalValue ?? this.totalValue,
      paymentChannel: paymentChannel ?? this.paymentChannel,
      placedAt: placedAt ?? this.placedAt,
      promisedDeliveryAt: promisedDeliveryAt ?? this.promisedDeliveryAt,
      actualDeliveryAt: actualDeliveryAt ?? this.actualDeliveryAt,
      zoneId: zoneId ?? this.zoneId,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      isSlaBreached: isSlaBreached ?? this.isSlaBreached,
      supportTicketId: supportTicketId ?? this.supportTicketId,
    );
  }

  /// Friendly display name for the status
  String get statusLabel {
    switch (status) {
      case OrderStatus.placed:
        return 'Placed';
      case OrderStatus.restaurantAccepted:
        return 'Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.riderAssigned:
        return 'Rider Assigned';
      case OrderStatus.riderAtRestaurant:
        return 'At Restaurant';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'On The Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.failed:
        return 'Failed';
    }
  }
}
