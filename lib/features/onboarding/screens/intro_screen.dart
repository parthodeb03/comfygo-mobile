// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import 'splash_screen.dart';

/// First-run artwork screen, reproduced from the reference intro page.
class IntroScreen extends StatefulWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  Future<void> _markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SplashScreen.introSeenKey, true);
    } catch (_) {
      // The intro is still usable if preferences are unavailable.
    }
  }

  Future<void> _start() async {
    await _markSeen();
    if (mounted) context.go('/welcome');
  }

  Future<void> _signUp() async {
    await _markSeen();
    if (mounted) context.go('/signup');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: CgColors.light.bg,
      body: CgBackground(
        gradient: CgColors.light.gSage,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).top,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Explore',
                          style: CgType.t20.copyWith(
                            fontSize: 26,
                            height: 32 / 26,
                            color: CgColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Transform.rotate(
                          angle: -2 * math.pi / 180,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            color: CgColors.deepGreen,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            child: Text(
                              'Worldwide',
                              style: CgType.t20.copyWith(
                                fontSize: 26,
                                height: 32 / 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedBuilder(
                      animation: _float,
                      builder: (context, child) {
                        final offset =
                            math.sin(_float.value * math.pi * 2) * -8.0;
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        height: 300,
                        width: width,
                        child: SvgPicture.asset(
                          'assets/illustrations/intro_scene.svg',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Disc'),
                              TextSpan(
                                text: 'ov',
                                style: CgType.t20.copyWith(
                                  fontSize: 23,
                                  height: 34 / 23,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(
                                text: 'er The World With Travel Gui',
                              ),
                              TextSpan(
                                text: 'd',
                                style: CgType.t20.copyWith(
                                  fontSize: 23,
                                  height: 34 / 23,
                                  color: Colors.white,
                                ),
                              ),
                              const TextSpan(text: 'er'),
                            ],
                          ),
                          style: CgType.t20.copyWith(
                            fontSize: 23,
                            height: 34 / 23,
                            fontWeight: FontWeight.w700,
                            color: CgColors.ink,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explore destinations, cultures and hidden gems '
                          'with our travel guide.',
                          style: CgType.b14.copyWith(color: CgColors.inkSoft),
                        ),
                        const SizedBox(height: 20),
                        CgPillButton(
                          width: double.infinity,
                          semanticLabel: "Let's get started",
                          onTap: _start,
                          child: SizedBox(
                            height: 56,
                            width: double.infinity,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 8,
                                  top: 8,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      size: 18,
                                      color: CgColors.deepGreen,
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  left: 56,
                                  right: 16,
                                  child: Center(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text("Let’s get started!"),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 16,
                                            color: CgColors.light.onPrimary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'You do not have any account? ',
                              style: CgType.b14.copyWith(
                                fontSize: 14,
                                color: CgColors.inkSoft,
                              ),
                            ),
                            GestureDetector(
                              onTap: _signUp,
                              child: Text(
                                'Sign Up',
                                style: CgType.b14.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: CgColors.ink,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
