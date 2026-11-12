// Landing screen ("Travel and share moments with us") from the reference UI.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/comfy_ui.dart';
import '../widgets/reference_art.dart';
import '../widgets/reference_controls.dart';
import '../widgets/reference_theme.dart';

/// First page of the reference: the tilted-photo collage, the headline and the
/// two entry actions. Shown once the intro slides are done, before sign in.
///
/// The layout follows the reference; the palette is green rather than aqua.
class WelcomeScreen extends StatelessWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const WelcomeScreen({super.key});

  /// Soft leaf-green page background.
  static const LinearGradient _lightBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE9F7E3), Color(0xFFCDEBC8), Color(0xFFF5F8E7)],
    stops: [0, 0.48, 1],
  );

  /// Forest-green page background for dark mode.
  static const LinearGradient _darkBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1F14), Color(0xFF12351F), Color(0xFF17402A)],
    stops: [0, 0.5, 1],
  );

  /// Green call-to-action, matching the page.
  static const LinearGradient _cta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5239), Color(0xFF2E7D4F)],
  );

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: c.bg,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: isDark ? _darkBg : _lightBg),
          child: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CgCollage(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Text(
                            'Travel and share moments with us',
                            style: CgRefType.display.copyWith(color: c.text),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 290),
                          child: Text(
                            'Share the moments that matter, connect with fellow '
                            'travellers and turn every journey into a story.',
                            style: CgRefType.bodyS.copyWith(color: c.text2),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _SignInAction(onTap: () => context.go('/login')),
                              CgRefButton(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                ),
                                gradient: _cta,
                                semanticLabel: 'Get started',
                                onTap: () => context.go('/signup'),
                                child: const Text('Get started'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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

class _SignInAction extends StatelessWidget {
  const _SignInAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    return CgPressable(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            'Sign in',
            style: CgRefType.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: c.text,
            ),
          ),
        ),
      ),
    );
  }
}
