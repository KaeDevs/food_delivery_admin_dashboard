import 'package:flutter/material.dart';
import '../../../data/models/zone.dart';
import '../../../data/models/order.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/status_chip.dart';

class CityDrillDown extends StatelessWidget {
  final List<Zone> zones;
  final List<Order> orders;

  const CityDrillDown({super.key, required this.zones, required this.orders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 48,
            dataRowMinHeight: 52,
            dataRowMaxHeight: 56,
            columnSpacing: 32,
            horizontalMargin: 16,
            columns: const [
              DataColumn(label: Text('Zone')),
              DataColumn(label: Text('Active Orders'), numeric: true),
              DataColumn(label: Text('Available Riders'), numeric: true),
              DataColumn(label: Text('D/S Ratio')),
              DataColumn(label: Text('SLA Breach Rate')),
              DataColumn(label: Text('Surge')),
            ],
            rows: zones.map((zone) {
              final zoneOrders = orders.where((o) => o.zoneId == zone.id);
              final breached = zoneOrders.where((o) => o.isSlaBreached).length;
              final breachRate = zoneOrders.isNotEmpty ? breached / zoneOrders.length : 0.0;

              final dsColor = zone.demandSupplyRatio > 1.5
                  ? kDanger
                  : zone.demandSupplyRatio > 1.2
                      ? kWarning
                      : zone.demandSupplyRatio < 0.5
                          ? kInfo
                          : kSuccess;

              return DataRow(cells: [
                DataCell(Text(zone.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
                DataCell(Text('${zone.activeOrders}')),
                DataCell(Text('${zone.availableRiders}')),
                DataCell(StatusChip(label: Formatters.ratio(zone.demandSupplyRatio), color: dsColor)),
                DataCell(Text(Formatters.percent(breachRate), style: TextStyle(color: breachRate > 0.1 ? kDanger : null))),
                DataCell(zone.isSurgeActive
                    ? StatusChip(label: 'Active', color: kWarning, icon: Icons.bolt)
                    : Text('Off', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant))),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
