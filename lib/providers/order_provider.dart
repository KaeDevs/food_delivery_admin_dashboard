import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/order.dart';
import '../data/mock/mock_orders.dart';
import '../data/models/audit_log.dart';
import '../data/mock/mock_audit_logs.dart';

final orderProvider = StateNotifierProvider<OrderListNotifier, List<Order>>((ref) {
  return OrderListNotifier();
});

class OrderListNotifier extends StateNotifier<List<Order>> {
  OrderListNotifier() : super(MockOrders.orders);

  void updateOrder(String id, Order updated) {
    state = state.map((o) => o.id == id ? updated : o).toList();
  }

  void reassignRider(String orderId, String newRiderId, String reasonCode, String adminId, String adminRole) {
    final idx = state.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final old = state[idx];
    final updated = old.copyWith(riderId: newRiderId, status: OrderStatus.riderAssigned);
    state = [...state]..[idx] = updated;

    MockAuditLogs.logs.insert(0, AuditLog(
      id: 'aud-auto-${DateTime.now().millisecondsSinceEpoch}',
      actorAdminId: adminId,
      actorRole: adminRole,
      actionName: 'REASSIGN_ORDER',
      entityType: 'order',
      entityId: orderId,
      beforeState: 'rider:${old.riderId ?? "unassigned"}',
      afterState: 'rider:$newRiderId',
      reasonCode: reasonCode,
      timestamp: DateTime.now(),
    ));
  }

  void extendEta(String orderId, int extraMinutes, String reasonCode, String adminId, String adminRole) {
    final idx = state.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final old = state[idx];
    if (old.promisedDeliveryAt == null) return;
    final updated = old.copyWith(
      promisedDeliveryAt: old.promisedDeliveryAt!.add(Duration(minutes: extraMinutes)),
      isSlaBreached: false,
    );
    state = [...state]..[idx] = updated;

    MockAuditLogs.logs.insert(0, AuditLog(
      id: 'aud-auto-${DateTime.now().millisecondsSinceEpoch}',
      actorAdminId: adminId, actorRole: adminRole,
      actionName: 'EXTEND_ETA', entityType: 'order', entityId: orderId,
      beforeState: 'eta:${old.promisedDeliveryAt}', afterState: 'eta:${updated.promisedDeliveryAt}',
      reasonCode: reasonCode, timestamp: DateTime.now(),
    ));
  }

  void forceCancel(String orderId, CancellationReason reason, String adminId, String adminRole) {
    final idx = state.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final old = state[idx];
    final updated = old.copyWith(status: OrderStatus.cancelled, cancellationReason: reason);
    state = [...state]..[idx] = updated;

    MockAuditLogs.logs.insert(0, AuditLog(
      id: 'aud-auto-${DateTime.now().millisecondsSinceEpoch}',
      actorAdminId: adminId, actorRole: adminRole,
      actionName: 'FORCE_CANCEL', entityType: 'order', entityId: orderId,
      beforeState: old.status.name, afterState: 'cancelled',
      reasonCode: reason.name, timestamp: DateTime.now(),
    ));
  }

  void issueCompensation(String orderId, double amount, String reason, String adminId, String adminRole) {
    MockAuditLogs.logs.insert(0, AuditLog(
      id: 'aud-auto-${DateTime.now().millisecondsSinceEpoch}',
      actorAdminId: adminId, actorRole: adminRole,
      actionName: 'ISSUE_COMPENSATION', entityType: 'order', entityId: orderId,
      beforeState: 'compensation:0', afterState: 'compensation:$amount',
      reasonCode: reason, timestamp: DateTime.now(),
    ));
  }
}

// Derived providers
final delayedOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderProvider).where((o) => o.isSlaBreached).toList();
});

final activeOrdersProvider = Provider<List<Order>>((ref) {
  return ref.watch(orderProvider).where((o) =>
    o.status != OrderStatus.delivered &&
    o.status != OrderStatus.cancelled &&
    o.status != OrderStatus.failed
  ).toList();
});

final ordersByStatusProvider = Provider.family<List<Order>, OrderStatus>((ref, status) {
  return ref.watch(orderProvider).where((o) => o.status == status).toList();
});

final todayOrdersProvider = Provider<List<Order>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return ref.watch(orderProvider).where((o) => o.placedAt.isAfter(today)).toList();
});

final todayDeliveredProvider = Provider<List<Order>>((ref) {
  return ref.watch(todayOrdersProvider).where((o) => o.status == OrderStatus.delivered).toList();
});
