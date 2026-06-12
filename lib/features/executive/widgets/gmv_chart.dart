import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/kpi_snapshot.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class GmvChart extends StatelessWidget {
  final List<KpiSnapshot> snapshots;

  const GmvChart({super.key, required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (snapshots.isEmpty) return const Center(child: Text('No data'));

    return LineChart(
      LineChartData(
        lineBarsData: [
          // GMV line
          LineChartBarData(
            spots: snapshots.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.gmv / 1000)).toList(),
            isCurved: true,
            color: kChartPalette[0],
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: kChartPalette[0].withOpacity(0.08),
            ),
          ),
          // Order volume line
          LineChartBarData(
            spots: snapshots.asMap().entries.map((e) =>
                FlSpot(e.key.toDouble(), e.value.orderVolume.toDouble())).toList(),
            isCurved: true,
            color: kChartPalette[1],
            barWidth: 2,
            dotData: const FlDotData(show: false),
            dashArray: [5, 3],
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= snapshots.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    Formatters.dateShort(snapshots[idx].date),
                    style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text('GMV (₹K)', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant)),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text('₹${value.toInt()}K', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant));
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
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final isGmv = spot.barIndex == 0;
                return LineTooltipItem(
                  isGmv ? '₹${spot.y.toStringAsFixed(0)}K' : '${spot.y.toInt()} orders',
                  TextStyle(
                    color: isGmv ? kChartPalette[0] : kChartPalette[1],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}
