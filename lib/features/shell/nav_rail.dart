import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class NavRail extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  final bool isCollapsed;

  const NavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.isCollapsed = false,
  });

  static const _destinations = [
    _NavDest(
      'Dashboard',
      Icons.dashboard_outlined,
      Icons.dashboard,
      '/dashboard',
      null,
    ),
    _NavDest(
      'Live Operations',
      Icons.monitor_heart_outlined,
      Icons.monitor_heart,
      '/live-ops',
      ['Super Admin', 'Operations Admin', 'Dispatch Admin'],
    ),
    _NavDest(
      'Delivery Allocation',
      Icons.local_shipping_outlined,
      Icons.local_shipping,
      '/dispatch',
      ['Super Admin', 'Operations Admin', 'Dispatch Admin'],
    ),
    _NavDest('Merchants', Icons.store_outlined, Icons.store, '/merchants', [
      'Super Admin',
      'Operations Admin',
      'Merchant Success Admin',
    ]),
    _NavDest(
      'Riders',
      Icons.delivery_dining_outlined,
      Icons.delivery_dining,
      '/riders',
      ['Super Admin', 'Operations Admin', 'Dispatch Admin'],
    ),
    _NavDest('Finance', Icons.payments_outlined, Icons.payments, '/finance', [
      'Super Admin',
      'Finance Admin',
    ]),
    // _NavDest('Trust & Safety', Icons.security_outlined, Icons.security, '/trust', ['Super Admin', 'Trust & Safety Admin']),
    _NavDest('Customers', Icons.people_outlined, Icons.people, '/customers', [
      'Super Admin',
      'Support Admin',
      'Analyst',
    ]),
    _NavDest('Geo Operations', Icons.map_outlined, Icons.map, '/geo-ops', [
      'Super Admin',
      'Operations Admin',
      'Dispatch Admin',
    ]),
    _NavDest(
      'Support',
      Icons.support_agent_outlined,
      Icons.support_agent,
      '/support',
      ['Super Admin', 'Support Admin'],
    ),
    _NavDest(
      'Identity',
      Icons.manage_accounts_outlined,
      Icons.manage_accounts,
      '/identity',
      ['Super Admin'],
    ),
    _NavDest('Ratings', Icons.star_outline, Icons.star, '/ratings', [
      'Super Admin',
      'Merchant Success Admin',
      'Analyst',
    ]),
    _NavDest(
      'Promotions',
      Icons.campaign_outlined,
      Icons.campaign,
      '/promotions',
      ['Super Admin', 'Merchant Success Admin'],
    ),
    // _NavDest(
    //   'Reporting',
    //   Icons.bar_chart_outlined,
    //   Icons.bar_chart,
    //   '/reporting',
    //   null,
    // ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider);
    final role = user?.role ?? '';

    final visibleDests = <_NavDest>[];
    for (final dest in _destinations) {
      if (dest.allowedRoles == null ||
          role == 'Super Admin' ||
          (dest.allowedRoles?.contains(role) ?? false)) {
        visibleDests.add(dest);
      }
    }

    return Container(
      width: isCollapsed ? 72 : 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo header
          Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 24),
            alignment: Alignment.centerLeft,
            child: isCollapsed
                ? Center(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.bolt,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bolt,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          children: [
                            const TextSpan(text: 'ADMIN'),
                            TextSpan(
                              text: ' Dashboard',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w300,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          // User info header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isCollapsed ? 8 : 16,
              vertical: 12,
            ),
            child: isCollapsed
                ? Center(
                    child: Tooltip(
                      message: '${user?.name ?? 'Admin'} (${role})',
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        child: Text(
                          user?.name.substring(0, 1) ?? 'A',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: theme.colorScheme.primary,
                          child: Text(
                            user?.name.substring(0, 1) ?? 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name ?? 'Admin',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  child: Material(
                    color: isSelected
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => onDestinationSelected(index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: isCollapsed
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            // Left active stripe indicator
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 3,
                              height: isSelected ? 16 : 0,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            SizedBox(width: isSelected ? 8 : 11),
                            Icon(
                              isSelected ? dest.selectedIcon : dest.icon,
                              size: 18,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                            if (!isCollapsed) const SizedBox(width: 12),
                            if (!isCollapsed)
                              Expanded(
                                child: Text(
                                  dest.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? theme.colorScheme.primary
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: isCollapsed
                ? Column(
                    children: [
                      _buildThemeToggle(context, ref, true),
                      const SizedBox(height: 8),
                      IconButton(
                        icon: Icon(
                          Icons.logout_rounded,
                          size: 18,
                          color: theme.colorScheme.error,
                        ),
                        onPressed: () {
                          ref.read(authProvider.notifier).logout();
                          context.go('/login');
                        },
                        tooltip: 'Sign Out',
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withOpacity(
                          0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildThemeToggle(context, ref, false)),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          onPressed: () {
                            ref.read(authProvider.notifier).logout();
                            context.go('/login');
                          },
                          tooltip: 'Sign Out',
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    WidgetRef ref,
    bool isCollapsed,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isCollapsed) {
      return IconButton(
        icon: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          ref.read(themeModeProvider.notifier).state = isDark
              ? ThemeMode.light
              : ThemeMode.dark;
        },
        tooltip: 'Toggle Theme',
      );
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        ref.read(themeModeProvider.notifier).state = isDark
            ? ThemeMode.light
            : ThemeMode.dark;
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              isDark ? 'Light Mode' : 'Dark Mode',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> getVisibleRoutes(String role) {
    return _destinations
        .where(
          (d) =>
              d.allowedRoles == null ||
              role == 'Super Admin' ||
              (d.allowedRoles?.contains(role) ?? false),
        )
        .map((d) => d.route)
        .toList();
  }

  static List<String> getVisibleRoutesForRole(String role) {
    return _destinations
        .where(
          (d) =>
              d.allowedRoles == null ||
              role == 'Super Admin' ||
              (d.allowedRoles?.contains(role) ?? false),
        )
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

  const _NavDest(
    this.label,
    this.icon,
    this.selectedIcon,
    this.route,
    this.allowedRoles,
  );
}
