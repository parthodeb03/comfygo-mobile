// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/comfy_design.dart';

/// Photo shown by the auth backgrounds.
const String kMountainAsset = 'assets/images/mountain.jfif'; // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.

/// True full-bleed mountain backdrop for the auth screens.
///
/// The photo fills the entire screen (edge to edge, top to bottom) so no empty
/// section is left behind. It is brought to life with a slow Ken Burns drift, a
/// soft diagonal light sweep and a gentle fade-in on mount. A translucent wash
/// sits on top so overlaid text and glass panels stay readable.
///
/// The looping motion is frozen on a fixed frame under `FLUTTER_TEST` (same
/// approach as `CgBackground`) so `pumpAndSettle` still terminates.
class CgMountainBackground extends StatefulWidget {
  const CgMountainBackground({super.key, this.wash});

  /// Translucent wash painted over the photo. Defaults to a soft sage scrim.
  final Gradient? wash;

  @override
  State<CgMountainBackground> createState() => _CgMountainBackgroundState();
}

class _CgMountainBackgroundState extends State<CgMountainBackground>
    with SingleTickerProviderStateMixin {
  /// Mirrors `CgBackground`: an infinite loop would keep `pumpAndSettle`
  /// busy forever, so widget tests freeze the cycle on a fixed frame.
  static final bool _motionEnabled = !Platform.environment.containsKey(
    'FLUTTER_TEST',
  );

  /// Frame painted when motion is disabled (tests).
  static const double _staticProgress = 0.35;

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
    value: _motionEnabled ? 0 : _staticProgress,
  );

  @override
  void initState() {
    super.initState();
    if (_motionEnabled) _loop.repeat(reverse: true);
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid base so nothing flashes while the photo decodes.
        const ColoredBox(color: Color(0xFF16241C)),
        // Ken Burns photo layer.
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_loop.value);
              return Transform.scale(
                scale: 1.12 + 0.08 * t,
                child: Image.asset(
                  kMountainAsset,
                  fit: BoxFit.cover,
                  cacheWidth: 1440,
                  frameBuilder: (context, child, frame, wasSync) {
                    if (wasSync) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      child: child,
                    );
                  },
                  errorBuilder: (_, _, _) => const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF2E4A38), Color(0xFF16241C)],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Readability wash over the whole photo.
        DecoratedBox(
          decoration: BoxDecoration(gradient: widget.wash ?? _defaultWash),
        ),
        // Soft diagonal light sweep.
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final p = _loop.value;
              final size = MediaQuery.sizeOf(context);
              return Opacity(
                opacity: math.sin(math.pi * p) * 0.4,
                child: Transform.translate(
                  offset: Offset(size.width * (-0.8 + 2.0 * p), 0),
                  child: Transform.rotate(
                    angle: -0.45,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: size.width * 0.5,
                        height: size.height * 1.6,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Color(0x33FFFFFF),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static const Gradient _defaultWash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x6616241C), Color(0x3316241C), Color(0x8C16241C)],
    stops: [0, 0.4, 1],
  );
}

/// Frosted-glass panel: blurs whatever sits behind it, tints it translucently
/// and adds the signature bright edge highlight of glassmorphism.
///
/// Wrap it around any content (forms, cards) that floats over the full-screen
/// photo. The blur needs a [BackdropFilter], so this must be painted over the
/// background rather than inside an opaque ancestor.
class CgGlassPanel extends StatelessWidget {
  const CgGlassPanel({
    super.key,
    required this.child,
    this.radius = const BorderRadius.vertical(
      top: Radius.circular(CgRadii.sheet),
    ),
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 40),
    this.blurSigma = 22,
    this.tint = const Color(0x33FFFFFF),
    this.highlight = const Color(0x59FFFFFF),
    this.minHeight,
  });

  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;

  /// Strength of the backdrop blur.
  final double blurSigma;

  /// Translucent fill painted over the blur.
  final Color tint;

  /// Bright border that sells the glass edge.
  final Color highlight;

  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final panel = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: double.infinity,
          constraints: minHeight == null
              ? null
              : BoxConstraints(minHeight: minHeight!),
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                tint,
                tint.withValues(alpha: tint.a * 0.55),
              ],
            ),
            borderRadius: radius,
            border: Border.all(color: highlight, width: 1.2),
          ),
          child: child,
        ),
      ),
    );

    return Semantics(container: true, child: panel);
  }
}
