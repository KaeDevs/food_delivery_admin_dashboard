import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/order.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rider_provider.dart';
import '../../../data/models/delivery_partner.dart';

enum InterventionType { reassign, extendEta, forceCancel, compensate }

void showInterventionDialog(BuildContext context, WidgetRef ref, Order order, InterventionType type) {
  switch (type) {
    case InterventionType.reassign:
      _showReassignDialog(context, ref, order);
      break;
    case InterventionType.extendEta:
      _showExtendEtaDialog(context, ref, order);
      break;
    case InterventionType.forceCancel:
      _showForceCancelDialog(context, ref, order);
      break;
    case InterventionType.compensate:
      _showCompensateDialog(context, ref, order);
      break;
  }
}

void _showReassignDialog(BuildContext context, WidgetRef ref, Order order) {
  final riders = ref.read(riderProvider).where((r) => r.status == RiderStatus.available).toList();
  String? selectedRider;
  String reason = 'Rider delayed';

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Reassign Rider'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order: ${order.id}', style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Rider'),
                items: riders.map((r) => DropdownMenuItem(
                  value: r.id,
                  child: Text('${r.name} (${r.zoneId})'),
                )).toList(),
                onChanged: (v) => setState(() => selectedRider = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Reason'),
                value: reason,
                items: ['Rider delayed', 'Rider unreachable', 'Rider reassignment request', 'SLA breach prevention']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setState(() => reason = v ?? reason),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: selectedRider == null ? null : () {
              final auth = ref.read(authProvider);
              ref.read(orderProvider.notifier).reassignRider(
                order.id, selectedRider!, reason, auth?.id ?? '', auth?.role ?? '',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Rider reassigned for ${order.id}')),
              );
            },
            child: const Text('Reassign'),
          ),
        ],
      ),
    ),
  );
}

void _showExtendEtaDialog(BuildContext context, WidgetRef ref, Order order) {
  int extraMinutes = 10;
  String reason = 'Restaurant delay';

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Extend ETA'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order: ${order.id}', style: Theme.of(ctx).textTheme.bodySmall),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (final mins in [10, 20, 30])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('+$mins min'),
                        selected: extraMinutes == mins,
                        onSelected: (s) => setState(() => extraMinutes = mins),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Reason'),
                controller: TextEditingController(text: reason),
                onChanged: (v) => reason = v,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final auth = ref.read(authProvider);
              ref.read(orderProvider.notifier).extendEta(
                order.id, extraMinutes, reason, auth?.id ?? '', auth?.role ?? '',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ETA extended by $extraMinutes min for ${order.id}')),
              );
            },
            child: const Text('Extend'),
          ),
        ],
      ),
    ),
  );
}

void _showForceCancelDialog(BuildContext context, WidgetRef ref, Order order) {
  CancellationReason reason = CancellationReason.systemError;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Force Cancel Order'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order: ${order.id}', style: Theme.of(ctx).textTheme.bodySmall),
              Text('This action cannot be undone.', style: TextStyle(color: Theme.of(ctx).colorScheme.error, fontSize: 13)),
              const SizedBox(height: 16),
              DropdownButtonFormField<CancellationReason>(
                decoration: const InputDecoration(labelText: 'Reason *'),
                value: reason,
                items: CancellationReason.values.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r.name),
                )).toList(),
                onChanged: (v) => setState(() => reason = v ?? reason),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () {
              final auth = ref.read(authProvider);
              ref.read(orderProvider.notifier).forceCancel(
                order.id, reason, auth?.id ?? '', auth?.role ?? '',
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order ${order.id} cancelled')),
              );
            },
            child: const Text('Force Cancel'),
          ),
        ],
      ),
    ),
  );
}

void _showCompensateDialog(BuildContext context, WidgetRef ref, Order order) {
  final amountController = TextEditingController(text: '50');
  String reason = 'Delay compensation';

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Issue Compensation'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order: ${order.id}', style: Theme.of(ctx).textTheme.bodySmall),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: 'Amount (₹)', prefixText: '₹ '),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(labelText: 'Reason'),
              controller: TextEditingController(text: reason),
              onChanged: (v) => reason = v,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final amount = double.tryParse(amountController.text) ?? 50;
            final auth = ref.read(authProvider);
            ref.read(orderProvider.notifier).issueCompensation(
              order.id, amount, reason, auth?.id ?? '', auth?.role ?? '',
            );
            Navigator.pop(ctx);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('₹$amount compensation issued for ${order.id}')),
            );
          },
          child: const Text('Issue'),
        ),
      ],
    ),
  );
}
