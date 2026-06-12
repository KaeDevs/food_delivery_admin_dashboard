import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/order.dart';
import '../../../core/theme/app_colors.dart';

class OrderFunnelChart extends StatelessWidget {
  final List<Order> orders;

  const OrderFunnelChart({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusCounts = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      statusCounts[status] = orders.where((o) => o.status == status).length;
    }

    final displayStatuses = OrderStatus.values.where((s) => statusCounts[s]! > 0).toList();

    return BarChart(
      BarChartData(
        barGroups: displayStatuses.asMap().entries.map((e) {
          final color = _statusColor(e.value);
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: statusCounts[e.value]!.toDouble(),
                color: color,
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= displayStatuses.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      _statusLabel(displayStatuses[idx]),
                      style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant));
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            strokeWidth: 0.5,
          ),
        ),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${_statusLabel(displayStatuses[group.x])}\n${rod.toY.toInt()} orders',
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.delivered: return kSuccess;
      case OrderStatus.cancelled: return kDanger;
      case OrderStatus.failed: return kDanger;
      case OrderStatus.onTheWay: return kInfo;
      case OrderStatus.pickedUp: return kChartPalette[4];
      case OrderStatus.preparing: return kWarning;
      case OrderStatus.ready: return kChartPalette[5];
      default: return kNeutral;
    }
  }

  String _statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed: return 'Placed';
      case OrderStatus.restaurantAccepted: return 'Accepted';
      case OrderStatus.preparing: return 'Preparing';
      case OrderStatus.ready: return 'Ready';
      case OrderStatus.riderAssigned: return 'Assigned';
      case OrderStatus.riderAtRestaurant: return 'At Rest.';
      case OrderStatus.pickedUp: return 'Picked Up';
      case OrderStatus.onTheWay: return 'On Way';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      case OrderStatus.failed: return 'Failed';
    }
  }
}
