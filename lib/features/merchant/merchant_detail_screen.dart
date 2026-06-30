import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/restaurant_provider.dart';
import '../../data/models/restaurant.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/status_chip.dart';

class MerchantDetailScreen extends ConsumerWidget {
  final String id;
  const MerchantDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restaurants = ref.watch(restaurantProvider);
    final restaurant = restaurants.where((r) => r.id == id).firstOrNull;

    if (restaurant == null)
      return const Center(child: Text('Restaurant not found'));

    return DefaultTabController(
      length: 6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 16),
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    restaurant.name[0],
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(width: 12),
                        StatusChip(
                          label: restaurant.status.name.toUpperCase(),
                          color: restaurant.status == RestaurantStatus.active
                              ? kSuccess
                              : kNeutral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${restaurant.cuisine} • ${restaurant.zoneId}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Online Status'),
                    const SizedBox(width: 8),
                    Switch(
                      value: restaurant.isOnline,
                      onChanged: (v) => ref
                          .read(restaurantProvider.notifier)
                          .toggleOnline(id),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Menu & Catalogue'),
              Tab(text: 'Settlement'),
              Tab(text: 'Compliance'),
              Tab(text: 'Analytics'),
              Tab(text: 'Media & Gallery'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OverviewTab(restaurant: restaurant),
                _MenuTab(restaurant: restaurant),
                _SettlementTab(restaurant: restaurant),
                _ComplianceTab(restaurant: restaurant),
                _AnalyticsTab(restaurant: restaurant),
                _GalleryTab(restaurant: restaurant),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Restaurant restaurant;
  const _OverviewTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                'Rating',
                restaurant.rating.toStringAsFixed(1),
                Icons.star,
                restaurant.rating < 3.5 ? kWarning : kSuccess,
              ),
              _StatCard(
                'Orders This Month',
                '${restaurant.totalOrdersThisMonth}',
                Icons.shopping_bag,
                kNeutral,
              ),
              _StatCard(
                'Rejection Rate',
                Formatters.percent(restaurant.rejectionRate),
                Icons.cancel,
                restaurant.rejectionRate > 0.1 ? kDanger : kSuccess,
              ),
              _StatCard(
                'Avg Prep Time',
                '${restaurant.avgPrepTimeMinutes} min',
                Icons.timer,
                kNeutral,
              ),
              _StatCard(
                'Pending Settlement',
                Formatters.currency(restaurant.weeklySettlementPending),
                Icons.account_balance_wallet,
                kNeutral,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTab extends StatefulWidget {
  final Restaurant restaurant;
  const _MenuTab({required this.restaurant});

  @override
  State<_MenuTab> createState() => _MenuTabState();
}

class _MenuTabState extends State<_MenuTab> {
  final List<Map<String, dynamic>> _mockItems = [
    {
      'name': 'Margherita Pizza',
      'category': 'Mains',
      'price': 250.0,
      'inStock': true,
    },
    {
      'name': 'Garlic Bread',
      'category': 'Starters',
      'price': 120.0,
      'inStock': true,
    },
    {
      'name': 'Paneer Tikka',
      'category': 'Starters',
      'price': 180.0,
      'inStock': false,
    },
    {
      'name': 'Cold Coffee',
      'category': 'Beverages',
      'price': 90.0,
      'inStock': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Menu Items',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // const Spacer(),
              // FilledButton.icon(
              //   onPressed: () {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       const SnackBar(content: Text('Add item dialog')),
              //     );
              //   },
              //   icon: const Icon(Icons.add, size: 18),
              //   label: const Text('Add Item'),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Item Name')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Price')),
                DataColumn(label: Text('In Stock')),
                // DataColumn(label: Text('Actions')),
              ],
              rows: _mockItems.map((item) {
                return DataRow(
                  cells: [
                    DataCell(Text(item['name'])),
                    DataCell(Text(item['category'])),
                    DataCell(Text(Formatters.currency(item['price']))),
                    DataCell(
                      Center(
                        child: item['inStock']
                            ? Icon(Icons.check, color: Colors.green)
                            : Icon(Icons.cancel, color: Colors.red),
                      ),

                      // DataCell(:
                      //   IconButton(
                      //     icon: const Icon(Icons.edit, size: 18),
                      // onPressed: () {},
                    ),
                    // ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementTab extends StatelessWidget {
  final Restaurant restaurant;
  const _SettlementTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Weekly Settlement',
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Formatters.currency(restaurant.weeklySettlementPending),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: kWarning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Manual payout initiated')),
                    );
                  },
                  child: const Text('Trigger Payout'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Recent Payouts', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Reference')),
              ],
              rows: [
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        Formatters.date(
                          DateTime.now().subtract(const Duration(days: 7)),
                        ),
                      ),
                    ),
                    DataCell(Text(Formatters.currency(14500.0))),
                    DataCell(StatusChip(label: 'Settled', color: kSuccess)),
                    DataCell(const Text('TXN-884920')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        Formatters.date(
                          DateTime.now().subtract(const Duration(days: 14)),
                        ),
                      ),
                    ),
                    DataCell(Text(Formatters.currency(16200.0))),
                    DataCell(StatusChip(label: 'Settled', color: kSuccess)),
                    DataCell(const Text('TXN-723145')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceTab extends StatelessWidget {
  final Restaurant restaurant;
  const _ComplianceTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ComplianceCard(
            title: 'FSSAI License',
            status: restaurant.fssaiStatus,
            expiry: restaurant.fssaiExpiry,
          ),
          const SizedBox(height: 16),
          _ComplianceCard(
            title: 'GST Registration',
            status: restaurant.gstStatus,
            expiry: null,
          ),
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  final String title;
  final DocumentStatus status;
  final DateTime? expiry;

  const _ComplianceCard({
    required this.title,
    required this.status,
    this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor = kNeutral;
    if (status == DocumentStatus.approved) statusColor = kSuccess;
    if (status == DocumentStatus.rejected || status == DocumentStatus.expired)
      statusColor = kDanger;
    if (status == DocumentStatus.pending ||
        status == DocumentStatus.underReview)
      statusColor = kWarning;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.description, size: 32, color: theme.colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                if (expiry != null)
                  Text(
                    'Expires: ${Formatters.date(expiry!)}',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          StatusChip(label: status.name.toUpperCase(), color: statusColor),
          const SizedBox(width: 24),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Requested $title update')),
              );
            },
            child: const Text('Request Update'),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  final Restaurant restaurant;
  const _AnalyticsTab({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Performance Metrics', style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _MetricBar(title: 'Customer Retention', percentage: 0.68),
              _MetricBar(title: 'On-time Preparation', percentage: 0.85),
              _MetricBar(
                title: 'Order Fulfillment',
                percentage: (1.0 - restaurant.rejectionRate).clamp(0.0, 1.0),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text('Popular Times', style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ChartBar(label: 'Morning', height: 40),
              const SizedBox(width: 16),
              _ChartBar(label: 'Lunch', height: 120),
              const SizedBox(width: 16),
              _ChartBar(label: 'Evening', height: 80),
              const SizedBox(width: 16),
              _ChartBar(label: 'Dinner', height: 140),
              const SizedBox(width: 16),
              _ChartBar(label: 'Late Night', height: 30),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  final String title;
  final double percentage;
  const _MetricBar({required this.title, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                Formatters.percent(percentage),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Theme.of(context).colorScheme.outlineVariant,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String label;
  final double height;
  const _ChartBar({required this.label, required this.height});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _GalleryTab extends StatefulWidget {
  final Restaurant restaurant;
  const _GalleryTab({required this.restaurant});

  @override
  State<_GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<_GalleryTab> {
  void _showImageDetails(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: 400,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 400,
                  color: Colors.grey.shade200,
                  child: const Center(child: Icon(Icons.broken_image, size: 64)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showReportDialog(context);
                      },
                      icon: const Icon(Icons.flag, size: 16),
                      label: const Text('Flag Content'),
                      style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Image'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send a warning to the merchant regarding this image.'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Warning Message',
                    hintText: 'e.g. This image violates our guidelines because it is vulgar.',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Warning sent to the merchant successfully.'),
                    backgroundColor: Colors.green.shade600,
                  ),
                );
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.orange.shade600),
              child: const Text('Send Warning'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.restaurant.imageUrls.isEmpty) {
      return const Center(child: Text('No images uploaded.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: widget.restaurant.imageUrls.length,
      itemBuilder: (context, index) {
        final url = widget.restaurant.imageUrls[index];
        return InkWell(
          onTap: () => _showImageDetails(context, url),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
              image: DecorationImage(
                image: NetworkImage(url),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
