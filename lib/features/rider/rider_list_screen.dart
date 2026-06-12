import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/rider_provider.dart';
import '../../data/models/delivery_partner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/status_chip.dart';

class RiderListScreen extends ConsumerStatefulWidget {
  const RiderListScreen({super.key});

  @override
  ConsumerState<RiderListScreen> createState() => _RiderListScreenState();
}

class _RiderListScreenState extends ConsumerState<RiderListScreen> {
  String _statusFilter = 'all';
  String _searchQuery = '';
  bool _hasWarnings = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allRiders = ref.watch(riderProvider);

    var filtered = allRiders;
    if (_statusFilter != 'all') {
      filtered = filtered.where((r) => r.status.name == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    if (_hasWarnings) {
      filtered = filtered.where((r) => r.warningCount > 0).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Rider Management', style: theme.textTheme.headlineSmall),
              const Spacer(),
              SizedBox(
                width: 240,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search riders...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String>(
                value: _statusFilter,
                underline: const SizedBox(),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All Statuses')),
                  ...RiderStatus.values.map((s) => DropdownMenuItem(
                    value: s.name, child: Text(s.name.toUpperCase()),
                  )),
                ],
                onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
              ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Has Warnings'),
                selected: _hasWarnings,
                onSelected: (v) => setState(() => _hasWarnings = v),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowHeight: 48,
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Zone')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Acceptance')),
                    DataColumn(label: Text('Completion')),
                    DataColumn(label: Text('Warnings')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filtered.map((r) {
                    return DataRow(
                      color: WidgetStatePropertyAll(r.isSuspended ? kDanger.withOpacity(0.05) : null),
                      cells: [
                        DataCell(Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(r.zoneId)),
                        DataCell(StatusChip(
                          label: r.status.name.toUpperCase(),
                          color: _statusColor(r.status),
                        )),
                        DataCell(Text(Formatters.percent(r.acceptanceRate))),
                        DataCell(Text(Formatters.percent(r.completionRate))),
                        DataCell(
                          Row(
                            children: [
                              Text('${r.warningCount}'),
                              if (r.warningCount >= 2) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.warning, color: kDanger, size: 16),
                              ],
                            ],
                          ),
                        ),
                        DataCell(
                          OutlinedButton(
                            onPressed: () => context.push('/riders/${r.id}'),
                            child: const Text('View'),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(RiderStatus status) {
    switch (status) {
      case RiderStatus.available: return kSuccess;
      case RiderStatus.delivering: return kInfo;
      case RiderStatus.offline: return kNeutral;
      case RiderStatus.suspended: return kDanger;
      default: return kNeutral;
    }
  }
}
