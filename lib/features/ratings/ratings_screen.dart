import 'package:flutter/material.dart';
import '../../shared/layouts/two_pane_layout.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/extensions.dart';
import '../../shared/widgets/detail_drawer.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  List<Map<String, dynamic>> pendingReviews = [
    {
      'id': '10002',
      'reason': 'Profanity',
      'text': '"Food was complete trash, cold and late. F*** this app."',
    },
    {
      'id': '10003',
      'reason': 'Abuse',
      'text': '"Rider was very rude and demanded extra money."',
    },
    {
      'id': '10004',
      'reason': 'Spam',
      'text': '"Click here to win a free iPhone!! http://spam.link"',
    },
    {
      'id': '10005',
      'reason': 'Profanity',
      'text': '"S*** experience. Never using this again."',
    },
    {
      'id': '10006',
      'reason': 'Inappropriate',
      'text': '"Restaurant added a weird note to my order."',
    },
  ];

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
                  Text(
                    'Declining Restaurants',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    tileColor: kWarning.withOpacity(0.05),
                    leading: const Icon(Icons.trending_down, color: kWarning),
                    title: const Text('Spice Garden'),
                    subtitle: const Text('Dropped 0.4 points in last 30 days'),
                    trailing: const Text(
                      '3.2',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: kWarning,
                      ),
                    ),
                    onTap: () {
                      if (!context.isLarge) {
                        showDetailDrawer(
                          context,
                          DetailDrawer(
                            title: 'Spice Garden Reviews',
                            scrollable: false,
                            child: _buildOrderModerationTab(theme),
                          ),
                        );
                      }
                    },
                  ),
                  if (!context.isLarge) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Open Moderation Queue'),
                        onPressed: () {
                          showDetailDrawer(
                            context,
                            DetailDrawer(
                              title: 'Review Moderation Queue',
                              scrollable: false,
                              child: _buildOrderModerationTab(theme),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
              detailPane: _buildOrderModerationTab(theme),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildOrderModerationTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Review Moderation Queue',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kWarning,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${pendingReviews.length} Pending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: pendingReviews.isEmpty
                ? const Center(child: Text('No pending reviews'))
                : ListView.builder(
                    itemCount: pendingReviews.length,
                    itemBuilder: (context, index) {
                      final review = pendingReviews[index];
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
                                  Text(
                                    'Order #${review['id']}',
                                    style: theme.textTheme.labelSmall,
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.flag, size: 16, color: kDanger),
                                  const SizedBox(width: 4),
                                  Text(
                                    review['reason'] as String,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: kDanger,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                review['text'] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {
                                      setState(() {
                                        pendingReviews.removeAt(index);
                                      });
                                    },
                                    child: const Text('Hide Review'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        pendingReviews.removeAt(index);
                                      });
                                    },
                                    child: const Text('Approve (Ignore)'),
                                  ),
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
    );
  }

}
