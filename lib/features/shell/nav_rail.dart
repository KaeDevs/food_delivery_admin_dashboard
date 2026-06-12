import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../core/theme/app_colors.dart';

class NavRail extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const NavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  static const _destinations = [
    _NavDest('Executive', Icons.dashboard_outlined, Icons.dashboard, '/executive', null),
    _NavDest('Live Operations', Icons.monitor_heart_outlined, Icons.monitor_heart, '/live-ops', ['Super Admin', 'Operations Admin', 'Dispatch Admin']),
    _NavDest('Dispatch', Icons.local_shipping_outlined, Icons.local_shipping, '/dispatch', ['Super Admin', 'Operations Admin', 'Dispatch Admin']),
    _NavDest('Merchants', Icons.store_outlined, Icons.store, '/merchants', ['Super Admin', 'Operations Admin', 'Merchant Success Admin']),
    _NavDest('Riders', Icons.delivery_dining_outlined, Icons.delivery_dining, '/riders', ['Super Admin', 'Operations Admin', 'Dispatch Admin']),
    _NavDest('Finance', Icons.payments_outlined, Icons.payments, '/finance', ['Super Admin', 'Finance Admin']),
    _NavDest('Trust & Safety', Icons.security_outlined, Icons.security, '/trust', ['Super Admin', 'Trust & Safety Admin']),
    _NavDest('Customers', Icons.people_outlined, Icons.people, '/customers', ['Super Admin', 'Support Admin', 'Analyst']),
    _NavDest('Geo Operations', Icons.map_outlined, Icons.map, '/geo-ops', ['Super Admin', 'Operations Admin', 'Dispatch Admin']),
    _NavDest('Support', Icons.support_agent_outlined, Icons.support_agent, '/support', ['Super Admin', 'Support Admin']),
    _NavDest('Identity', Icons.manage_accounts_outlined, Icons.manage_accounts, '/identity', ['Super Admin']),
    _NavDest('Ratings', Icons.star_outline, Icons.star, '/ratings', ['Super Admin', 'Merchant Success Admin', 'Analyst']),
    _NavDest('Promotions', Icons.campaign_outlined, Icons.campaign, '/promotions', ['Super Admin', 'Merchant Success Admin']),
    _NavDest('Reporting', Icons.bar_chart_outlined, Icons.bar_chart, '/reporting', null),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final role = user?.role ?? '';

    final visibleDests = <_NavDest>[];
    for (final dest in _destinations) {
      if (dest.allowedRoles == null || role == 'Super Admin' || (dest.allowedRoles?.contains(role) ?? false)) {
        visibleDests.add(dest);
      }
    }

    return Container(
      width: 240,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // User info header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: kSeedColor,
                  child: Text(
                    user?.name.substring(0, 1) ?? 'A',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Admin',
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kSeedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: kSeedColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          // Navigation items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: visibleDests.length,
              itemBuilder: (context, index) {
                final dest = visibleDests[index];
                final isSelected = index == selectedIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  child: Material(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onDestinationSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? dest.selectedIcon : dest.icon,
                              size: 20,
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                dest.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          // Bottom actions
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    theme.brightness == Brightness.dark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 20,
                  ),
                  onPressed: () {
                    // Theme toggle handled by parent
                  },
                  tooltip: 'Toggle Theme',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.logout, size: 20),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                    context.go('/login');
                  },
                  tooltip: 'Sign Out',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> getVisibleRoutes(String role) {
    return _destinations
        .where((d) => d.allowedRoles == null || role == 'Super Admin' || (d.allowedRoles?.contains(role) ?? false))
        .map((d) => d.route)
        .toList();
  }

  static List<String> getVisibleRoutesForRole(String role) {
    return _destinations
        .where((d) => d.allowedRoles == null || role == 'Super Admin' || (d.allowedRoles?.contains(role) ?? false))
        .map((d) => d.route)
        .toList();
  }
}

class _NavDest {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final List<String>? allowedRoles;

  const _NavDest(this.label, this.icon, this.selectedIcon, this.route, this.allowedRoles);
}
