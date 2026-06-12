import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/customer.dart';
import '../data/mock/mock_customers.dart';

final customerProvider = StateNotifierProvider<CustomerListNotifier, List<Customer>>((ref) => CustomerListNotifier());

class CustomerListNotifier extends StateNotifier<List<Customer>> {
  CustomerListNotifier() : super(MockCustomers.customers);
  void updateCustomer(String id, Customer updated) { state = state.map((c) => c.id == id ? updated : c).toList(); }
}

final churnRiskCustomersProvider = Provider<List<Customer>>((ref) => ref.watch(customerProvider).where((c) => c.churnRiskScore > 0.7).toList());
