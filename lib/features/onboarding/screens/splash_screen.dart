// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/auth_provider.dart';

/// Launch screen: waits for the auth check, then routes to
/// intro slides (first run) → login, or straight home when signed in.
class SplashScreen extends ConsumerStatefulWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
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
      context.go('/welcome');
    } else {
      context.go('/intro');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: CgBackground(
        child: Center(
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
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: c.gMint,
                      shape: BoxShape.circle,
                      boxShadow: c.cardShadow,
                    ),
                    child: SizedBox(
                      width: 56,
                      height: 64,
                      child: SvgPicture.asset('assets/illustrations/mango.svg'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ComfyGo',
                    style: CgType.t20.copyWith(fontSize: 30, color: c.text),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Travel Bangladesh, comfortably',
                    style: CgType.b14.copyWith(color: c.text2),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
