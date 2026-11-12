import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/comfy_destinations.dart';
import '../../state/saved_destinations_provider.dart';
import '../theme/comfy_design.dart';

/// Shared backdrop photo used by [CgBackground] across the whole app.
const String kCgBackdropAsset = 'assets/images/background image.jfif'; // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.

/// Full-screen background used by every redesigned page.
///
/// Layers the shared travel photo beneath a theme-aware linear gradient, then
/// brings it to life with a slow Ken Burns drift, a soft diagonal light sweep
/// and floating light motes. Content sits on top and stays fully readable.
///
/// Widget tests render the same composition as a static frame (see
/// [_motionEnabled]) so `pumpAndSettle` still terminates.
class CgBackground extends StatefulWidget {
  const CgBackground({super.key, required this.child, this.gradient});

  final Widget child;

  /// Optional overlay gradient (e.g. the sage auth wash). When null, the
  /// theme's background gradient tints the photo.
  final Gradient? gradient;

  /// The wash applied over the backdrop photo when no [gradient] is given.
  static LinearGradient washFor(bool dark) => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: dark
        ? const [Color(0xE60F1A14), Color(0xB313231B), Color(0xEB0F1A14)]
        : const [Color(0xC7F6F9F3), Color(0x94EFF5EC), Color(0xF2F6F9F3)],
  );

  @override
  State<CgBackground> createState() => _CgBackgroundState();
}

class _CgBackgroundState extends State<CgBackground>
    with SingleTickerProviderStateMixin {
  /// The looping motion would keep `pumpAndSettle` busy forever, so tests
  /// freeze the animation mid-cycle and paint that frame instead.
  static final bool _motionEnabled =
      !Platform.environment.containsKey('FLUTTER_TEST');

  /// Frozen progress used when motion is disabled (tests).
  static const double _staticProgress = 0.35;

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    final c = CgColors.of(context);
    final wash = widget.gradient;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid base so nothing flashes while the photo decodes.
        ColoredBox(
          color: dark ? const Color(0xFF0F1A14) : const Color(0xFFEFF5EC),
        ),
        // Ken Burns photo layer.
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_loop.value);
              return Transform.scale(
                scale: 1.06 + 0.06 * t,
                child: Image.asset(
                  kCgBackdropAsset,
                  fit: BoxFit.cover,
                  cacheWidth: 1080,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
        // Linear gradient wash — keeps text and cards readable on the photo.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: wash ?? CgBackground.washFor(dark),
            ),
          ),
        ),
        // Soft diagonal light sweep.
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, _) {
              final p = _loop.value;
              final w = MediaQuery.sizeOf(context).width;
              return Opacity(
                opacity: clampDouble(math.sin(math.pi * p) * 0.55, 0, 1),
                child: Transform.translate(
                  offset: Offset(w * (-0.9 + 2.0 * p), 0),
                  child: Transform.rotate(
                    angle: -0.45,
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: w * 0.5,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              (dark ? Colors.white : Colors.white).withValues(
                                alpha: 0.18,
                              ),
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
        // Floating light motes.
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _loop,
            builder: (context, _) => CustomPaint(
              painter: _MotesPainter(
                progress: _loop.value,
                tint: dark ? c.accent : Colors.white,
              ),
            ),
          ),
        ),
        // Gentle fade-in whenever a page mounts.
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
          builder: (context, opacity, _) => Opacity(
            opacity: opacity,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// Paints a handful of softly blurred motes drifting up the screen.
class _MotesPainter extends CustomPainter {
  const _MotesPainter({required this.progress, required this.tint});

  final double progress;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 16;
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    for (var i = 0; i < count; i++) {
      final seed = (i * 0.6180339887) % 1;
      final speed = 0.3 + (i % 5) * 0.11;
      final phase = (seed + progress * speed) % 1;
      final x = size.width * ((seed * 7.3) % 1);
      final y = size.height * (1.06 - phase * 1.12);
      final radius = 2.2 + (i % 4) * 1.1;
      final opacity = math.sin(math.pi * phase) * 0.5;
      paint.color = tint.withValues(alpha: opacity * 0.30);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MotesPainter old) =>
      old.progress != progress || old.tint != tint;
}

/// Rounded surface with the reference card gradient and shadow.
class CgCard extends StatelessWidget {
  const CgCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = CgRadii.card,
    this.shadow = true,
    this.clipBehavior = Clip.none,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final bool shadow;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Container(
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        gradient: c.gCard,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ? c.cardShadow : null,
      ),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );
  }
}

/// Circular white action button (`round` in the reference).
class CgRoundButton extends StatelessWidget {
  const CgRoundButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 48,
    this.iconSize = 22,
    this.color,
    this.semanticLabel,
    this.background,
    this.shadow = true,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final Color? color;
  final String? semanticLabel;
  final Gradient? background;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: CgPressable(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: background ?? c.gCard,
            shape: BoxShape.circle,
            boxShadow: shadow ? c.cardShadow : null,
          ),
          child: Icon(icon, size: iconSize, color: color ?? c.text),
        ),
      ),
    );
  }
}

/// Gradient call-to-action with the reference 56px pill shape.
class CgPillButton extends StatelessWidget {
  const CgPillButton({
    super.key,
    required this.child,
    this.onTap,
    this.loading = false,
    this.width,
    this.height = 56,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool loading;
  final double? width;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: CgPressable(
        onTap: loading ? null : onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: c.gMain,
            borderRadius: BorderRadius.circular(CgRadii.pill),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: .28),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: loading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(c.onPrimary),
                  ),
                )
              : DefaultTextStyle.merge(
                  style: CgType.button.copyWith(color: c.onPrimary),
                  child: child,
                ),
        ),
      ),
    );
  }
}

/// Category filter chip with the mint icon badge and accent underline.
class CgChip extends StatelessWidget {
  const CgChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: CgPressable(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          height: 44,
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
          decoration: BoxDecoration(
            gradient: selected ? c.gMint : c.gCard,
            borderRadius: BorderRadius.circular(CgRadii.input),
            border: Border(
              bottom: BorderSide(
                color: selected ? c.accent : Colors.transparent,
                width: 2,
              ),
            ),
            boxShadow: c.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: c.gMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 15, color: c.primary),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: CgType.b14.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One trip card, matching the structure used on Home, Explore and Saved.
class CgTripCard extends ConsumerWidget {
  const CgTripCard({
    super.key,
    required this.item,
    required this.onOpen,
    this.onHeight,
  });

  final ComfyDestination item;
  final VoidCallback onOpen;
  final double? onHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = CgColors.of(context);
    final saved = ref.watch(savedDestinationsProvider).contains(item.id);

    return CgCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ClipOval(
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: CgImage(path: item.thumb, cacheWidth: 96),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CgType.t16.copyWith(color: c.text),
                    ),
                    Text(
                      item.locationLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CgType.l12.copyWith(color: c.text2),
                    ),
                  ],
                ),
              ),
              CgRoundButton(
                size: 44,
                iconSize: 18,
                icon: Icons.north_east_rounded,
                semanticLabel: 'Open ${item.name}',
                onTap: onOpen,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: c.line),
                bottom: BorderSide(color: c.line),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: c.text2),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Time For Way',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CgType.l12.copyWith(color: c.text2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CgType.t16.copyWith(color: c.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Exclusive Tour',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CgType.t16.copyWith(color: c.text),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 12,
                            color: c.text2,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.dateRange,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CgType.l12.copyWith(color: c.text2),
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
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onOpen,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CgRadii.image),
              child: SizedBox(
                height: onHeight ?? 190,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CgImage(path: item.cover, cacheWidth: 600),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00081E14), Color(0xBF081E14)],
                          stops: [.45, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: _GlassHeart(
                        saved: saved,
                        onTap: () async {
                          await ref
                              .read(savedDestinationsProvider.notifier)
                              .toggle(item.id);
                        },
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.place_outlined,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${item.region}, Bangladesh',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: CgType.l12.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CgType.t20.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .28),
                                  borderRadius: BorderRadius.circular(
                                    CgRadii.pill,
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .6),
                                  ),
                                ),
                                child: Text(
                                  item.priceLabel,
                                  style: CgType.l12.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.star_rounded,
                                size: 13,
                                color: CgColorConstants.star,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  item.reviews,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: CgType.l12.copyWith(
                                    color: Colors.white,
                                    fontSize: 12,
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
        ],
      ),
    );
  }
}

class CgColorConstants {
  CgColorConstants._();
  static const Color star = Color(0xFFF2C230);
  static const Color danger = Color(0xFFC0453A);
  static const Color heart = Color(0xFFE5484D);
}

class _GlassHeart extends StatelessWidget {
  const _GlassHeart({required this.saved, required this.onTap});

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Semantics(
        button: true,
        label: saved ? 'Remove from saved' : 'Save destination',
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .28),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: .6)),
              ),
              child: Icon(
                saved ? Icons.favorite : Icons.favorite_border,
                size: 16,
                color: saved ? CgColorConstants.heart : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The five-tab bar from the reference (84px, icon-only, floating active pill).
class CgBottomNav extends StatelessWidget {
  const CgBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  static const List<String> routes = [
    '/',
    '/destinations',
    '/bookings',
    '/saved',
    '/profile',
  ];

  static const List<String> labels = [
    'Home',
    'Explore',
    'Bookings',
    'Saved',
    'Profile',
  ];

  static const List<IconData> icons = [
    Icons.home_outlined,
    Icons.search_rounded,
    Icons.calendar_today_outlined,
    Icons.favorite_border_rounded,
    Icons.person_outline_rounded,
  ];

  final int currentIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      height: 84 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset, left: 12, right: 12),
      decoration: BoxDecoration(
        gradient: c.gCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(CgRadii.nav),
        ),
        boxShadow: c.navShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(routes.length, (i) {
          final active = i == currentIndex;
          return Semantics(
            button: true,
            selected: active,
            label: labels[i],
            child: CgPressable(
              onTap: () => onSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 56,
                height: 46,
                decoration: BoxDecoration(
                  gradient: active ? c.gMain : null,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icons[i],
                  size: 22,
                  color: active ? c.onPrimary : c.text2,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Input field with the reference label, icon, focus ring and inline error.
class CgTextField extends StatefulWidget {
  const CgTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final int maxLines;

  @override
  State<CgTextField> createState() => _CgTextFieldState();
}

class _CgTextFieldState extends State<CgTextField> {
  late final FocusNode _focusNode;
  late bool _hidden;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscure;
    _focusNode = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final hasError = (widget.errorText ?? '').isNotEmpty;
    final borderColor = hasError
        ? CgColorConstants.danger
        : _focused
        ? c.primary
        : c.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: CgType.l12.copyWith(
            color: c.text,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: widget.maxLines > 1 ? null : 56,
          constraints: const BoxConstraints(minHeight: 56),
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: widget.maxLines > 1 ? 12 : 0,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(CgRadii.input),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: _focused && !hasError
                ? [
                    BoxShadow(
                      color: c.primary.withValues(alpha: .18),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: widget.maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(top: widget.maxLines > 1 ? 2 : 0),
                child: Icon(widget.icon, size: 18, color: c.text2),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  maxLines: widget.maxLines,
                  obscureText: _hidden,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onSubmitted: widget.onSubmitted,
                  onChanged: widget.onChanged,
                  cursorColor: c.primary,
                  style: CgType.body15.copyWith(color: c.text),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: CgType.body15.copyWith(
                      color: c.text2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              if (widget.obscure)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _hidden = !_hidden),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      _hidden ? Icons.visibility : Icons.visibility_off,
                      size: 18,
                      color: c.text2,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: CgType.l12.copyWith(color: CgColorConstants.danger),
          ),
        ],
      ],
    );
  }
}

/// Image with a branded fallback so a missing photo never shows a red box.
class CgImage extends StatelessWidget {
  const CgImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  final String path;
  final BoxFit fit;

  /// Decode width in physical pixels. Destination photos are large, so every
  /// usage asks for only the resolution it paints.
  final int? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Image.asset(
      path,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      cacheWidth: cacheWidth,
      errorBuilder: (context, error, stackTrace) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.primary, c.sage],
          ),
        ),
        child: const Center(
          child: Icon(Icons.landscape_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

/// Scales its child to 0.97 while pressed, like the reference button states.
class CgPressable extends StatefulWidget {
  const CgPressable({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  State<CgPressable> createState() => _CgPressableState();
}

class _CgPressableState extends State<CgPressable> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null;

  void _setPressed(bool value) {
    if (!_enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? .97 : 1,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Blurred sheet used behind the auth forms.
class CgSheet extends StatelessWidget {
  const CgSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 640),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(CgRadii.sheet),
        ),
      ),
      child: child,
    );
  }
}

/// Reference-style toast pinned above the bottom navigation.
void showCgToast(BuildContext context, String message) {
  final c = CgColors.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: CgType.l12.copyWith(
          color: c.onPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      backgroundColor: c.primary,
      behavior: SnackBarBehavior.floating,
      elevation: 12,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 96),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(milliseconds: 2200),
    ),
  );
}
