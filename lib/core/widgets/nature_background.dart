import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Soft, nature-inspired backdrop: a gentle green wash, glowing sunlit blobs
/// and a faint hill silhouette. Keeps screens from looking empty while text
/// and cards stay fully readable on top.
class NatureBackground extends StatelessWidget {
  final Widget? child;

  const NatureBackground({super.key, this.child});

  /// Standard usage: fills the parent and layers [child] on top.
  static Widget wrap({required Widget child}) => Stack(
    fit: StackFit.expand,
    children: [
      const Positioned.fill(child: NatureBackground()),
      child,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final painter = _NaturePainter(dark: AppColors.isDark(context));
    if (child == null) return CustomPaint(painter: painter);
    return CustomPaint(painter: painter, child: child);
  }
}

/// Photo backdrop for list screens: a real travel photo washed with a
/// green gradient so cards and text stay readable in both themes.
class PhotoBackground extends StatelessWidget {
  final String asset;
  final Widget? child;

  const PhotoBackground({
    super.key,
    this.asset = 'assets/images/bg_list_green.jpg',
    this.child,
  });

  /// Standard usage: fills the parent and layers [child] on top.
  static Widget wrap({
    required Widget child,
    String asset = 'assets/images/bg_list_green.jpg',
  }) => Stack(
    fit: StackFit.expand,
    children: [
      Positioned.fill(child: PhotoBackground(asset: asset)),
      child,
    ],
  );

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    final photo = Positioned.fill(
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
    final wash = Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: dark
                ? const [
                    Color(0xD90B1610),
                    Color(0x9E0C1710),
                    Color(0xC408120C),
                  ]
                : const [
                    Color(0xC4EDF6EA),
                    Color(0xA8DFEDE0),
                    Color(0xD6D2E6D6),
                  ],
          ),
        ),
      ),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        if (child == null) const ColoredBox(color: Color(0xFFE3F0E7)),
        photo,
        wash,
        ?child,
      ],
    );
  }
}

class _NaturePainter extends CustomPainter {
  final bool dark;
  const _NaturePainter({required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Base wash
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [Color(0xFF101713), Color(0xFF0F1512)]
              : const [Color(0xFFF5FAF5), Color(0xFFEAF3EC)],
        ).createShader(rect),
    );

    void blob(double fx, double fy, double rf, Color color) {
      final center = Offset(size.width * fx, size.height * fy);
      final radius = size.width * rf;
      if (radius <= 0) return;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    final green = dark ? const Color(0xFF2FA96C) : const Color(0xFF1B7A4F);
    final leaf = dark ? const Color(0xFF7BC47F) : const Color(0xFF8BCB6B);

    // Sunlit glow top-right, cool shade mid-left, warm meadow bottom-right
    blob(0.92, 0.02, 0.75, green.withValues(alpha: dark ? 0.20 : 0.14));
    blob(0.02, 0.34, 0.60, leaf.withValues(alpha: dark ? 0.12 : 0.10));
    blob(0.80, 0.72, 0.70, green.withValues(alpha: dark ? 0.14 : 0.08));

    // Gentle hill silhouette near the bottom
    final hill = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.80,
        size.width * 0.55,
        size.height * 0.89,
      )
      ..quadraticBezierTo(
        size.width * 0.80,
        size.height * 0.97,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      hill,
      Paint()..color = green.withValues(alpha: dark ? 0.22 : 0.07),
    );
  }

  @override
  bool shouldRepaint(_NaturePainter oldDelegate) => oldDelegate.dark != dark;
}
