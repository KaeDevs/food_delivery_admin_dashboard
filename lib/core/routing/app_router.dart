
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/shell/shell_scaffold.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/live_ops/live_ops_screen.dart';
import '../../features/dispatch/dispatch_screen.dart';
import '../../features/merchant/merchant_list_screen.dart';
import '../../features/merchant/merchant_detail_screen.dart';
import '../../features/rider/rider_list_screen.dart';
import '../../features/rider/rider_detail_screen.dart';
import '../../features/ratings/ratings_screen.dart';
import '../../features/finance/finance_screen.dart';

import '../../features/customer_intel/customer_screen.dart';
import '../../features/customer_intel/customer_detail_screen.dart';
import '../../features/geo_ops/geo_ops_screen.dart';
import '../../features/support/support_screen.dart';
import '../../features/identity/identity_screen.dart';
import '../../features/promotions/promotions_screen.dart';
import '../../features/reporting/reporting_screen.dart';


final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isGoingToLogin = state.uri.path == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }
      if (isLoggedIn && isGoingToLogin) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/live-ops',
            builder: (context, state) => const LiveOpsScreen(),
          ),
          GoRoute(
            path: '/dispatch',
            builder: (context, state) => const DispatchScreen(),
          ),
          // Implemented routes
          GoRoute(
            path: '/merchants',
            builder: (context, state) => const MerchantListScreen(),
          ),
          GoRoute(
            path: '/merchants/:id',
            builder: (context, state) =>
                MerchantDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/riders',
            builder: (context, state) => const RiderListScreen(),
          ),
          GoRoute(
            path: '/riders/:id',
            builder: (context, state) =>
                RiderDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/finance',
            builder: (context, state) => const FinanceScreen(),
          ),
          // GoRoute(
          //   path: '/trust',
          //   builder: (context, state) => const TrustScreen(),
          // ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomerScreen(),
          ),
          GoRoute(
            path: '/customers/:id',
            builder: (context, state) =>
                CustomerDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/geo-ops',
            builder: (context, state) => const GeoOpsScreen(),
          ),
          GoRoute(
            path: '/support',
            builder: (context, state) => const SupportScreen(),
          ),
          GoRoute(
            path: '/identity',
            builder: (context, state) => const IdentityScreen(),
          ),
          GoRoute(
            path: '/ratings',
            builder: (context, state) => const RatingsScreen(),
          ),
          GoRoute(
            path: '/promotions',
            builder: (context, state) => const PromotionsScreen(),
          ),
          GoRoute(
            path: '/reporting',
            builder: (context, state) => const ReportingScreen(),
          ),
        ],
      ),
    ],
  );
});
