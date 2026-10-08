import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../state/auth_provider.dart';

/// Launch screen: waits for the auth check, then routes to
/// intro slides (first run) → login, or straight home when signed in.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// SharedPreferences key marking that the intro slides were shown once.
  static const String introSeenKey = 'intro_seen';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _controller.forward();
    _leave();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _leave() async {
    final prefs = SharedPreferences.getInstance();
    final minSplash = Future<void>.delayed(const Duration(milliseconds: 1600));

    // Wait until the auth check finished (router redirect needs it too)
    while (!ref.read(authProvider).isInitialized) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }

    final introSeen = (await prefs).getBool(SplashScreen.introSeenKey) ?? false;
    await minSplash;

    if (!mounted || _navigated) return;
    _navigated = true;

    final isAuthenticated = ref.read(authProvider).isAuthenticated;
    if (isAuthenticated) {
      context.go('/');
    } else if (introSeen) {
      context.go('/login');
    } else {
      context.go('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary(context)
                            .withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.flight_takeoff_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: OneUISpacing.lg),
                Text(
                  'ComfyGo',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: OneUISpacing.xs),
                Text(
                  'Travel Bangladesh, comfortably',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: OneUISpacing.xxl),
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.primary(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
