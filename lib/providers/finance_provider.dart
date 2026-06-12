import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/payment_transaction.dart';
import '../data/mock/mock_transactions.dart';

final financeProvider = StateNotifierProvider<FinanceNotifier, List<PaymentTransaction>>((ref) => FinanceNotifier());

class FinanceNotifier extends StateNotifier<List<PaymentTransaction>> {
  FinanceNotifier() : super(MockTransactions.transactions);
  void updateTransaction(String id, PaymentTransaction updated) { state = state.map((t) => t.id == id ? updated : t).toList(); }
}

final failedTransactionsProvider = Provider<List<PaymentTransaction>>((ref) => ref.watch(financeProvider).where((t) => t.status == PaymentStatus.failed).toList());
