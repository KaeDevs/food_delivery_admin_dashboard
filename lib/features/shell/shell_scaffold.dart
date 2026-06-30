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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _routes = [
    '/dashboard',
    '/live-ops',
    '/dispatch',
    '/merchants',
    '/riders',
    '/finance',
    '/trust',
    '/customers',
    '/geo-ops',
    '/support',
    '/identity',
    '/ratings',
    '/promotions',
    '/reporting',
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 900;
        final isMedium =
            constraints.maxWidth >= 900 && constraints.maxWidth < 1200;

        return Scaffold(
          key: _scaffoldKey,
          drawer: isCompact
              ? Drawer(
                  child: NavRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (idx) {
                      _onDestinationSelected(idx);
                      Navigator.pop(context);
                    },
                    isCollapsed: false,
                  ),
                )
              : null,
          body: Row(
            children: [
              // Navigation Rail
              if (!isCompact)
                NavRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onDestinationSelected,
                  isCollapsed: isMedium,
                ),
              if (!isCompact)
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
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.1 : 0.01),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          if (isCompact)
                            IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () =>
                                  _scaffoldKey.currentState?.openDrawer(),
                            ),
                          if (isCompact) const SizedBox(width: 8),
                          Text(
                            pageTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const Spacer(),
                          // Alert bell
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.notifications_none_rounded,
                                    size: 20,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  onPressed: () {
                                    _showAlertPanel(context, ref);
                                  },
                                ),
                              ),
                              if (alertCount > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: kDanger,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 1.5,
                                      ),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      '$alertCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.2),
                              ),
                            ),
                            child: Text(
                              ref.watch(authProvider)?.role ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
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
      },
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
                          Text(
                            'Active Alerts',
                            style: theme.textTheme.titleSmall,
                          ),
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
                        final color = alert.severity == AlertSeverity.critical
                            ? kDanger
                            : alert.severity == AlertSeverity.warning
                            ? kWarning
                            : kInfo;
                        return ListTile(
                          leading: Icon(
                            alert.severity == AlertSeverity.critical
                                ? Icons.error
                                : Icons.warning_amber,
                            color: color,
                            size: 20,
                          ),
                          title: Text(
                            alert.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            alert.ownerRole,
                            style: theme.textTheme.labelSmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  String route = '/dashboard';
                                  final roleLow = alert.ownerRole.toLowerCase();
                                  if (roleLow.contains('dispatch'))
                                    route = '/dispatch';
                                  else if (roleLow.contains('merchant'))
                                    route = '/merchants';
                                  else if (roleLow.contains('finance'))
                                    route = '/finance';
                                  else if (roleLow.contains('ops') ||
                                      roleLow.contains('operations'))
                                    route = '/live-ops';
                                  // else if (roleLow.contains('trust'))
                                  //   route = '/trust';

                                  final visibleRoutes =
                                      NavRail.getVisibleRoutesForRole(
                                        ref.read(authProvider)?.role ?? '',
                                      );
                                  if (visibleRoutes.contains(route)) {
                                    context.go(route);
                                  }
                                },
                                child: const Text(
                                  'Go to →',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                onPressed: () {
                                  ref
                                      .read(alertProvider.notifier)
                                      .dismiss(alert.id);
                                },
                              ),
                            ],
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
    '/dashboard': 'Dashboard',
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
