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
    final failed = transactions.where((t) => t.status == PaymentStatus.failed).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: DefaultTabController(
        length: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Finance & Settlements', style: Theme.of(context).textTheme.headlineSmall),
                const Spacer(),
                if (failed.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: kDanger, borderRadius: BorderRadius.circular(16)),
                    child: Text('${failed.length} Failed Txns', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Center(child: Text('Overview Dashboard under construction')),
                  _TransactionsTab(transactions: transactions),
                  const Center(child: Text('Settlements under construction')),
                  const Center(child: Text('Rider Payouts under construction')),
                  const Center(child: Text('Refunds Queue under construction')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsTab extends StatelessWidget {
  final List<PaymentTransaction> transactions;
  const _TransactionsTab({required this.transactions});

  @override
  Widget build(BuildContext context) {
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
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list), label: const Text('Filters')),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                columns: const [
                  DataColumn(label: Text('Txn ID')),
                  DataColumn(label: Text('Order ID')),
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Channel')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Timestamp')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: transactions.map((t) {
                  return DataRow(
                    color: WidgetStatePropertyAll(t.status == PaymentStatus.failed ? kDanger.withOpacity(0.05) : null),
                    cells: [
                      DataCell(Text(t.id.substring(0, 8), style: const TextStyle(fontFamily: 'monospace'))),
                      DataCell(Text(t.orderId.substring(0, 8))),
                      DataCell(Text(Formatters.currency(t.amount))),
                      DataCell(Text(t.channel.name.toUpperCase())),
                      DataCell(StatusChip(
                        label: t.status.name.toUpperCase(),
                        color: t.status == PaymentStatus.success ? kSuccess : (t.status == PaymentStatus.failed ? kDanger : kWarning),
                      )),
                      DataCell(Text(Formatters.dateTime(t.timestamp))),
                      DataCell(
                        t.status == PaymentStatus.failed
                            ? OutlinedButton(onPressed: () {}, child: const Text('Retry'))
                            : const SizedBox.shrink(),
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
