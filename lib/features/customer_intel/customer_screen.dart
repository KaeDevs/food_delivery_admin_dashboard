import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/customer_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customers = ref.watch(customerProvider);
    final churnRiskCount = customers.where((c) => c.churnRiskScore > 0.7).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Customer Intelligence', style: theme.textTheme.headlineSmall),
                const Spacer(),
                if (churnRiskCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: kWarning.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                    child: Text('$churnRiskCount Customers at Churn Risk', style: const TextStyle(color: kWarning, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Cohort Analysis'),
                Tab(text: 'Behaviour'),
                Tab(text: 'Risk'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(customers: customers),
                  const Center(child: Text('Cohort Analysis Grid under construction')),
                  const Center(child: Text('Behaviour Analytics under construction')),
                  const Center(child: Text('Risk Table under construction')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final List<dynamic> customers;
  const _OverviewTab({required this.customers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            width: 300,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search Customer Name or Phone...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Phone')),
                  DataColumn(label: Text('Total Orders')),
                  DataColumn(label: Text('Lifetime Value')),
                  DataColumn(label: Text('Churn Risk')),
                  DataColumn(label: Text('Sub Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: customers.map((c) {
                  return DataRow(
                    cells: [
                      DataCell(Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      DataCell(Text('****${c.phone.substring(c.phone.length - 4)}')),
                      DataCell(Text('${c.totalOrders}')),
                      DataCell(Text(Formatters.currency(c.lifetimeValue))),
                      DataCell(
                        Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: LinearProgressIndicator(
                                value: c.churnRiskScore,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                                color: c.churnRiskScore > 0.7 ? kDanger : (c.churnRiskScore > 0.4 ? kWarning : kSuccess),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(Formatters.percent(c.churnRiskScore)),
                          ],
                        ),
                      ),
                      DataCell(Text(c.subscriptionStatus.toUpperCase())),
                      DataCell(
                        OutlinedButton(
                          onPressed: () => context.push('/customers/${c.id}'),
                          child: const Text('View Profile'),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
