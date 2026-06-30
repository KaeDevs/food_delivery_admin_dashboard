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

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Theme(
              data: theme.copyWith(
                dataTableTheme: DataTableThemeData(
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerLow,
                  ),
                  headingTextStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                  dataTextStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              child: DataTable(
                headingRowHeight: 56,
                dataRowMinHeight: 56,
                dataRowMaxHeight: 64,
                horizontalMargin: 20,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(label: Text('ZONE')),
                  DataColumn(label: Text('ACTIVE ORDERS'), numeric: true),
                  DataColumn(label: Text('AVAILABLE RIDERS'), numeric: true),
                  DataColumn(label: Text('D/S RATIO')),
                  DataColumn(label: Text('SLA BREACH RATE')),
                  DataColumn(label: Text('SURGE')),
                ],
                rows: zones.map((zone) {
                  final zoneOrders = orders.where((o) => o.zoneId == zone.id);
                  final breached = zoneOrders
                      .where((o) => o.isSlaBreached)
                      .length;
                  final breachRate = zoneOrders.isNotEmpty
                      ? breached / zoneOrders.length
                      : 0.0;

                  final dsColor = zone.demandSupplyRatio > 1.5
                      ? kDanger
                      : zone.demandSupplyRatio > 1.2
                      ? kWarning
                      : zone.demandSupplyRatio < 0.5
                      ? kInfo
                      : kSuccess;

                  return DataRow(
                    onSelectChanged: (selected) {
                      // Hover highlight trigger
                    },
                    cells: [
                      DataCell(
                        Text(
                          zone.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      DataCell(Text('${zone.activeOrders}')),
                      DataCell(Text('${zone.availableRiders}')),
                      DataCell(
                        StatusChip(
                          label: Formatters.ratio(zone.demandSupplyRatio),
                          color: dsColor,
                        ),
                      ),
                      DataCell(
                        Text(
                          Formatters.percent(breachRate),
                          style: TextStyle(
                            color: breachRate > 0.1 ? kDanger : null,
                            fontWeight: breachRate > 0.1 ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      DataCell(
                        zone.isSurgeActive
                            ? StatusChip(
                                label: 'ACTIVE',
                                color: kWarning,
                                icon: Icons.bolt,
                              )
                            : Text(
                                'OFF',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
