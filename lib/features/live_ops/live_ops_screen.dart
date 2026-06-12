import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/rider_provider.dart';
import '../../data/models/order.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/status_chip.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/sla_badge.dart';
import 'widgets/intervention_sheet.dart';

class LiveOpsScreen extends ConsumerStatefulWidget {
  const LiveOpsScreen({super.key});
  @override
  ConsumerState<LiveOpsScreen> createState() => _LiveOpsScreenState();
}

class _LiveOpsScreenState extends ConsumerState<LiveOpsScreen> {
  String? _selectedOrderId;
  String _zoneFilter = 'all';
  String _searchQuery = '';
  bool _delayedOnly = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allOrders = ref.watch(orderProvider);
    final delayed = ref.watch(delayedOrdersProvider);
    final active = ref.watch(activeOrdersProvider);
    final riders = ref.watch(riderProvider);

    // Filter orders
    var filteredOrders = List<Order>.from(allOrders);
    if (_zoneFilter != 'all') {
      filteredOrders = filteredOrders.where((o) => o.zoneId == _zoneFilter).toList();
    }
    if (_delayedOnly) {
      filteredOrders = filteredOrders.where((o) => o.isSlaBreached).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((o) =>
          o.id.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    // Sort: SLA breached first, then by placedAt descending
    filteredOrders.sort((a, b) {
      if (a.isSlaBreached && !b.isSlaBreached) return -1;
      if (!a.isSlaBreached && b.isSlaBreached) return 1;
      return b.placedAt.compareTo(a.placedAt);
    });

    final selectedOrder = _selectedOrderId != null
        ? allOrders.where((o) => o.id == _selectedOrderId).firstOrNull
        : null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top stat chips
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _StatChip(label: 'Active', value: '${active.length}', color: kInfo),
              _StatChip(label: 'Delayed', value: '${delayed.length}', color: kDanger),
              _StatChip(label: 'SLA At Risk', value: '${allOrders.where((o) => o.isSlaBreached).length}', color: kWarning),
              _StatChip(label: 'Avg ETA', value: '32 min', color: kNeutral),
            ],
          ),
          const SizedBox(height: 16),
          // Filter bar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: 160,
                height: 36,
                child: DropdownButtonFormField<String>(
                  value: _zoneFilter,
                  isDense: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Zones', style: TextStyle(fontSize: 13))),
                    ...['koramangala', 'whitefield', 'indiranagar', 'hsr_layout', 'electronic_city', 'jayanagar']
                        .map((z) => DropdownMenuItem(value: z, child: Text(z.replaceAll('_', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' '), style: const TextStyle(fontSize: 13)))),
                  ],
                  onChanged: (v) => setState(() => _zoneFilter = v ?? 'all'),
                ),
              ),
              FilterChip(
                label: const Text('Delayed Only'),
                selected: _delayedOnly,
                onSelected: (v) => setState(() => _delayedOnly = v),
              ),
              SizedBox(
                width: 200,
                height: 36,
                child: TextField(
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Search order ID...',
                    prefixIcon: Icon(Icons.search, size: 18),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Main content
          Expanded(
            child: Row(
              children: [
                // Order list
                Expanded(
                  flex: _selectedOrderId != null ? 5 : 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${filteredOrders.length} orders', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowHeight: 44,
                              dataRowMinHeight: 48,
                              dataRowMaxHeight: 52,
                              columnSpacing: 20,
                              showCheckboxColumn: false,
                              columns: const [
                                DataColumn(label: Text('Order ID')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Value'), numeric: true),
                                DataColumn(label: Text('Zone')),
                                DataColumn(label: Text('Placed')),
                                DataColumn(label: Text('SLA')),
                              ],
                              rows: filteredOrders.map((order) {
                                final isSelected = order.id == _selectedOrderId;
                                return DataRow(
                                  selected: isSelected,
                                  color: WidgetStatePropertyAll(
                                    order.isSlaBreached
                                        ? kDanger.withOpacity(0.05)
                                        : isSelected
                                            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                                            : null,
                                  ),
                                  onSelectChanged: (_) => setState(() => _selectedOrderId = order.id),
                                  cells: [
                                    DataCell(Text(order.id, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                    DataCell(StatusChip(label: order.statusLabel, color: _statusColor(order.status))),
                                    DataCell(Text(Formatters.currency(order.totalValue), style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(order.zoneId.replaceAll('_', ' '), style: const TextStyle(fontSize: 13))),
                                    DataCell(Text(Formatters.relativeTime(order.placedAt), style: const TextStyle(fontSize: 13))),
                                    DataCell(SlaBadge(order: order)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Detail panel
                if (selectedOrder != null) ...[
                  VerticalDivider(width: 1, color: theme.colorScheme.outlineVariant),
                  Expanded(
                    flex: 5,
                    child: _OrderDetailPanel(
                      order: selectedOrder,
                      riders: riders,
                      onClose: () => setState(() => _selectedOrderId = null),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered: return kSuccess;
      case OrderStatus.cancelled: case OrderStatus.failed: return kDanger;
      case OrderStatus.onTheWay: case OrderStatus.pickedUp: return kInfo;
      case OrderStatus.preparing: return kWarning;
      default: return kNeutral;
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _OrderDetailPanel extends ConsumerWidget {
  final Order order;
  final List<dynamic> riders;
  final VoidCallback onClose;
  const _OrderDetailPanel({required this.order, required this.riders, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final isOpsAdmin = auth?.role == 'Super Admin' || auth?.role == 'Operations Admin';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(order.id, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              StatusChip(label: order.statusLabel, color: _statusColor(order.status)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, size: 20), onPressed: onClose),
            ],
          ),
          const SizedBox(height: 16),

          // Order info
          _DetailRow('Total Value', Formatters.currency(order.totalValue)),
          _DetailRow('Payment', order.paymentChannel.toUpperCase()),
          _DetailRow('Zone', order.zoneId.replaceAll('_', ' ')),
          _DetailRow('Placed', Formatters.dateTime(order.placedAt)),
          if (order.promisedDeliveryAt != null)
            _DetailRow('Promised Delivery', Formatters.dateTime(order.promisedDeliveryAt!)),
          if (order.actualDeliveryAt != null)
            _DetailRow('Actual Delivery', Formatters.dateTime(order.actualDeliveryAt!)),

          const SizedBox(height: 16),
          const SectionHeader(title: 'Order Timeline'),
          const SizedBox(height: 8),
          _OrderTimeline(order: order),

          const SizedBox(height: 16),
          const SectionHeader(title: 'Items'),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(child: Text('${item.name} × ${item.quantity}', style: theme.textTheme.bodySmall)),
                Text(Formatters.currency(item.price), style: theme.textTheme.bodySmall),
              ],
            ),
          )),

          if (order.riderId != null) ...[
            const SizedBox(height: 16),
            _DetailRow('Rider ID', order.riderId!),
          ],

          // Intervention buttons
          if (isOpsAdmin && order.status != OrderStatus.delivered && order.status != OrderStatus.cancelled && order.status != OrderStatus.failed) ...[
            const SizedBox(height: 24),
            const SectionHeader(title: 'Interventions'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Reassign Rider'),
                  onPressed: () => showInterventionDialog(context, ref, order, InterventionType.reassign),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Extend ETA'),
                  onPressed: () => showInterventionDialog(context, ref, order, InterventionType.extendEta),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.cancel_outlined, size: 16, color: kDanger),
                  label: Text('Force Cancel', style: TextStyle(color: kDanger)),
                  style: OutlinedButton.styleFrom(side: BorderSide(color: kDanger)),
                  onPressed: () => showInterventionDialog(context, ref, order, InterventionType.forceCancel),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.currency_rupee, size: 16),
                  label: const Text('Compensate'),
                  onPressed: () => showInterventionDialog(context, ref, order, InterventionType.compensate),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered: return kSuccess;
      case OrderStatus.cancelled: case OrderStatus.failed: return kDanger;
      case OrderStatus.onTheWay: case OrderStatus.pickedUp: return kInfo;
      case OrderStatus.preparing: return kWarning;
      default: return kNeutral;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
          Expanded(child: Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final Order order;
  const _OrderTimeline({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = OrderStatus.values;
    final currentIdx = statuses.indexOf(order.status);

    // Show only relevant statuses
    final showStatuses = order.status == OrderStatus.cancelled || order.status == OrderStatus.failed
        ? [OrderStatus.placed, order.status]
        : statuses.where((s) => s.index <= currentIdx && s != OrderStatus.cancelled && s != OrderStatus.failed).toList();

    return Column(
      children: showStatuses.asMap().entries.map((e) {
        final isLast = e.key == showStatuses.length - 1;
        final isCurrent = e.value == order.status;
        final color = isCurrent ? kInfo : kSuccess;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: isCurrent ? Border.all(color: color, width: 2) : null,
                  ),
                ),
                if (!isLast) Container(width: 2, height: 24, color: kSuccess.withOpacity(0.3)),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              _label(e.value),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                color: isCurrent ? color : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _label(OrderStatus s) {
    switch (s) {
      case OrderStatus.placed: return 'Order Placed';
      case OrderStatus.restaurantAccepted: return 'Restaurant Accepted';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.ready: return 'Ready for Pickup';
      case OrderStatus.riderAssigned: return 'Rider Assigned';
      case OrderStatus.riderAtRestaurant: return 'Rider at Restaurant';
      case OrderStatus.pickedUp: return 'Picked Up';
      case OrderStatus.onTheWay: return 'On the Way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.failed: return 'Failed';
    }
  }
}
