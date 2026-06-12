import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/order.dart';
import '../../../providers/order_provider.dart';
import '../../../providers/dispatch_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/layouts/two_pane_layout.dart';
import '../live_ops/widgets/sla_badge.dart';

class DispatchScreen extends ConsumerStatefulWidget {
  const DispatchScreen({super.key});

  @override
  ConsumerState<DispatchScreen> createState() => _DispatchScreenState();
}

class _DispatchScreenState extends ConsumerState<DispatchScreen> {
  String _zoneFilter = 'koramangala';
  String? _selectedOrderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dispatchState = ref.watch(dispatchProvider);
    final activeOrders = ref.watch(activeOrdersProvider);

    // Get zones and specific zone data
    final zones = dispatchState.zones;
    final currentZone = zones.firstWhere(
      (z) => z.id == _zoneFilter,
      orElse: () => zones.first,
    );

    // Filter orders to unassigned/ready/preparing for the selected zone
    final dispatchableOrders = activeOrders
        .where(
          (o) =>
              o.zoneId == _zoneFilter &&
              (o.status == OrderStatus.placed ||
                  o.status == OrderStatus.restaurantAccepted ||
                  o.status == OrderStatus.preparing ||
                  o.status == OrderStatus.ready ||
                  o.status == OrderStatus.riderAssigned),
        )
        .toList();

    dispatchableOrders.sort((a, b) {
      if (a.isSlaBreached && !b.isSlaBreached) return -1;
      if (!a.isSlaBreached && b.isSlaBreached) return 1;
      return b.placedAt.compareTo(a.placedAt);
    });

    final selectedOrder = _selectedOrderId != null
        ? dispatchableOrders.where((o) => o.id == _selectedOrderId).firstOrNull
        : null;

    final dsColor = currentZone.demandSupplyRatio > 1.5
        ? kDanger
        : currentZone.demandSupplyRatio > 1.2
        ? kWarning
        : currentZone.demandSupplyRatio < 0.5
        ? kInfo
        : kSuccess;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Dispatch Configuration',
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _zoneFilter,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down),
                items: zones
                    .map(
                      (z) => DropdownMenuItem(
                        value: z.id,
                        child: Text(
                          z.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _zoneFilter = v;
                      _selectedOrderId = null;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Zone Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                _Stat(
                  label: 'Active Orders',
                  value: '${currentZone.activeOrders}',
                ),
                _Stat(
                  label: 'Available Riders',
                  value: '${currentZone.availableRiders}',
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'D/S Ratio',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusChip(
                      label: Formatters.ratio(currentZone.demandSupplyRatio),
                      color: dsColor,
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Surge Pricing',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Switch(
                      value: currentZone.isSurgeActive,
                      onChanged: (v) => ref
                          .read(dispatchProvider.notifier)
                          .toggleSurge(currentZone.id),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Expanded(
            child: TwoPaneLayout(
              splitRatio: 0.5,
              listPane: _OrderListPane(
                orders: dispatchableOrders,
                selectedId: _selectedOrderId,
                onSelect: (id) => setState(() => _selectedOrderId = id),
              ),
              detailPane: selectedOrder != null
                  ? _OrderDispatchDetail(order: selectedOrder)
                  : const Center(
                      child: Text('Select an order to view dispatch options'),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _OrderListPane extends StatelessWidget {
  final List<Order> orders;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _OrderListPane({
    required this.orders,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Dispatch Queue'),
        Expanded(
          child: ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
            itemBuilder: (context, index) {
              final order = orders[index];
              final isSelected = order.id == selectedId;
              return ListTile(
                selected: isSelected,
                selectedTileColor: theme.colorScheme.primaryContainer
                    .withOpacity(0.3),
                title: Row(
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SlaBadge(order: order),
                  ],
                ),
                subtitle: Text(
                  '${order.statusLabel} • ${Formatters.relativeTime(order.placedAt)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: order.riderId != null
                    ? StatusChip(label: 'Assigned', color: kSuccess)
                    : StatusChip(label: 'Unassigned', color: kWarning),
                onTap: () => onSelect(order.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OrderDispatchDetail extends StatelessWidget {
  final Order order;

  const _OrderDispatchDetail({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Dispatch Order ${order.id}',
                  style: theme.textTheme.titleLarge,
                ),
                const Spacer(),
                if (order.riderId != null)
                  StatusChip(
                    label: 'Assigned to ${order.riderId}',
                    color: kSuccess,
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Auto-Dispatch Recommendations'),
            const SizedBox(height: 16),
            // Mock recommendations
            _RiderOption(
              name: 'Suresh Babu',
              distance: '1.2 km',
              eta: '5 min',
              isBest: true,
              score: 98,
            ),
            const SizedBox(height: 8),
            _RiderOption(
              name: 'Arun Kumar',
              distance: '2.5 km',
              eta: '10 min',
              isBest: false,
              score: 85,
            ),
            const SizedBox(height: 8),
            _RiderOption(
              name: 'Manoj Reddy',
              distance: '3.1 km',
              eta: '12 min',
              isBest: false,
              score: 72,
            ),
            const SizedBox(height: 32),
            const SectionHeader(title: 'Manual Override'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search Rider ID or Name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Rider manually assigned')),
                );
              },
              child: const Text('Assign Custom Rider'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiderOption extends StatelessWidget {
  final String name;
  final String distance;
  final String eta;
  final bool isBest;
  final int score;

  const _RiderOption({
    required this.name,
    required this.distance,
    required this.eta,
    required this.isBest,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isBest
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isBest
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            child: Text(name[0], style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isBest) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST MATCH',
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$distance • $eta to restaurant',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isBest ? theme.colorScheme.primary : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Match Score',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          FilledButton.tonal(onPressed: () {}, child: const Text('Assign')),
        ],
      ),
    );
  }
}
