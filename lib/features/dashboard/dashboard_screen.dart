import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/order.dart';
import '../../data/models/delivery_partner.dart';
import '../../data/models/alert_rule.dart';
import '../../providers/order_provider.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/rider_provider.dart';
import '../../providers/alert_provider.dart';
import '../../providers/dispatch_provider.dart';
import '../../data/mock/mock_kpi_snapshots.dart';
import '../../core/utils/formatters.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../shared/widgets/loading_shimmer.dart';
import 'widgets/kpi_card.dart';
import 'widgets/gmv_chart.dart';
import 'widgets/order_funnel_chart.dart';
import 'widgets/city_drill_down.dart';
import 'widgets/live_fleet_status_card.dart';
import 'widgets/dashboard_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allOrders = ref.watch(orderProvider);
    final todayOrders = ref.watch(todayOrdersProvider);
    final todayDelivered = ref.watch(todayDeliveredProvider);
    final activeRestaurants = ref.watch(activeRestaurantsProvider);
    final riders = ref.watch(riderProvider);
    final firedAlerts = ref.watch(firedAlertsProvider);
    final dispatch = ref.watch(dispatchProvider);
    final snapshots = MockKpiSnapshots.snapshots;

    // Calculate KPIs
    final grossOrderVolume = todayOrders.length;
    final netCompleted = todayDelivered.length;
    final gmvToday = todayDelivered.fold<double>(
      0,
      (sum, o) => sum + o.totalValue,
    );
    final aov = netCompleted > 0 ? gmvToday / netCompleted : 0.0;
    final monthlyUsers = allOrders.map((o) => o.customerId).toSet().length;
    final activeRests = activeRestaurants.length;
    final activeRiders = riders
        .where(
          (r) =>
              r.status != RiderStatus.offline &&
              r.status != RiderStatus.suspended,
        )
        .length;
    final deliveredOrders = allOrders.where(
      (o) => o.status == OrderStatus.delivered,
    );
    final onTimeCount = deliveredOrders.where((o) => !o.isSlaBreached).length;
    final onTimeRate = deliveredOrders.isNotEmpty
        ? onTimeCount / deliveredOrders.length
        : 0.0;

    // Yesterday comparison (from snapshots)
    final yesterdaySnap = snapshots.length > 1
        ? snapshots[snapshots.length - 2]
        : null;
    final todaySnap = snapshots.isNotEmpty ? snapshots.last : null;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: KPI Row
                  _isLoading
                      ? Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: List.generate(
                            8,
                            (index) => const SizedBox(
                              width: 200,
                              child: ShimmerCard(),
                            ),
                          ),
                        )
                      : Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            KpiCard(
                              title: 'Gross Order Volume',
                              value: grossOrderVolume.toString(),
                              icon: Icons.shopping_bag_outlined,
                              trendLabel: yesterdaySnap != null
                                  ? '${((grossOrderVolume - yesterdaySnap.orderVolume) / yesterdaySnap.orderVolume * 100).toStringAsFixed(1)}%'
                                  : null,
                              trendColor:
                                  grossOrderVolume >=
                                          (yesterdaySnap?.orderVolume ?? 0)
                                      ? kSuccess
                                      : kDanger,
                              onTap: () => context.go('/live-ops'),
                            ),
                            KpiCard(
                              title: 'Net Completed',
                              value: netCompleted.toString(),
                              icon: Icons.check_circle_outline,
                              trendColor: kSuccess,
                            ),
                            KpiCard(
                              title: 'GMV Today',
                              value: Formatters.currencyCompact(gmvToday),
                              icon: Icons.currency_rupee,
                              trendLabel:
                                  todaySnap != null && yesterdaySnap != null
                                      ? '${((todaySnap.gmv - yesterdaySnap.gmv) / yesterdaySnap.gmv * 100).toStringAsFixed(1)}%'
                                      : null,
                              trendColor: gmvToday >= (yesterdaySnap?.gmv ?? 0)
                                  ? kSuccess
                                  : kDanger,
                            ),
                            KpiCard(
                              title: 'Avg Order Value',
                              value: Formatters.currency(aov),
                              icon: Icons.receipt_outlined,
                            ),
                            KpiCard(
                              title: 'Monthly Users',
                              value: monthlyUsers.toString(),
                              icon: Icons.people_outline,
                            ),
                            KpiCard(
                              title: 'Active Restaurants',
                              value: activeRests.toString(),
                              icon: Icons.store_outlined,
                            ),
                            KpiCard(
                              title: 'Active Riders',
                              value: activeRiders.toString(),
                              icon: Icons.delivery_dining_outlined,
                            ),
                            KpiCard(
                              title: 'On-Time Rate',
                              value: Formatters.percent(onTimeRate),
                              icon: Icons.timer_outlined,
                              trendColor: onTimeRate >= 0.85
                                  ? kSuccess
                                  : kDanger,
                              onTap: () => context.go('/live-ops'),
                            ),
                          ],
                        ),
                  const SizedBox(height: 32),

                  // Section 2 & 3: Responsive Charts & Live Incident Feed Layout
                  if (context.isCompact) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LiveFleetStatusCard(),
                        const SizedBox(height: 32),
                        DashboardCard(
                          title: 'GMV & Order Volume (30 Days)',
                          subtitle: 'Timeline of platform sales performance',
                          child: SizedBox(
                            height: 280,
                            child: GmvChart(snapshots: snapshots),
                          ),
                        ),
                        const SizedBox(height: 32),
                        DashboardCard(
                          title: 'Order Status Distribution',
                          subtitle: 'Breakup of daily order life-cycle states',
                          child: SizedBox(
                            height: 240,
                            width: double.infinity,
                            child: OrderFunnelChart(orders: allOrders),
                          ),
                        ),
                        const SizedBox(height: 32),
                        DashboardCard(
                          title: 'Live Incident Feed',
                          subtitle: 'Real-time SLA breaches and service violations',
                          child: _buildIncidentFeed(firedAlerts, context),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GMV & Status Charts
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardCard(
                                title: 'GMV & Order Volume (30 Days)',
                                subtitle: 'Timeline of platform sales performance',
                                child: SizedBox(
                                  height: 280,
                                  child: GmvChart(snapshots: snapshots),
                                ),
                              ),
                              const SizedBox(height: 32),
                              DashboardCard(
                                title: 'Order Status Distribution',
                                subtitle: 'Breakup of daily order life-cycle states',
                                child: SizedBox(
                                  height: 240,
                                  width: double.infinity,
                                  child: OrderFunnelChart(orders: allOrders),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Live Fleet Status & Incident Feed
                        SizedBox(
                          width: 320,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const LiveFleetStatusCard(),
                              const SizedBox(height: 32),
                              DashboardCard(
                                title: 'Live Incident Feed',
                                subtitle: 'Active system alerts and exceptions',
                                child: _buildIncidentFeed(firedAlerts, context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 32),

                  // Section 5: City Drill-Down
                  DashboardCard(
                    title: 'City Zone Performance',
                    subtitle: 'Operational efficiency and supply metrics by delivery zone',
                    child: CityDrillDown(zones: dispatch.zones, orders: allOrders),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentFeed(List<AlertRule> firedAlerts, BuildContext context) {
    final theme = Theme.of(context);
    if (firedAlerts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              color: kSuccess,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              'All Clear',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'No active incidents',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: firedAlerts.map((alert) {
        final color = alert.severity == AlertSeverity.critical
            ? kDanger
            : alert.severity == AlertSeverity.warning
                ? kWarning
                : kInfo;
        return InkWell(
          onTap: () {
            String route = '/dashboard';
            final roleLow = alert.ownerRole.toLowerCase();
            if (roleLow.contains('dispatch'))
              route = '/dispatch';
            else if (roleLow.contains('merchant'))
              route = '/merchants';
            else if (roleLow.contains('finance'))
              route = '/finance';
            else if (roleLow.contains('ops') ||
                roleLow.contains('operations'))
              route = '/live-ops';
            context.go(route);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  alert.severity == AlertSeverity.critical
                      ? Icons.error
                      : Icons.warning_amber,
                  color: color,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alert.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.firedAt != null
                            ? Formatters.relativeTime(alert.firedAt!)
                            : '',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
