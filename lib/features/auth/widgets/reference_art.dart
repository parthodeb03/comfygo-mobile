// Landing-page artwork: painted scenes, photo-style header and scribble.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'reference_theme.dart';

/// Paints one landscape "photo" from the reference.
///
/// The reference draws each destination as an inline SVG (sky gradient, sun,
/// two ridge silhouettes and a pair of trees). Painting it keeps the screens
/// identical at every size and avoids depending on remote imagery.
class CgSceneArt extends StatelessWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const CgSceneArt({super.key, required this.sky, required this.ridge});

  /// Upper colour of the sky gradient (`a[1]` in the reference data).
  final Color sky;

  /// Ridge and foreground colour (`a[0]`).
  final Color ridge;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _ScenePainter(sky: sky, ridge: ridge),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({required this.sky, required this.ridge});

  final Color sky;
  final Color ridge;

  // The SVG viewBox.
  static const double _vw = 200;
  static const double _vh = 120;

  @override
  void paint(Canvas canvas, Size size) {
    // `preserveAspectRatio="xMidYMid slice"` → cover.
    final scale = math.max(size.width / _vw, size.height / _vh);
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.translate(
      (size.width - _vw * scale) / 2,
      (size.height - _vh * scale) / 2,
    );
    canvas.scale(scale);

    final bounds = const Rect.fromLTWH(0, 0, _vw, _vh);
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [sky, const Color(0xFFFFF3C4)],
        ).createShader(bounds),
    );

    // Sun.
    canvas.drawCircle(
      const Offset(150, 30),
      14,
      Paint()..color = const Color(0xFFFFE53B),
    );

    // Back ridge: M0 40… (mirrored for the denser reference scene).
    final backRidge = Path()
      ..moveTo(0, 85)
      ..quadraticBezierTo(40, 55, 90, 80)
      ..quadraticBezierTo(140, 105, 200, 70)
      ..lineTo(200, 120)
      ..lineTo(0, 120)
      ..close();
    canvas.drawPath(backRidge, Paint()..color = ridge.withValues(alpha: 0.55));

    // Foreground ridge.
    final frontRidge = Path()
      ..moveTo(0, 100)
      ..quadraticBezierTo(50, 78, 110, 98)
      ..quadraticBezierTo(170, 118, 200, 90)
      ..lineTo(200, 120)
      ..lineTo(0, 120)
      ..close();
    canvas.drawPath(frontRidge, Paint()..color = ridge);

    // Two trees.
    final tree = Paint()..color = const Color(0xFF0E5C40);
    canvas.drawRect(const Rect.fromLTWH(34, 82, 4, 16), tree);
    canvas.drawCircle(const Offset(36, 76), 11, tree);
    canvas.drawRect(const Rect.fromLTWH(150, 86, 4, 14), tree);
    canvas.drawCircle(const Offset(152, 80), 9, tree);

    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.sky != sky || old.ridge != ridge;
}

/// Photo-style header used by sign in and sign up (`art()` in the reference).
class CgPhotoHeader extends StatelessWidget {
  const CgPhotoHeader({
    super.key,
    this.height = 330,
    this.start = const Color(0xFF1F4D3A),
    this.end = const Color(0xFF8FB39A),
    this.onBack,
    this.topPadding = 0,
    required this.child,
  });

  final double height;
  final Color start;
  final Color end;
  final VoidCallback? onBack;

  /// Device status-bar inset, added above the back button so the artwork can
  /// run edge to edge behind the system bars.
  final double topPadding;

  /// Content pinned to the bottom-left corner of the artwork.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 160deg gradient.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [start, end],
              ),
            ),
          ),
          // radial-gradient(circle at 85% 12%, …).
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, -0.76),
                radius: 0.8,
                colors: [CgRefColors.light.artHighlight, Colors.transparent],
                stops: const [0, 0.45],
              ),
            ),
          ),
          // White wave silhouettes across the lower half.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: height / 2,
            child: CustomPaint(painter: _WavePainter()),
          ),
          // Readability scrim.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, CgRefColors.light.artScrim],
                stops: const [0.35, 1],
              ),
            ),
          ),
          if (onBack != null)
            Positioned(
              left: 16,
              top: 16 + topPadding,
              child: _GlassRoundButton(
                icon: Icons.arrow_back_ios_new_rounded,
                semanticLabel: 'Back',
                onTap: onBack!,
              ),
            ),
          Positioned(left: 24, right: 24, bottom: 32, child: child),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 100;
    final sy = size.height / 60;
    canvas.save();
    canvas.scale(sx, sy);

    final light = Path()
      ..moveTo(0, 40)
      ..quadraticBezierTo(25, 20, 50, 36)
      ..quadraticBezierTo(75, 52, 100, 28)
      ..lineTo(100, 60)
      ..lineTo(0, 60)
      ..close();
    canvas.drawPath(
      light,
      Paint()..color = Colors.white.withValues(alpha: .18),
    );

    final dark = Path()
      ..moveTo(0, 50)
      ..quadraticBezierTo(30, 34, 60, 48)
      ..quadraticBezierTo(90, 62, 100, 42)
      ..lineTo(100, 60)
      ..lineTo(0, 60)
      ..close();
    canvas.drawPath(dark, Paint()..color = Colors.black.withValues(alpha: .20));

    canvas.restore();
  }

  @override
  bool shouldRepaint(_WavePainter old) => false;
}

class _GlassRoundButton extends StatelessWidget {
  const _GlassRoundButton({
    required this.icon,
    required this.semanticLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .24),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: .55)),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

/// The three tilted photo cards plus the hand-drawn orange loop that open the
/// landing screen.
class CgCollage extends StatelessWidget {
  const CgCollage({super.key});

  /// Width the reference positions its cards against.
  static const double _designWidth = 390;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : _designWidth;
        final s = (width / _designWidth).clamp(0.62, 1.2);
        final height = 470 * s;

        Widget card({
          double left = 0,
          required double top,
          required double cardWidth,
          required double cardHeight,
          required double radius,
          required double angle,
          required CgSceneArt scene,
          Widget? overlay,
          double? right,
          Border? border,
        }) {
          final content = ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                scene,
                if (overlay != null)
                  Positioned(left: 8 * s, top: 8 * s, child: overlay),
              ],
            ),
          );

          return Positioned(
            left: right == null ? left * s : null,
            right: right == null ? null : right * s,
            top: top * s,
            width: cardWidth * s,
            height: cardHeight * s,
            child: Transform.rotate(
              angle: angle * math.pi / 180,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: border,
                  boxShadow: CgRefColors.light.shadow2,
                ),
                child: content,
              ),
            ),
          );
        }

        return SizedBox(
          height: height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              card(
                left: 22,
                top: 70,
                cardWidth: 150,
                cardHeight: 200,
                radius: 18,
                angle: -8,
                scene: const CgSceneArt(
                  sky: Color(0xFFE8D9B0),
                  ridge: Color(0xFF1F6F8B),
                ),
              ),
              card(
                right: 20,
                top: 46,
                cardWidth: 170,
                cardHeight: 210,
                radius: 18,
                angle: 7,
                scene: const CgSceneArt(
                  sky: Color(0xFFB7C9A8),
                  ridge: Color(0xFF3E5C76),
                ),
              ),
              card(
                left: 105,
                top: 130,
                cardWidth: 180,
                cardHeight: 250,
                radius: 22,
                angle: 0,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .75),
                  width: 5 * s,
                ),
                scene: const CgSceneArt(
                  sky: Color(0xFFA8C98B),
                  ridge: Color(0xFF2F6B4A),
                ),
                overlay: _GlassPill(label: 'Sreemangal, Sylhet'),
              ),
              Positioned.fill(
                child: IgnorePointer(child: CgScribble(s: s)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlassPill extends StatelessWidget {
  const _GlassPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CgRefColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: c.glassFill,
        borderRadius: BorderRadius.circular(CgRefRadii.pill),
        border: Border.all(color: c.glassBorder),
      ),
      child: Text(
        label,
        style: CgRefType.label.copyWith(
          color: c.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Animated orange loop that draws itself in 1.4 s after a 0.3 s delay,
/// exactly like the CSS `draw` keyframes.
class CgScribble extends StatefulWidget {
  const CgScribble({super.key, required this.s});

  final double s;

  @override
  State<CgScribble> createState() => _CgScribbleState();
}

class _CgScribbleState extends State<CgScribble>
    with SingleTickerProviderStateMixin {
  /// 300 ms hold, then a 1.4 s draw — the CSS `draw` keyframes.
  late final AnimationController _draw = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _draw,
    curve: const Interval(300 / 1700, 1, curve: Cubic(0.22, 1, 0.36, 1)),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      _draw.value = 1;
    } else {
      _draw.forward();
    }
  }

  @override
  void dispose() {
    _draw.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _draw,
      builder: (context, _) => CustomPaint(
        painter: _DrawProgressPainter(s: widget.s, progress: _progress.value),
      ),
    );
  }
}

class _DrawProgressPainter extends CustomPainter {
  const _DrawProgressPainter({required this.s, required this.progress});

  final double s;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    canvas.save();
    canvas.scale(size.width / 390, size.height / 470);
    final path = Path()
      ..moveTo(30, 300)
      ..cubicTo(20, 160, 170, 120, 320, 170)
      ..cubicTo(380, 195, 370, 290, 250, 330)
      ..cubicTo(140, 365, 40, 345, 60, 270);
    final paint = Paint()
      ..color = CgRefColors.light.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DrawProgressPainter old) =>
      old.progress != progress || old.s != s;
}
