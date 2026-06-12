import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/rider_provider.dart';
import '../../data/models/delivery_partner.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/status_chip.dart';

class RiderDetailScreen extends ConsumerWidget {
  final String id;
  const RiderDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final riders = ref.watch(riderProvider);
    final rider = riders.where((r) => r.id == id).firstOrNull;

    if (rider == null) return const Center(child: Text('Rider not found'));

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
                IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                const SizedBox(width: 16),
                CircleAvatar(radius: 24, child: Text(rider.name[0], style: const TextStyle(fontSize: 20))),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(rider.name, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(width: 12),
                        StatusChip(label: rider.status.name.toUpperCase(), color: _statusColor(rider.status)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${rider.phone} • ${rider.zoneId}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const TabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Performance'),
              Tab(text: 'Earnings'),
              Tab(text: 'Discipline'),
              Tab(text: 'Documents'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ProfileTab(rider: rider),
                const Center(child: Text('Performance Analytics under construction')),
                const Center(child: Text('Earnings under construction')),
                _DisciplineTab(rider: rider),
                const Center(child: Text('Documents under construction')),
              ],
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

class _ProfileTab extends StatelessWidget {
  final DeliveryPartner rider;
  const _ProfileTab({required this.rider});

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
              _StatCard('Rating', rider.rating.toStringAsFixed(1), Icons.star, kSuccess),
              _StatCard('Deliveries This Month', '${rider.deliveriesThisMonth}', Icons.pedal_bike, kNeutral),
              _StatCard('Acceptance Rate', Formatters.percent(rider.acceptanceRate), Icons.check_circle_outline, kSuccess),
              _StatCard('Completion Rate', Formatters.percent(rider.completionRate), Icons.done_all, kSuccess),
            ],
          ),
        ],
      ),
    );
  }
}

class _DisciplineTab extends StatelessWidget {
  final DeliveryPartner rider;
  const _DisciplineTab({required this.rider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rider.warningCount >= 2 ? kDanger.withOpacity(0.1) : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: rider.warningCount >= 2 ? kDanger : theme.colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: rider.warningCount >= 2 ? kDanger : kWarning, size: 32),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${rider.warningCount} / 2 warnings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text('Rolling 30-day window', style: theme.textTheme.bodySmall),
                  ],
                ),
                const Spacer(),
                if (rider.warningCount >= 2)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: kDanger),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Suspension review initiated')));
                    },
                    icon: const Icon(Icons.gavel),
                    label: const Text('Initiate Suspension Review'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('Discipline History', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          if (rider.disciplineHistory.isEmpty)
            const Text('No recent discipline events.')
          else
            ...rider.disciplineHistory.map((e) => ListTile(
              title: Text(e.offenceType),
              subtitle: Text('${Formatters.dateShort(e.date)} • ${e.adminNote}'),
              trailing: StatusChip(label: e.outcome.name, color: e.outcome == DisciplineOutcome.cleared ? kSuccess : kWarning),
            )),
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
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}
