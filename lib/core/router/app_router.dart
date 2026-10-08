import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/intro_screen.dart';
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
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/contact_screen.dart';
import '../../features/profile/screens/static_page_screen.dart';
import '../../features/spots/screens/spots_screen.dart';
import '../../features/spots/screens/spot_detail_screen.dart';
import '../../core/widgets/navigation_shell.dart';
import '../../state/auth_provider.dart';

/// Global navigator key for GoRouter
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Smooth fade + rise transition used by pushed (non-shell) routes.
CustomTransitionPage<T> _fadeSlide<T>(GoRouterState state, Widget child) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// App Router Provider — does NOT watch authProvider to avoid rebuild loops
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      // Launch flow: splash → intro slides (first run) → auth
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: IntroScreen()),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeSlide(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const SignupScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const ForgotPasswordScreen()),
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
        pageBuilder: (context, state) => _fadeSlide(
          state,
          DestinationDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/hotels',
        pageBuilder: (context, state) => _fadeSlide(state, const HotelsScreen()),
      ),
      GoRoute(
        path: '/hotels/:id',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          HotelDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/transports',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const TransportsScreen()),
      ),
      GoRoute(
        path: '/guides',
        pageBuilder: (context, state) => _fadeSlide(state, const GuidesScreen()),
      ),
      GoRoute(
        path: '/guides/:id',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          GuideDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/bookings/:id',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          BookingDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ),
      GoRoute(
        path: '/book/:type/:itemId',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          BookingFormScreen(
            type: state.pathParameters['type']!,
            itemId: int.parse(state.pathParameters['itemId']!),
          ),
        ),
      ),
      GoRoute(
        path: '/payments/:bookingId',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          PaymentScreen(
            bookingId: int.parse(state.pathParameters['bookingId']!),
          ),
        ),
      ),
      GoRoute(
        path: '/packages',
        pageBuilder: (context, state) => _fadeSlide(state, const PackagesScreen()),
      ),

      // Tourist spots (view-only inspiration)
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: '/help',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const HelpSupportScreen()),
      ),
      GoRoute(
        path: '/contact',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const ContactScreen()),
      ),
      GoRoute(
        path: '/about',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          const StaticPageScreen(page: StaticPageScreen.about),
        ),
      ),
      GoRoute(
        path: '/privacy',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          const StaticPageScreen(page: StaticPageScreen.privacy),
        ),
      ),
      GoRoute(
        path: '/terms',
        pageBuilder: (context, state) => _fadeSlide(
          state,
          const StaticPageScreen(page: StaticPageScreen.terms),
        ),
      ),
      GoRoute(
        path: '/spots',
        pageBuilder: (context, state) => _fadeSlide(state, const SpotsScreen()),
      ),
      GoRoute(
        path: '/spots/:id',
        pageBuilder: (context, state) =>
            _fadeSlide(state, SpotDetailScreen(id: state.pathParameters['id']!)),
      ),

      // Admin Routes
      GoRoute(
        path: '/admin-login',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const AdminLoginScreen()),
      ),
      GoRoute(
        path: '/admin',
        pageBuilder: (context, state) =>
            _fadeSlide(state, const AdminPanelScreen()),
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
      final isSplashRoute = location == '/splash';
      final isIntroRoute = location == '/intro';
      final isAuthRoute =
          isLoginRoute ||
          isSignupRoute ||
          isForgotPasswordRoute ||
          isAdminLoginRoute ||
          isSplashRoute ||
          isIntroRoute;
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

      // Splash/intro are only for signed-out users — the SplashScreen itself
      // also routes, this just keeps the URL consistent when auth resolves.
      if (isAuth && (isSplashRoute || isIntroRoute)) {
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
