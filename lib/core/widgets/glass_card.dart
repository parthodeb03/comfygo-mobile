import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/theme.dart';
import 'travel_widgets.dart';

/// Primary green button — full-width, gradient fill, glow shadow and a
/// press micro-interaction.
class CGButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;

  const CGButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 54,
  });

  @override
  State<CGButton> createState() => _CGButtonState();
}

class _CGButtonState extends State<CGButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final enabled = widget.onPressed != null && !widget.isLoading;
    final outlined = widget.isOutlined;

    final Color contentColor = !enabled
        ? (outlined ? AppColors.textHint(context) : Colors.white70)
        : outlined
        ? primary
        : Colors.white;

    return SizedBox(
      width: widget.width ?? double.infinity,
      // IntrinsicHeight keeps the button at its content height (min [widget.height])
      // instead of letting the inner Center stretch to fill a parent's bounded
      // height (e.g. inside a Row in a bottom bar, which otherwise swallows the
      // whole screen and leaves the body zero height).
      child: IntrinsicHeight(
        child: Listener(
          onPointerDown: enabled ? (_) => _setPressed(true) : null,
          onPointerUp: (_) => _setPressed(false),
          onPointerCancel: (_) => _setPressed(false),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: outlined
                    ? null
                    : LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: enabled
                            ? const [
                                OneUIColors.buttonGreenDark,
                                OneUIColors.buttonGreen,
                                OneUIColors.buttonGreenLight,
                              ]
                            : [Colors.grey.shade500, Colors.grey.shade400],
                        stops: enabled ? const [0.0, 0.55, 1.0] : null,
                      ),
                color: outlined
                    ? enabled
                          ? primary.withValues(alpha: 0.07)
                          : Colors.transparent
                    : null,
                borderRadius: BorderRadius.circular(16),
                border: outlined
                    ? Border.all(
                        color: enabled ? primary : AppColors.divider(context),
                        width: 1.6,
                      )
                    : null,
                boxShadow: enabled && !outlined
                    ? [
                        const BoxShadow(
                          color: Color(0x661B7A4F),
                          blurRadius: 18,
                          offset: Offset(0, 6),
                        ),
                      ]
                    : const [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.isLoading ? null : widget.onPressed,
                    borderRadius: BorderRadius.circular(16),
                    splashColor: outlined
                        ? primary.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.20),
                    highlightColor: outlined
                        ? primary.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: widget.height),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        child: Center(
                          child: _buildChild(contentColor, primary),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color contentColor, Color spinnerColor) {
    if (widget.isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.isOutlined ? spinnerColor : Colors.white,
          ),
        ),
      );
    }
    final text = Text(
      widget.label,
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: contentColor,
      ),
    );
    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 20, color: contentColor),
          const SizedBox(width: 8),
          Flexible(child: text),
        ],
      );
    }
    return text;
  }
}

/// Social sign-in button — surface fill with thin border
class CGSocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  const CGSocialButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 54),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary(context),
          backgroundColor: AppColors.surface(context),
          side: BorderSide(color: AppColors.divider(context), width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill-shaped category chip — selectable
class CGChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Color? activeColor;
  final Color? inactiveColor;

  const CGChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  State<CGChip> createState() => _CGChipState();
}

class _CGChipState extends State<CGChip> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeBg = widget.activeColor ?? AppColors.primary(context);
    final inactiveBg =
        widget.inactiveColor ?? AppColors.surfaceVariant(context);

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 13,
              fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
              color: widget.isSelected
                  ? Colors.white
                  : AppColors.textSecondary(context),
            ),
            child: Text(widget.label),
          ),
        ),
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
      ),
    );
  }
}

/// Flat card with rounded corners — matches reference kit card style
class CGCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final Color? color;
  final Border? border;

  const CGCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.width,
    this.height,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        padding: padding ?? const EdgeInsets.all(OneUISpacing.lg),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface(context),
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
        ),
        child: child,
      ),
    );
  }
}

/// Listing card — image + name + price, used in grid browsing
class CGListingCard extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final String? subtitle;
  final String? price;
  final VoidCallback? onTap;
  final Widget? badge;
  final double? imageHeight;
  final String? heroTag;
  final String? imageAsset;

  const CGListingCard({
    super.key,
    this.imageUrl,
    required this.name,
    this.subtitle,
    this.price,
    this.onTap,
    this.badge,
    this.imageHeight = 140,
    this.heroTag,
    this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider(context), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                _buildImage(context),
                if (badge != null) Positioned(top: 10, left: 10, child: badge!),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (price != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      price!,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageWidget = Container(
      height: imageHeight,
      width: double.infinity,
      color: AppColors.surfaceVariant(context),
      child: TravelPhoto(
        url: imageUrl,
        asset: imageAsset ?? TravelPhotos.forDestination(name),
        label: name,
      ),
    );

    if (heroTag != null) {
      return Hero(tag: heroTag!, child: imageWidget);
    }
    return imageWidget;
  }
}

/// Quantity stepper — + / - with animated count
class CGStepper extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const CGStepper({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 99,
    required this.onChanged,
  });

  @override
  State<CGStepper> createState() => _CGStepperState();
}

class _CGStepperState extends State<CGStepper> {
  late int _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  void didUpdateWidget(CGStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _value = widget.value;
  }

  void _increment() {
    if (_value < widget.max) {
      HapticFeedback.lightImpact();
      setState(() => _value++);
      widget.onChanged(_value);
    }
  }

  void _decrement() {
    if (_value > widget.min) {
      HapticFeedback.lightImpact();
      setState(() => _value--);
      widget.onChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildButton(Icons.remove_rounded, _decrement, _value > widget.min),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              '$_value',
              key: ValueKey(_value),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          _buildButton(Icons.add_rounded, _increment, _value < widget.max),
        ],
      ),
    );
  }

  Widget _buildButton(IconData icon, VoidCallback onTap, bool enabled) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? AppColors.textPrimary(context)
              : AppColors.textHint(context),
        ),
      ),
    );
  }
}

/// Gradient banner card — green background with image bleeding to side
class CGBannerCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? child;
  final VoidCallback? onTap;
  final double height;

  const CGBannerCard({
    super.key,
    required this.title,
    this.subtitle,
    this.child,
    this.onTap,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: height),
        width: double.infinity,
        padding: const EdgeInsets.all(OneUISpacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary(context), Color(0xFF2A8F63)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
            if (child != null) ...[const SizedBox(height: 12), child!],
          ],
        ),
      ),
    );
  }
}

/// Section header with optional "See All" link
class CGSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const CGSectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: OneUISpacing.lg,
        vertical: OneUISpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-screen green splash background
class CGSplashBackground extends StatelessWidget {
  final Widget child;

  const CGSplashBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primaryVariant(context),
            AppColors.primary(context),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// Status badge for booking status
class CGStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool animate;

  const CGStatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: color),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      builder: (context, animatedColor, child) {
        final c = animatedColor ?? color;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
            child: Text(label),
          ),
        );
      },
    );
  }
}

/// Favorite heart button with animation
class CGFavoriteButton extends StatefulWidget {
  final bool isFavorited;
  final ValueChanged<bool> onChanged;

  const CGFavoriteButton({
    super.key,
    this.isFavorited = false,
    required this.onChanged,
  });

  @override
  State<CGFavoriteButton> createState() => _CGFavoriteButtonState();
}

class _CGFavoriteButtonState extends State<CGFavoriteButton>
    with SingleTickerProviderStateMixin {
  late bool _isFavorited;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _isFavorited = widget.isFavorited;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  @override
  void didUpdateWidget(CGFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorited != widget.isFavorited) {
      _isFavorited = widget.isFavorited;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _isFavorited = !_isFavorited);
        widget.onChanged(_isFavorited);
        _controller.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            _isFavorited ? Icons.favorite : Icons.favorite_border_rounded,
            color: _isFavorited ? Colors.red : AppColors.textSecondary(context),
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// LEGACY ALIASES — kept for backward compatibility during migration
// ═══════════════════════════════════════════════════════════════════

/// Legacy alias — use CGCard instead
class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? tintColor;
  final Border? border;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 15,
    this.opacity = 0.15,
    this.padding,
    this.margin,
    this.borderRadius = OneUISpacing.radiusXl,
    this.tintColor,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CGCard(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      width: width,
      height: height,
      border: border,
      child: child,
    );
  }
}

/// Legacy alias — use CGSplashBackground or Container with green gradient
class GlassBackground extends StatelessWidget {
  final String imagePath;
  final Widget child;
  final double gradientOpacity;
  final List<Color>? gradientColors;

  const GlassBackground({
    super.key,
    required this.imagePath,
    required this.child,
    this.gradientOpacity = 0.6,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with fallback
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              Container(color: AppColors.background(context)),
        ),
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:
                  gradientColors ??
                  [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: gradientOpacity),
                  ],
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

/// Legacy alias — use CGButton instead
class GlassOverlay extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;

  const GlassOverlay({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.blur = 20,
    this.opacity = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(OneUISpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      child: child,
    );
  }
}

/// Legacy alias — use standard TextFormField with InputDecoration instead
class GlassInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int maxLines;

  const GlassInput({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.focusNode,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      textInputAction: textInputAction,
      enabled: enabled,
      maxLines: obscureText ? 1 : maxLines,
      style: TextStyle(color: AppColors.textPrimary(context), fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: AppColors.textHint(context), fontSize: 15),
        prefixIcon: prefixIcon != null
            ? Icon(
                prefixIcon,
                color: AppColors.textSecondary(context),
                size: 20,
              )
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.inputFill(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary(context), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: OneUIColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}
