import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../shared/widgets/section_header.dart';
import 'widgets/kpi_card.dart';
import 'widgets/gmv_chart.dart';
import 'widgets/order_funnel_chart.dart';
import 'widgets/city_drill_down.dart';

class ExecutiveScreen extends ConsumerWidget {
  const ExecutiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allOrders = ref.watch(orderProvider);
    final todayOrders = ref.watch(todayOrdersProvider);
    final todayDelivered = ref.watch(todayDeliveredProvider);
    final activeRestaurants = ref.watch(activeRestaurantsProvider);
    final riders = ref.watch(riderProvider);
    final firedAlerts = ref.watch(firedAlertsProvider);
    final dispatch = ref.watch(dispatchProvider);
    final snapshots = MockKpiSnapshots.snapshots;

    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    // Calculate KPIs
    final grossOrderVolume = todayOrders.length;
    final netCompleted = todayDelivered.length;
    final gmvToday = todayDelivered.fold<double>(0, (sum, o) => sum + o.totalValue);
    final aov = netCompleted > 0 ? gmvToday / netCompleted : 0.0;
    final monthlyUsers = allOrders.map((o) => o.customerId).toSet().length;
    final activeRests = activeRestaurants.length;
    final activeRiders = riders.where((r) => r.status != RiderStatus.offline && r.status != RiderStatus.suspended).length;
    final deliveredOrders = allOrders.where((o) => o.status == OrderStatus.delivered);
    final onTimeCount = deliveredOrders.where((o) => !o.isSlaBreached).length;
    final onTimeRate = deliveredOrders.isNotEmpty ? onTimeCount / deliveredOrders.length : 0.0;

    // Yesterday comparison (from snapshots)
    final yesterdaySnap = snapshots.length > 1 ? snapshots[snapshots.length - 2] : null;
    final todaySnap = snapshots.isNotEmpty ? snapshots.last : null;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Executive Command Centre', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: KPI Row
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      KpiCard(
                        title: 'Gross Order Volume',
                        value: grossOrderVolume.toString(),
                        icon: Icons.shopping_bag_outlined,
                        trendLabel: yesterdaySnap != null ? '${((grossOrderVolume - yesterdaySnap.orderVolume) / yesterdaySnap.orderVolume * 100).toStringAsFixed(1)}%' : null,
                        trendColor: grossOrderVolume >= (yesterdaySnap?.orderVolume ?? 0) ? kSuccess : kDanger,
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
                        trendLabel: todaySnap != null && yesterdaySnap != null ? '${((todaySnap.gmv - yesterdaySnap.gmv) / yesterdaySnap.gmv * 100).toStringAsFixed(1)}%' : null,
                        trendColor: gmvToday >= (yesterdaySnap?.gmv ?? 0) ? kSuccess : kDanger,
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
                        trendColor: onTimeRate >= 0.85 ? kSuccess : kDanger,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Section 2 & 3: Charts Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GMV Chart
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'GMV & Order Volume (30 Days)'),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 280,
                              child: GmvChart(snapshots: snapshots),
                            ),
                            const SizedBox(height: 32),
                            const SectionHeader(title: 'Order Status Distribution'),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 240,
                              child: OrderFunnelChart(orders: allOrders),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Live Incident Feed
                      SizedBox(
                        width: 320,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(title: 'Live Incident Feed'),
                            const SizedBox(height: 16),
                            if (firedAlerts.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surfaceContainerLowest,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.check_circle, color: kSuccess, size: 40),
                                    const SizedBox(height: 8),
                                    Text('All clear', style: Theme.of(context).textTheme.titleSmall),
                                    Text('No active incidents', style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              )
                            else
                              ...firedAlerts.map((alert) {
                                final color = alert.severity == AlertSeverity.critical ? kDanger
                                    : alert.severity == AlertSeverity.warning ? kWarning : kInfo;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: color.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        alert.severity == AlertSeverity.critical ? Icons.error : Icons.warning_amber,
                                        color: color, size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(alert.name, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                                            const SizedBox(height: 2),
                                            Text(
                                              alert.firedAt != null ? Formatters.relativeTime(alert.firedAt!) : '',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Section 5: City Drill-Down
                  const SectionHeader(title: 'City Zone Performance'),
                  const SizedBox(height: 16),
                  CityDrillDown(zones: dispatch.zones, orders: allOrders),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
