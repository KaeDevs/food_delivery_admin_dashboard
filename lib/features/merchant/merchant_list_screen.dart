import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/restaurant_provider.dart';
import '../../data/models/restaurant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/status_chip.dart';

class MerchantListScreen extends ConsumerStatefulWidget {
  const MerchantListScreen({super.key});

  @override
  ConsumerState<MerchantListScreen> createState() => _MerchantListScreenState();
}

class _MerchantListScreenState extends ConsumerState<MerchantListScreen> {
  String _statusFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allRestaurants = ref.watch(restaurantProvider);
    final belowRating = ref.watch(restaurantsBelowRatingProvider);

    var filtered = allRestaurants;
    if (_statusFilter != 'all') {
      filtered = filtered.where((r) => r.status.name == _statusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) => r.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (belowRating.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kWarning.withOpacity(0.1),
                border: Border.all(color: kWarning.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: kWarning),
                  const SizedBox(width: 12),
                  Text(
                    '${belowRating.length} restaurants below rating threshold (3.5)',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: kWarning),
                  ),
                ],
              ),
            ),
          
          Row(
            children: [
              Text('Merchant Management', style: theme.textTheme.headlineSmall),
              const Spacer(),
              SizedBox(
                width: 240,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search restaurants...',
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
                  ...RestaurantStatus.values.map((s) => DropdownMenuItem(
                    value: s.name, child: Text(s.name.toUpperCase()),
                  )),
                ],
                onChanged: (v) => setState(() => _statusFilter = v ?? 'all'),
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
                    DataColumn(label: Text('Cuisine')),
                    DataColumn(label: Text('Zone')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Rating')),
                    DataColumn(label: Text('FSSAI')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: filtered.map((r) {
                    final isLowRating = r.rating > 0 && r.rating < 3.5;
                    return DataRow(
                      color: WidgetStatePropertyAll(isLowRating ? kWarning.withOpacity(0.05) : null),
                      cells: [
                        DataCell(Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        DataCell(Text(r.cuisine)),
                        DataCell(Text(r.zoneId)),
                        DataCell(StatusChip(
                          label: r.status.name.toUpperCase(),
                          color: r.status == RestaurantStatus.active ? kSuccess : kNeutral,
                        )),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, size: 16, color: isLowRating ? kWarning : kSuccess),
                              const SizedBox(width: 4),
                              Text(r.rating.toStringAsFixed(1), style: TextStyle(color: isLowRating ? kWarning : null, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        DataCell(Text(r.fssaiStatus.name.toUpperCase())),
                        DataCell(
                          OutlinedButton(
                            onPressed: () => context.push('/merchants/${r.id}'),
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
}
