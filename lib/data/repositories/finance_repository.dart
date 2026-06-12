import '../models/payment_transaction.dart';
import '../mock/mock_transactions.dart';

class FinanceRepository {
  static List<PaymentTransaction> getAll() => MockTransactions.transactions;
  static List<PaymentTransaction> getFailed() => MockTransactions.transactions.where((t) => t.status == PaymentStatus.failed).toList();
  static List<PaymentTransaction> getByChannel(PaymentChannel channel) => MockTransactions.transactions.where((t) => t.channel == channel).toList();
  static List<PaymentTransaction> getRefunded() => MockTransactions.transactions.where((t) => t.isRefunded).toList();
  static Map<PaymentChannel, int> getChannelDistribution() {
    final map = <PaymentChannel, int>{};
    for (final t in MockTransactions.transactions) { map[t.channel] = (map[t.channel] ?? 0) + 1; }
    return map;
  }
}
