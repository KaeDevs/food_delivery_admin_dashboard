import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/customer_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String id;
  const CustomerDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(customerProvider);
    final customer = customers.where((c) => c.id == id).firstOrNull;

    if (customer == null) return const Center(child: Text('Customer not found'));

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          if (customer.isPromoAbuser)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Chip(
                avatar: Icon(Icons.warning, color: Colors.white, size: 16),
                label: Text('Promo Abuser'),
                backgroundColor: kDanger,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _InfoCard('Email', customer.email),
                _InfoCard('Phone', customer.phone),
                _InfoCard('Total Orders', '${customer.totalOrders}'),
                _InfoCard('Lifetime Value', Formatters.currency(customer.lifetimeValue)),
                _InfoCard('Cohort', customer.acquisitionCohort),
                _InfoCard('Last Order', Formatters.dateShort(customer.lastOrderDate)),
                _InfoCard('Address', customer.fullAddress),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Account Risks', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: kWarning),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Churn Risk Score: ${Formatters.percent(customer.churnRiskScore)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: customer.churnRiskScore, color: kWarning, minHeight: 8),
                    const SizedBox(height: 16),
                    Text('Refund Rate: ${Formatters.percent(customer.refundRate)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: customer.refundRate, color: customer.refundRate > 0.3 ? kDanger : kInfo, minHeight: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _InfoCard(String title, String value) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
