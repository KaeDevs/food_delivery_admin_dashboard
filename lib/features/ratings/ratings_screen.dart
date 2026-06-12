import 'package:flutter/material.dart';
import '../../shared/layouts/two_pane_layout.dart';
import '../../core/theme/app_colors.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ratings & Reviews', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: TwoPaneLayout(
              splitRatio: 0.4,
              listPane: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Platform Average', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _AverageBadge('Restaurants', '4.2', Icons.store, context),
                      const SizedBox(width: 16),
                      _AverageBadge('Riders', '4.6', Icons.pedal_bike, context),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Declining Restaurants', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: kWarning.withOpacity(0.05),
                    leading: const Icon(Icons.trending_down, color: kWarning),
                    title: const Text('Spice Garden'),
                    subtitle: const Text('Dropped 0.4 points in last 30 days'),
                    trailing: const Text('3.2', style: TextStyle(fontWeight: FontWeight.w700, color: kWarning)),
                  ),
                ],
              ),
              detailPane: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Review Moderation Queue', style: theme.textTheme.titleMedium),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: kWarning, borderRadius: BorderRadius.circular(12)),
                        child: const Text('5 Pending', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: theme.colorScheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Order #100${index}2', style: theme.textTheme.labelSmall),
                                    const Spacer(),
                                    const Icon(Icons.flag, size: 16, color: kDanger),
                                    const SizedBox(width: 4),
                                    Text('Profanity', style: theme.textTheme.labelSmall?.copyWith(color: kDanger)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('"Food was complete trash, cold and late. F*** this app."', style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    OutlinedButton(onPressed: () {}, child: const Text('Hide Review')),
                                    const SizedBox(width: 8),
                                    TextButton(onPressed: () {}, child: const Text('Approve (Ignore)')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _AverageBadge(String title, String rating, IconData icon, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: kWarning, size: 24),
              const SizedBox(width: 4),
              Text(rating, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}
