import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/payment_transaction.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/status_chip.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(financeProvider);
    final failed = transactions
        .where((t) => t.status == PaymentStatus.failed)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTabController(
        length: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Finance & Settlements',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                if (failed.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kDanger,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${failed.length} Failed Txns',
                      style: const TextStyle(
                        color: Colors.white,
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
                Tab(text: 'Transactions'),
                Tab(text: 'Settlements'),
                Tab(text: 'Rider Payouts'),
                Tab(text: 'Refunds & Disputes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _OverviewTab(transactions: transactions),
                  _TransactionsTab(transactions: transactions),
                  const _SettlementsTab(),
                  const _RiderPayoutsTab(),
                  const _RefundsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsTab extends StatefulWidget {
  final List<PaymentTransaction> transactions;
  const _TransactionsTab({required this.transactions});

  @override
  State<_TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<_TransactionsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    var filtered = widget.transactions;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (t) =>
                t.id.toLowerCase().contains(q) ||
                t.orderId.toLowerCase().contains(q),
          )
          .toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search Order ID or Txn ID...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ],
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
                      DataColumn(label: Text('Txn ID')),
                      DataColumn(label: Text('Order ID')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Channel')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Timestamp')),
                    ],
                    rows: filtered.map((t) {
                      return DataRow(
                        color: WidgetStatePropertyAll(
                          t.status == PaymentStatus.failed
                              ? kDanger.withOpacity(0.05)
                              : null,
                        ),
                        cells: [
                          DataCell(
                            Text(
                              t.id.substring(0, 8),
                              style: const TextStyle(fontFamily: 'monospace'),
                            ),
                          ),
                          DataCell(Text(t.orderId.substring(0, 8))),
                          DataCell(Text(Formatters.currency(t.amount))),
                          DataCell(Text(t.channel.name.toUpperCase())),
                          DataCell(
                            StatusChip(
                              label: t.status.name.toUpperCase(),
                              color: t.status == PaymentStatus.success
                                  ? kSuccess
                                  : (t.status == PaymentStatus.failed
                                        ? kDanger
                                        : kWarning),
                            ),
                          ),
                          DataCell(Text(Formatters.dateTime(t.timestamp))),
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
}

class _OverviewTab extends StatelessWidget {
  final List<PaymentTransaction> transactions;
  const _OverviewTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
    final totalVolume = transactions
        .where((t) => t.status == PaymentStatus.success)
        .fold(0.0, (sum, t) => sum + t.amount);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                'Total Volume',
                Formatters.currencyCompact(totalVolume),
                Icons.account_balance_wallet,
                kInfo,
              ),
              _StatCard(
                'Platform Revenue',
                Formatters.currencyCompact(totalVolume * 0.15),
                Icons.trending_up,
                kSuccess,
              ),
              _StatCard(
                'Pending Settlements',
                Formatters.currencyCompact(totalVolume * 0.2),
                Icons.pending_actions,
                kWarning,
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          const Text('No recent activity available.'),
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

class _SettlementsTab extends StatelessWidget {
  const _SettlementsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Merchant Settlements',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, contraints) => ConstrainedBox(
                constraints: BoxConstraints(minWidth: contraints.maxWidth),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Batch ID')),
                    DataColumn(label: Text('Merchant')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: const [
                    DataRow(
                      cells: [
                        DataCell(Text('STL-001')),
                        DataCell(Text('Spicy Palace')),
                        DataCell(Text('₹4,500.00')),
                        DataCell(
                          StatusChip(label: 'COMPLETED', color: kSuccess),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('STL-002')),
                        DataCell(Text('Vegan Bites')),
                        DataCell(Text('₹1,200.00')),
                        DataCell(StatusChip(label: 'PENDING', color: kWarning)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RiderPayoutsTab extends StatelessWidget {
  const _RiderPayoutsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Rider Payouts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) => ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Payout ID')),
                    DataColumn(label: Text('Rider Name')),
                    DataColumn(label: Text('Amount')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: const [
                    DataRow(
                      cells: [
                        DataCell(Text('PAY-101')),
                        DataCell(Text('Suresh Babu')),
                        DataCell(Text('₹850.00')),
                        DataCell(StatusChip(label: 'PROCESSING', color: kInfo)),
                      ],
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text('PAY-102')),
                        DataCell(Text('Arun Kumar')),
                        DataCell(Text('₹1,120.00')),
                        DataCell(
                          StatusChip(label: 'COMPLETED', color: kSuccess),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RefundsTab extends StatelessWidget {
  const _RefundsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Refunds & Disputes',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (context, constraints) => ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Order ID')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Reason')),
                    DataColumn(label: Text('Amount')),
                  ],
                  rows: const [
                    DataRow(
                      cells: [
                        DataCell(Text('ORD-991')),
                        DataCell(Text('John Doe')),
                        DataCell(Text('Missing Item')),
                        DataCell(Text('₹150.00')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
