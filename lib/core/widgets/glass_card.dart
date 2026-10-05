import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme.dart';
import 'travel_widgets.dart';

/// Primary green button — full-width, rounded corners, micro-interaction
class CGButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      constraints: BoxConstraints(minHeight: height),
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: OneUIColors.primaryLight,
                side: const BorderSide(
                  color: OneUIColors.primaryLight,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _buildChild(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: OneUIColors.primaryLight,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _buildChild(),
            ),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    }
    return Text(
      label,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}

/// Social sign-in button — white with thin gray border
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
          foregroundColor: OneUIColors.textPrimaryLight,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
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
    final activeBg = widget.activeColor ?? OneUIColors.primaryLight;
    final inactiveBg = widget.inactiveColor ?? OneUIColors.surfaceVariantLight;

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
                  : OneUIColors.textSecondaryLight,
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
          color: color ?? OneUIColors.surfaceLight,
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
          color: OneUIColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                _buildImage(),
                if (badge != null) Positioned(top: 10, left: 10, child: badge!),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: OneUIColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: OneUIColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (price != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      price!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: OneUIColors.primaryLight,
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

  Widget _buildImage() {
    final imageWidget = Container(
      height: imageHeight,
      width: double.infinity,
      color: OneUIColors.surfaceVariantLight,
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
        color: OneUIColors.surfaceVariantLight,
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: OneUIColors.textPrimaryLight,
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
              ? OneUIColors.textPrimaryLight
              : OneUIColors.textHintLight,
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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [OneUIColors.primaryLight, Color(0xFF2A8F63)],
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OneUIColors.textPrimaryLight,
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
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: OneUIColors.primaryLight,
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [OneUIColors.primaryVariantLight, OneUIColors.primaryLight],
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
            color: _isFavorited ? Colors.red : OneUIColors.textSecondaryLight,
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
              Container(color: OneUIColors.backgroundLight),
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
      style: const TextStyle(color: OneUIColors.textPrimaryLight, fontSize: 15),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: OneUIColors.textHintLight,
          fontSize: 15,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: OneUIColors.textSecondaryLight, size: 20)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: OneUIColors.inputFillLight,
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
          borderSide: const BorderSide(
            color: OneUIColors.primaryLight,
            width: 1.5,
          ),
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
