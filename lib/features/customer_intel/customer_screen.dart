import 'package:admin_dashboard/shared/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/customer_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer.dart';

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
    final churnRiskCount = customers
        .where((c) => c.churnRiskScore > 0.7)
        .length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTabController(
        length: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Customer Intelligence',
                  style: theme.textTheme.headlineSmall,
                ),
                const Spacer(),
                if (churnRiskCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kWarning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$churnRiskCount Customers at Churn Risk',
                      style: const TextStyle(
                        color: kWarning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  _CohortAnalysisTab(customers: customers),
                  _BehaviourTab(customers: customers),
                  _RiskTab(customers: customers),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerStatefulWidget {
  final List<Customer> customers;
  const _OverviewTab({required this.customers});

  @override
  ConsumerState<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends ConsumerState<_OverviewTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var filtered = widget.customers;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.phone.toLowerCase().contains(q),
          )
          .toList();
    }

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
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowHeight: 48,
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Total Orders')),
                      DataColumn(label: Text('Lifetime Value')),
                      DataColumn(label: Text('Churn Risk')),
                      DataColumn(label: Text('Sub Status')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: filtered.map((c) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '****${c.phone.substring(c.phone.length - 4)}',
                            ),
                          ),
                          DataCell(Text(c.locationArea)),
                          DataCell(Text('${c.totalOrders}')),
                          DataCell(Text(Formatters.currency(c.lifetimeValue))),
                          DataCell(
                            Row(
                              children: [
                                SizedBox(
                                  width: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: c.churnRiskScore,
                                      minHeight: 6,
                                      backgroundColor: Theme.of(
                                        context,
                                      ).colorScheme.surfaceContainerHighest,
                                      color: c.churnRiskScore > 0.7
                                          ? kDanger
                                          : (c.churnRiskScore > 0.4
                                                ? kWarning
                                                : kSuccess),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(Formatters.percent(c.churnRiskScore)),
                              ],
                            ),
                          ),
                          DataCell(Text(c.subscriptionStatus.toUpperCase())),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                OutlinedButton(
                                  onPressed: () =>
                                      context.push('/customers/${c.id}'),
                                  child: const Text('View Profile'),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showEditCustomerDialog(c),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditCustomerDialog(Customer c) {
    final nameCtrl = TextEditingController(text: c.name);
    final locationCtrl = TextEditingController(text: c.locationArea);
    String selectedStatus = c.subscriptionStatus;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Customer'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location Area',
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Subscription Status',
                    ),
                    items: ['none', 'active', 'expired'].map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedStatus = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final updated = c.copyWith(
                      name: nameCtrl.text,
                      locationArea: locationCtrl.text,
                      subscriptionStatus: selectedStatus,
                    );
                    ref
                        .read(customerProvider.notifier)
                        .updateCustomer(c.id, updated);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CohortAnalysisTab extends StatelessWidget {
  final List<Customer> customers;
  const _CohortAnalysisTab({required this.customers});

  @override
  Widget build(BuildContext context) {
    // Group by acquisitionCohort
    final cohorts = <String, List<dynamic>>{};
    for (final c in customers) {
      cohorts.putIfAbsent(c.acquisitionCohort, () => []).add(c);
    }

    final sortedCohorts = cohorts.keys.toList()..sort();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Retention by Cohort',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Cohort')),
                        DataColumn(label: Text('Customers')),
                        DataColumn(label: Text('Avg LTV')),
                        DataColumn(label: Text('Avg Churn Risk')),
                        DataColumn(label: Text('Active Subs')),
                      ],
                      rows: sortedCohorts.map((cohort) {
                        final group = cohorts[cohort]!;
                        final avgLtv =
                            group.fold(0.0, (sum, c) => sum + c.lifetimeValue) /
                            group.length;
                        final avgRisk =
                            group.fold(
                              0.0,
                              (sum, c) => sum + c.churnRiskScore,
                            ) /
                            group.length;
                        final activeSubs = group
                            .where((c) => c.subscriptionStatus == 'active')
                            .length;

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                cohort,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(Text('${group.length}')),
                            DataCell(Text(Formatters.currency(avgLtv))),
                            DataCell(Text(Formatters.percent(avgRisk))),
                            DataCell(Text('$activeSubs / ${group.length}')),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BehaviourTab extends StatelessWidget {
  final List<Customer> customers;
  const _BehaviourTab({required this.customers});

  @override
  Widget build(BuildContext context) {
    final promoAbusers = customers.where((c) => c.isPromoAbuser).length;
    final highRefunds = customers.where((c) => c.refundRate > 0.15).length;
    final highFrequency = customers.where((c) => c.totalOrders > 20).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Behaviour Summary',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                'High Frequency',
                '$highFrequency',
                Icons.shopping_bag,
                kSuccess,
              ),
              _StatCard(
                'Promo Abusers',
                '$promoAbusers',
                Icons.local_offer,
                kWarning,
              ),
              _StatCard(
                'High Refunds (>15%)',
                '$highRefunds',
                Icons.assignment_return,
                kDanger,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Behaviour Detail',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Customer')),
                        DataColumn(label: Text('Total Orders')),
                        DataColumn(label: Text('Avg Order Value')),
                        DataColumn(label: Text('Refund Rate')),
                        DataColumn(label: Text('Tags')),
                      ],
                      rows: customers.map((c) {
                        final aov = c.totalOrders > 0
                            ? c.lifetimeValue / c.totalOrders
                            : 0.0;
                        return DataRow(
                          cells: [
                            DataCell(Text(c.name)),
                            DataCell(Text('${c.totalOrders}')),
                            DataCell(Text(Formatters.currency(aov))),
                            DataCell(Text(Formatters.percent(c.refundRate))),
                            DataCell(
                              Row(
                                children: [
                                  if (c.isPromoAbuser)
                                    const StatusChip(
                                      label: 'Promo Abuser',
                                      color: kWarning,
                                    ),
                                  if (c.refundRate > 0.15) ...[
                                    if (c.isPromoAbuser)
                                      const SizedBox(width: 4),
                                    const StatusChip(
                                      label: 'High Refund',
                                      color: kDanger,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? widget.color.withOpacity(0.5)
                  : theme.colorScheme.outlineVariant,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.color.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 20, color: widget.color),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskTab extends StatelessWidget {
  final List<Customer> customers;
  const _RiskTab({required this.customers});

  @override
  Widget build(BuildContext context) {
    final atRisk = customers.where((c) => c.churnRiskScore > 0.4).toList();
    atRisk.sort((a, b) => b.churnRiskScore.compareTo(a.churnRiskScore));

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'High Risk Customers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Risk Score')),
                        DataColumn(label: Text('Last Order')),
                        // DataColumn(label: Text('Action')),
                      ],
                      rows: atRisk.map((c) {
                        return DataRow(
                          cells: [
                            DataCell(Text(c.name)),
                            DataCell(
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: c.churnRiskScore,
                                        minHeight: 6,
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHighest,
                                        color: c.churnRiskScore > 0.7
                                            ? kDanger
                                            : kWarning,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(Formatters.percent(c.churnRiskScore)),
                                ],
                              ),
                            ),
                            DataCell(
                              Text(Formatters.dateShort(c.lastOrderDate)),
                            ),
                            // DataCell(
                            //   OutlinedButton(
                            //     onPressed: () {},
                            //     child: const Text('Send Offer'),
                            //   ),
                            // ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
