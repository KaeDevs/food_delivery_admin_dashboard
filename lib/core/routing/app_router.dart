import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/shell_scaffold.dart';
import '../../features/executive/executive_screen.dart';
import '../../features/live_ops/live_ops_screen.dart';
import '../../features/dispatch/dispatch_screen.dart';
import '../../features/merchant/merchant_list_screen.dart';
import '../../features/merchant/merchant_detail_screen.dart';
import '../../features/rider/rider_list_screen.dart';
import '../../features/rider/rider_detail_screen.dart';
import '../../features/ratings/ratings_screen.dart';
import '../../features/finance/finance_screen.dart';
import '../../features/trust_safety/trust_screen.dart';
import '../../features/customer_intel/customer_screen.dart';
import '../../features/customer_intel/customer_detail_screen.dart';
import '../../features/placeholder_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/executive',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isGoingToLogin = state.uri.path == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }
      if (isLoggedIn && isGoingToLogin) {
        return '/executive';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/executive',
            builder: (context, state) => const ExecutiveScreen(),
          ),
          GoRoute(
            path: '/live-ops',
            builder: (context, state) => const LiveOpsScreen(),
          ),
          GoRoute(
            path: '/dispatch',
            builder: (context, state) => const DispatchScreen(),
          ),
          // Placeholders for remaining routes
          GoRoute(
            path: '/merchants',
            builder: (context, state) => const MerchantListScreen(),
          ),
          GoRoute(
            path: '/merchants/:id',
            builder: (context, state) => MerchantDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/riders',
            builder: (context, state) => const RiderListScreen(),
          ),
          GoRoute(
            path: '/riders/:id',
            builder: (context, state) => RiderDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceScreen(),
          ),
          GoRoute(
            path: '/trust',
            builder: (context, state) => const TrustScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerScreen(),
          ),
          GoRoute(
            path: '/customers/:id',
            builder: (context, state) => CustomerDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/geo-ops',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Geo Operations',
              icon: Icons.map_outlined,
              description: 'Manage delivery zones, geofencing, and live map view.',
            ),
          ),
          GoRoute(
            path: '/support',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Support Console',
              icon: Icons.support_agent_outlined,
              description: 'Handle customer and partner support tickets and resolutions.',
            ),
          ),
          GoRoute(
            path: '/identity',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Identity & Access',
              icon: Icons.manage_accounts_outlined,
              description: 'Manage admin user accounts, roles, and access scopes.',
            ),
          ),
          GoRoute(
            path: '/ratings',
            builder: (context, state) => const RatingsScreen(),
          ),
          GoRoute(
            path: '/promotions',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Promotions',
              icon: Icons.campaign_outlined,
              description: 'Configure and monitor discount campaigns and subsidies.',
            ),
          ),
          GoRoute(
            path: '/reporting',
            builder: (context, state) => const PlaceholderScreen(
              title: 'Reporting',
              icon: Icons.bar_chart_outlined,
              description: 'Generate and export custom data reports.',
            ),
          ),
        ],
      ),
    ],
  );
});
