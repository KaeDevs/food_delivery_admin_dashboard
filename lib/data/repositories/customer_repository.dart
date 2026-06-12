import '../models/customer.dart';
import '../mock/mock_customers.dart';

class CustomerRepository {
  static List<Customer> getAll() => MockCustomers.customers;
  static Customer? getById(String id) {
    try { return MockCustomers.customers.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }
  static List<Customer> getChurnRisk(double threshold) => MockCustomers.customers.where((c) => c.churnRiskScore > threshold).toList();
  static List<Customer> getPromoAbusers() => MockCustomers.customers.where((c) => c.isPromoAbuser).toList();
  static List<Customer> getHighRefundRate(double threshold) => MockCustomers.customers.where((c) => c.refundRate > threshold).toList();
}
