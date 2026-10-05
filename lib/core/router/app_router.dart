import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/destinations/screens/destinations_screen.dart';
import '../../features/destinations/screens/destination_detail_screen.dart';
import '../../features/hotels/screens/hotels_screen.dart';
import '../../features/hotels/screens/hotel_detail_screen.dart';
import '../../features/transports/screens/transports_screen.dart';
import '../../features/guides/screens/guides_screen.dart';
import '../../features/guides/screens/guide_detail_screen.dart';
import '../../features/bookings/screens/bookings_screen.dart';
import '../../features/bookings/screens/booking_detail_screen.dart';
import '../../features/bookings/screens/booking_form_screen.dart';
import '../../features/payments/screens/payment_screen.dart';
import '../../features/packages/screens/packages_screen.dart';
import '../../features/admin/screens/admin_panel_screen.dart';
import '../../features/admin/screens/admin_login_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../core/widgets/navigation_shell.dart';
import '../../state/auth_provider.dart';

/// Global navigator key for GoRouter
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// App Router Provider — does NOT watch authProvider to avoid rebuild loops
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login',
    routes: [
      // Auth Routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Shell
      ShellRoute(
        builder: (context, state, child) => NavigationShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/destinations',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: DestinationsScreen()),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: BookingsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Detail Routes
      GoRoute(
        path: '/destinations/:id',
        builder: (context, state) =>
            DestinationDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/hotels',
        builder: (context, state) => const HotelsScreen(),
      ),
      GoRoute(
        path: '/hotels/:id',
        builder: (context, state) =>
            HotelDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/transports',
        builder: (context, state) => const TransportsScreen(),
      ),
      GoRoute(
        path: '/guides',
        builder: (context, state) => const GuidesScreen(),
      ),
      GoRoute(
        path: '/guides/:id',
        builder: (context, state) =>
            GuideDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/bookings/:id',
        builder: (context, state) =>
            BookingDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/book/:type/:itemId',
        builder: (context, state) => BookingFormScreen(
          type: state.pathParameters['type']!,
          itemId: int.parse(state.pathParameters['itemId']!),
        ),
      ),
      GoRoute(
        path: '/payments/:bookingId',
        builder: (context, state) => PaymentScreen(
          bookingId: int.parse(state.pathParameters['bookingId']!),
        ),
      ),
      GoRoute(
        path: '/packages',
        builder: (context, state) => const PackagesScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPanelScreen(),
      ),
    ],
    redirect: (context, state) {
      // We read authProvider here — it doesn't cause a router rebuild
      // because we're inside the redirect callback, not in the provider setup
      final container = ProviderScope.containerOf(context, listen: false);
      final authState = container.read(authProvider);

      // Still loading initial auth check — show nothing yet
      if (!authState.isInitialized) return null;

      final isAuth = authState.isAuthenticated;
      final location = state.matchedLocation;

      final isLoginRoute = location == '/login';
      final isSignupRoute = location == '/signup';
      final isForgotPasswordRoute = location == '/forgot-password';
      final isAdminLoginRoute = location == '/admin-login';
      final isAuthRoute =
          isLoginRoute ||
          isSignupRoute ||
          isForgotPasswordRoute ||
          isAdminLoginRoute;
      // /admin-login is deliberately NOT covered by the /admin guard below —
      // it must stay reachable before authentication.
      final isAdminRoute =
          location.startsWith('/admin') && !isAdminLoginRoute;

      // Not authenticated and not on auth page → go to login
      if (!isAuth && !isAuthRoute) {
        return '/login';
      }

      // Authenticated and on login page → go to home
      if (isAuth && isLoginRoute) {
        return '/';
      }

      // Authenticated and on signup page → go to home
      if (isAuth && isSignupRoute) {
        return '/';
      }

      // Admin access check
      if (isAdminRoute && authState.user?.role.name != 'admin') {
        return '/';
      }

      return null;
    },
  );
});
