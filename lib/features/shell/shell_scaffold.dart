import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/alert_rule.dart';
import '../../providers/auth_provider.dart';
import '../../providers/alert_provider.dart';
import '../../core/theme/app_colors.dart';
import 'nav_rail.dart';

class ShellScaffold extends ConsumerStatefulWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  ConsumerState<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends ConsumerState<ShellScaffold> {
  int _selectedIndex = 0;

  static const _routes = [
    '/executive', '/live-ops', '/dispatch', '/merchants', '/riders',
    '/finance', '/trust', '/customers', '/geo-ops', '/support',
    '/identity', '/ratings', '/promotions', '/reporting',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.path;
    final role = ref.read(authProvider)?.role ?? '';
    final visibleRoutes = NavRail.getVisibleRoutesForRole(role);

    for (int i = 0; i < visibleRoutes.length; i++) {
      if (location.startsWith(visibleRoutes[i])) {
        if (_selectedIndex != i) {
          setState(() => _selectedIndex = i);
        }
        return;
      }
    }
  }

  void _onDestinationSelected(int index) {
    final role = ref.read(authProvider)?.role ?? '';
    final visibleRoutes = NavRail.getVisibleRoutesForRole(role);
    if (index < visibleRoutes.length) {
      setState(() => _selectedIndex = index);
      context.go(visibleRoutes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertCount = ref.watch(firedAlertCountProvider);
    final location = GoRouterState.of(context).uri.path;

    // Derive page title from current route
    String pageTitle = 'Dashboard';
    for (final entry in _routeTitles.entries) {
      if (location.startsWith(entry.key)) {
        pageTitle = entry.value;
        break;
      }
    }

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          NavRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        pageTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      // Alert bell
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, size: 22),
                            onPressed: () {
                              _showAlertPanel(context, ref);
                            },
                          ),
                          if (alertCount > 0)
                            Positioned(
                              right: 4,
                              top: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: kDanger,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$alertCount',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSeedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ref.watch(authProvider)?.role ?? '',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: kSeedColor),
                        ),
                      ),
                    ],
                  ),
                ),
                // Page content
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertPanel(BuildContext context, WidgetRef ref) {
    final alerts = ref.read(firedAlertsProvider);
    final theme = Theme.of(context);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Alerts',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) {
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 56, right: 16),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 360,
                constraints: const BoxConstraints(maxHeight: 480),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Text('Active Alerts', style: theme.textTheme.titleSmall),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              ref.read(alertProvider.notifier).dismissAll();
                              Navigator.of(ctx).pop();
                            },
                            child: const Text('Dismiss All'),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: theme.colorScheme.outlineVariant),
                    if (alerts.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No active alerts'),
                      )
                    else
                      ...alerts.map((alert) {
                        final color = alert.severity == AlertSeverity.critical ? kDanger
                            : alert.severity == AlertSeverity.warning ? kWarning : kInfo;
                        return ListTile(
                          leading: Icon(
                            alert.severity == AlertSeverity.critical ? Icons.error : Icons.warning_amber,
                            color: color,
                            size: 20,
                          ),
                          title: Text(alert.name, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: Text(alert.ownerRole, style: theme.textTheme.labelSmall),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () {
                              ref.read(alertProvider.notifier).dismiss(alert.id);
                            },
                          ),
                          dense: true,
                        );
                      }),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static const _routeTitles = {
    '/executive': 'Executive Command Centre',
    '/live-ops': 'Live Operations',
    '/dispatch': 'Dispatch & Assignment',
    '/merchants': 'Merchant Management',
    '/riders': 'Rider Management',
    '/finance': 'Finance & Payments',
    '/trust': 'Trust & Safety',
    '/customers': 'Customer Intelligence',
    '/geo-ops': 'Geo Operations',
    '/support': 'Support Console',
    '/identity': 'Identity & Access',
    '/ratings': 'Ratings & Reviews',
    '/promotions': 'Promotions & Campaigns',
    '/reporting': 'Reporting & Analytics',
  };
}
