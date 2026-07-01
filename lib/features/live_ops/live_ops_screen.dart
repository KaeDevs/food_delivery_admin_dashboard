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
import '../../shared/widgets/empty_state.dart';
import 'widgets/sla_badge.dart';
import 'widgets/intervention_sheet.dart';
import '../dashboard/widgets/kpi_card.dart';
import '../dashboard/widgets/dashboard_card.dart';

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
      filteredOrders = filteredOrders
          .where((o) => o.zoneId == _zoneFilter)
          .toList();
    }
    if (_delayedOnly) {
      filteredOrders = filteredOrders.where((o) => o.isSlaBreached).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders
          .where((o) => o.id.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
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

    final slaAtRiskCount = allOrders.where((o) => o.isSlaBreached).length;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top stats row using premium KpiCards
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              KpiCard(
                title: 'Active Orders',
                value: '${active.length}',
                icon: Icons.local_shipping_outlined,
                trendColor: kInfo,
              ),
              KpiCard(
                title: 'Delayed Orders',
                value: '${delayed.length}',
                icon: Icons.warning_amber_rounded,
                trendColor: kDanger,
              ),
              KpiCard(
                title: 'SLA At Risk',
                value: '$slaAtRiskCount',
                icon: Icons.timer_outlined,
                trendColor: kWarning,
              ),
              const KpiCard(
                title: 'Average ETA',
                value: '32 min',
                icon: Icons.av_timer_rounded,
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Main content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order list wrapped in a card
                Expanded(
                  flex: _selectedOrderId != null ? 7 : 12,
                  child: DashboardCard(
                    title: 'Active Orders Queue',
                    subtitle:
                        'Real-time tracking of platform orders and delivery SLA metrics',
                    fillHeight: true,
                    actions: [
                      // Filter items in the card header actions
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 140,
                            height: 36,
                            child: DropdownButtonFormField<String>(
                              initialValue: _zoneFilter,
                              isDense: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: 'all',
                                  child: Text(
                                    'All Zones',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                ...[
                                  'koramangala',
                                  'whitefield',
                                  'indiranagar',
                                  'hsr_layout',
                                  'electronic_city',
                                  'jayanagar',
                                ].map(
                                  (z) => DropdownMenuItem(
                                    value: z,
                                    child: Text(
                                      z
                                          .replaceAll('_', ' ')
                                          .split(' ')
                                          .map(
                                            (w) =>
                                                '${w[0].toUpperCase()}${w.substring(1)}',
                                          )
                                          .join(' '),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _zoneFilter = v ?? 'all'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text(
                              'Delayed Only',
                              style: TextStyle(fontSize: 11),
                            ),
                            selected: _delayedOnly,
                            onSelected: (v) => setState(() => _delayedOnly = v),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 180,
                            height: 36,
                            child: TextField(
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Search order ID...',
                                prefixIcon: const Icon(Icons.search, size: 16),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                              ),
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                            ),
                          ),
                        ],
                      ),
                    ],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${filteredOrders.length} orders found'.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: filteredOrders.isEmpty
                              ? const EmptyState(
                                  icon: Icons.inbox_outlined,
                                  title: 'No orders found',
                                  subtitle:
                                      'Try adjusting your filters or search query.',
                                )
                              : LayoutBuilder(
                                  builder: (context, constraints) => SingleChildScrollView(
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: constraints.maxWidth,
                                        ),
                                        child: Theme(
                                          data: theme.copyWith(
                                            dataTableTheme: DataTableThemeData(
                                              headingRowColor:
                                                  WidgetStateProperty.all(
                                                theme
                                                    .colorScheme
                                                    .surfaceContainerLow,
                                              ),
                                              headingTextStyle: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.6,
                                              ),
                                              dataTextStyle: const TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ),
                                          child: DataTable(
                                            headingRowHeight: 56,
                                            dataRowMinHeight: 56,
                                            dataRowMaxHeight: 64,
                                            columnSpacing: 24,
                                            showCheckboxColumn: false,
                                            columns: const [
                                              DataColumn(
                                                label: Text('ORDER ID'),
                                              ),
                                              DataColumn(label: Text('STATUS')),
                                              DataColumn(
                                                label: Text('VALUE'),
                                                numeric: true,
                                              ),
                                              DataColumn(label: Text('ZONE')),
                                              DataColumn(label: Text('PLACED')),
                                              DataColumn(label: Text('SLA')),
                                            ],
                                            rows: filteredOrders.map((order) {
                                              final isSelected =
                                                  order.id == _selectedOrderId;
                                              return DataRow(
                                                selected: isSelected,
                                                color: WidgetStatePropertyAll(
                                                  order.isSlaBreached
                                                      ? kDanger.withValues(
                                                          alpha: 0.05,
                                                        )
                                                      : isSelected
                                                      ? theme
                                                            .colorScheme
                                                            .primaryContainer
                                                            .withValues(
                                                              alpha: 0.2,
                                                            )
                                                      : null,
                                                ),
                                                onSelectChanged: (_) =>
                                                    setState(
                                                      () => _selectedOrderId =
                                                          order.id,
                                                    ),
                                                cells: [
                                                  DataCell(
                                                    Text(
                                                      order.id,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    StatusChip(
                                                      label: order.statusLabel,
                                                      color: _statusColor(
                                                        order.status,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      Formatters.currency(
                                                        order.totalValue,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      order.zoneId
                                                          .replaceAll('_', ' ')
                                                          .split(' ')
                                                          .map(
                                                            (w) =>
                                                                '${w[0].toUpperCase()}${w.substring(1)}',
                                                          )
                                                          .join(' '),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    Text(
                                                      Formatters.relativeTime(
                                                        order.placedAt,
                                                      ),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SlaBadge(order: order),
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
                        ),
                      ],
                    ),
                  ),
                ),
                // Detail panel wrapped in a DashboardCard
                if (selectedOrder != null) ...[
                  const SizedBox(width: 24),
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
      case OrderStatus.delivered:
        return kSuccess;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return kDanger;
      case OrderStatus.onTheWay:
      case OrderStatus.pickedUp:
        return kInfo;
      case OrderStatus.preparing:
        return kWarning;
      default:
        return kNeutral;
    }
  }
}

class _OrderDetailPanel extends ConsumerWidget {
  final Order order;
  final List<dynamic> riders;
  final VoidCallback onClose;
  const _OrderDetailPanel({
    required this.order,
    required this.riders,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final isOpsAdmin =
        auth?.role == 'Super Admin' || auth?.role == 'Operations Admin';

    return DashboardCard(
      title: order.id,
      subtitle: 'Placed ${Formatters.relativeTime(order.placedAt)}',
      fillHeight: true,
      actions: [
        StatusChip(label: order.statusLabel, color: _statusColor(order.status)),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.close, size: 20), onPressed: onClose),
      ],
      child: ListView(
        shrinkWrap: true,
        children: [
          // Order info
          _DetailRow('Total Value', Formatters.currency(order.totalValue)),
          _DetailRow('Payment', order.paymentChannel.toUpperCase()),
          _DetailRow(
            'Zone',
            order.zoneId
                .replaceAll('_', ' ')
                .split(' ')
                .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
                .join(' '),
          ),
          _DetailRow('Placed', Formatters.dateTime(order.placedAt)),
          if (order.promisedDeliveryAt != null)
            _DetailRow(
              'Promised Delivery',
              Formatters.dateTime(order.promisedDeliveryAt!),
            ),
          if (order.actualDeliveryAt != null)
            _DetailRow(
              'Actual Delivery',
              Formatters.dateTime(order.actualDeliveryAt!),
            ),

          const SizedBox(height: 20),
          const SectionHeader(title: 'Order Timeline'),
          const SizedBox(height: 8),
          _OrderTimeline(order: order),

          const SizedBox(height: 20),
          const SectionHeader(title: 'Items'),
          const SizedBox(height: 8),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      '${item.name} × ${item.quantity}',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Formatters.currency(item.price),
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

          if (order.riderId != null) ...[
            const SizedBox(height: 20),
            _DetailRow('Rider ID', order.riderId!),
          ],

          // Intervention buttons
          if (isOpsAdmin &&
              order.status != OrderStatus.delivered &&
              order.status != OrderStatus.cancelled &&
              order.status != OrderStatus.failed) ...[
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
                  onPressed: () => showInterventionDialog(
                    context,
                    ref,
                    order,
                    InterventionType.reassign,
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Extend ETA'),
                  onPressed: () => showInterventionDialog(
                    context,
                    ref,
                    order,
                    InterventionType.extendEta,
                  ),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.cancel_outlined, size: 16, color: kDanger),
                  label: Text('Force Cancel', style: TextStyle(color: kDanger)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: kDanger),
                  ),
                  onPressed: () => showInterventionDialog(
                    context,
                    ref,
                    order,
                    InterventionType.forceCancel,
                  ),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.currency_rupee, size: 16),
                  label: const Text('Compensate'),
                  onPressed: () => showInterventionDialog(
                    context,
                    ref,
                    order,
                    InterventionType.compensate,
                  ),
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
      case OrderStatus.delivered:
        return kSuccess;
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        return kDanger;
      case OrderStatus.onTheWay:
      case OrderStatus.pickedUp:
        return kInfo;
      case OrderStatus.preparing:
        return kWarning;
      default:
        return kNeutral;
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
    final showStatuses =
        order.status == OrderStatus.cancelled ||
            order.status == OrderStatus.failed
        ? [OrderStatus.placed, order.status]
        : statuses
              .where(
                (s) =>
                    s.index <= currentIdx &&
                    s != OrderStatus.cancelled &&
                    s != OrderStatus.failed,
              )
              .toList();

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
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: isCurrent
                        ? Border.all(color: color, width: 2)
                        : null,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 24,
                    color: kSuccess.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              _label(e.value),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
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
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.restaurantAccepted:
        return 'Restaurant Accepted';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.riderAssigned:
        return 'Rider Assigned';
      case OrderStatus.riderAtRestaurant:
        return 'Rider at Restaurant';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.onTheWay:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.failed:
        return 'Failed';
    }
  }
}
