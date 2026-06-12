import 'package:flutter/material.dart';
import '../../shared/layouts/two_pane_layout.dart';
import '../../core/theme/app_colors.dart';

class TrustScreen extends StatelessWidget {
  const TrustScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Trust & Safety Workbench', style: theme.textTheme.headlineSmall),
              const Spacer(),
              FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Create Manual Case'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TwoPaneLayout(
              splitRatio: 0.3,
              listPane: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Case Categories', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _CategoryItem('All Cases', 5, true),
                  _CategoryItem('GPS Spoofing', 2, false),
                  _CategoryItem('Promo Fraud', 2, false),
                  _CategoryItem('Refund Abuse', 1, false),
                  _CategoryItem('Merchant Malpractice', 0, false),
                ],
              ),
              detailPane: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Open Cases', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                          child: ListTile(
                            leading: const CircleAvatar(backgroundColor: kDanger, child: Icon(Icons.security, color: Colors.white)),
                            title: Row(
                              children: [
                                const Text('GPS Spoofing Detected', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: kDanger.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('Critical', style: TextStyle(color: kDanger, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            subtitle: const Text('Delivery Partner #R1004 showed unrealistic travel speeds.'),
                            trailing: OutlinedButton(
                              onPressed: () {},
                              child: const Text('Review Evidence'),
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

  Widget _CategoryItem(String title, int count, bool selected) {
    return Container(
      color: selected ? kSeedColor.withOpacity(0.1) : null,
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.normal, color: selected ? kSeedColor : null)),
        trailing: count > 0 
            ? CircleAvatar(radius: 12, backgroundColor: selected ? kSeedColor : kNeutral, child: Text('$count', style: const TextStyle(fontSize: 12, color: Colors.white)))
            : null,
      ),
    );
  }
}
