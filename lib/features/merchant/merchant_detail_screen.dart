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
      length: 5,
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
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OverviewTab(restaurant: restaurant),
                const Center(child: Text('Menu Governance under construction')),
                const Center(child: Text('Settlement under construction')),
                const Center(child: Text('Compliance under construction')),
                const Center(child: Text('Analytics under construction')),
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
