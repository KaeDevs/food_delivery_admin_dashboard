import '../models/payment_transaction.dart';
import '../models/order.dart';
import 'mock_orders.dart';

class MockTransactions {
  static List<PaymentTransaction> transactions = [];

  static void seed() {
    final channelMap = {
      'upi': PaymentChannel.upi,
      'card': PaymentChannel.card,
      'wallet': PaymentChannel.wallet,
      'netBanking': PaymentChannel.netBanking,
      'cod': PaymentChannel.cod,
    };

    transactions = [];

    for (int i = 0; i < MockOrders.orders.length; i++) {
      final order = MockOrders.orders[i];
      PaymentStatus status;
      String? failureReason;
      bool isRefunded = false;
      double? refundAmount;

      if (order.status == OrderStatus.failed) {
        status = PaymentStatus.failed;
        failureReason = i % 2 == 0 ? 'Gateway timeout' : 'Insufficient funds';
      } else if (order.status == OrderStatus.cancelled) {
        status = PaymentStatus.refunded;
        isRefunded = true;
        refundAmount = order.totalValue;
      } else {
        status = PaymentStatus.success;
      }

      transactions.add(PaymentTransaction(
        id: 'txn-${(i + 1).toString().padLeft(4, '0')}',
        orderId: order.id,
        amount: order.totalValue,
        channel: channelMap[order.paymentChannel] ?? PaymentChannel.upi,
        status: status,
        timestamp: order.placedAt,
        failureReason: failureReason,
        isRefunded: isRefunded,
        refundAmount: refundAmount,
      ));
    }

    // Add 3 extra failed transactions
    final now = DateTime.now();
    transactions.add(PaymentTransaction(
      id: 'txn-0061', orderId: 'ORD-0039', amount: 399,
      channel: PaymentChannel.upi, status: PaymentStatus.failed,
      timestamp: now.subtract(const Duration(hours: 1)),
      failureReason: 'UPI service unavailable',
    ));
    transactions.add(PaymentTransaction(
      id: 'txn-0062', orderId: 'ORD-0040', amount: 750,
      channel: PaymentChannel.netBanking, status: PaymentStatus.failed,
      timestamp: now.subtract(const Duration(hours: 2)),
      failureReason: 'Bank server error',
    ));
    transactions.add(PaymentTransaction(
      id: 'txn-0063', orderId: 'ORD-0035', amount: 520,
      channel: PaymentChannel.card, status: PaymentStatus.failed,
      timestamp: now.subtract(const Duration(hours: 3)),
      failureReason: 'Card declined',
    ));
  }
}
