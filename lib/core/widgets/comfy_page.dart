import 'package:flutter/material.dart';

import '../theme/comfy_design.dart';
import 'comfy_ui.dart';

/// Standard page chrome: gradient background + safe area + optional bottom bar.
class CgPageScaffold extends StatelessWidget {
  const CgPageScaffold({super.key, required this.child, this.bottom});

  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: CgBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(child: child),
              ?bottom,
            ],
          ),
        ),
      ),
    );
  }
}

/// Page title row with an optional round back button and trailing action.
class CgPageTitle extends StatelessWidget {
  const CgPageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 20, 20, 0),
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (onBack != null) ...[
            CgRoundButton(
              icon: Icons.arrow_back_ios_new_rounded,
              iconSize: 18,
              semanticLabel: 'Back',
              onTap: onBack,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: CgType.pageTitle.copyWith(color: c.text)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: CgType.b14.copyWith(color: c.text2)),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}

/// Section heading with an optional trailing action.
class CgSection extends StatelessWidget {
  const CgSection({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: CgType.t16.copyWith(fontSize: 18, color: c.text),
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: const Size(0, 40),
              foregroundColor: c.primary,
            ),
            child: Text(
              actionLabel!,
              style: CgType.b14.copyWith(
                fontWeight: FontWeight.w700,
                color: c.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Card row with a mint icon badge, title, subtitle and trailing slot.
class CgTile extends StatelessWidget {
  const CgTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.trailingText,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final badge = leading ?? Icon(icon ?? Icons.circle_outlined, size: 20);
    final content = CgCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: c.gMint,
              shape: BoxShape.circle,
            ),
            child: IconTheme(
              data: IconThemeData(color: iconColor ?? c.primary, size: 20),
              child: badge,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CgType.t16.copyWith(color: c.text),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.l12.copyWith(color: c.text2),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (trailingText != null)
            CgTextPill(label: trailingText!)
          else
            trailing ??
                Icon(Icons.chevron_right_rounded, size: 20, color: c.text2),
        ],
      ),
    );
    if (onTap == null) return content;
    return CgPressable(onTap: onTap, child: content);
  }
}

/// Small mint pill used for statuses and short metadata.
class CgTextPill extends StatelessWidget {
  const CgTextPill({
    super.key,
    required this.label,
    this.background,
    this.foreground,
    this.icon,
  });

  final String label;
  final Color? background;
  final Color? foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? c.mint,
        borderRadius: BorderRadius.circular(CgRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground ?? c.primary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CgType.l12.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: foreground ?? c.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Underline tab row used by overview/detail/review sections.
class CgUnderlineTabs extends StatelessWidget {
  const CgUnderlineTabs({
    super.key,
    required this.tabs,
    required this.value,
    required this.onChanged,
  });

  final List<String> tabs;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(height: 1, color: c.line),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final tab in tabs)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(tab),
                    child: IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tab,
                              style: CgType.b14.copyWith(
                                fontWeight: FontWeight.w600,
                                color: value == tab ? c.text : c.text2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 2,
                              decoration: BoxDecoration(
                                color: value == tab
                                    ? c.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Card-style outlined secondary button (same height/radius as the pill).
class CgOutlineButton extends StatelessWidget {
  const CgOutlineButton({
    super.key,
    required this.child,
    this.onTap,
    this.width,
    this.height = 56,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPressable(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(CgRadii.pill),
          border: Border.all(color: c.line, width: 1.5),
        ),
        child: DefaultTextStyle.merge(
          style: CgType.button.copyWith(color: c.text),
          child: child,
        ),
      ),
    );
  }
}

/// Consistent empty state.
class CgEmptyState extends StatelessWidget {
  const CgEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.travel_explore_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: c.gMint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: c.primary),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: CgType.b14.copyWith(color: c.text2),
          ),
        ],
      ),
    );
  }
}

/// Consistent loading state.
class CgLoadingState extends StatelessWidget {
  const CgLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Center(
        child: CircularProgressIndicator(color: CgColors.of(context).primary),
      ),
    );
  }
}

/// Consistent error state with a retry action.
class CgErrorState extends StatelessWidget {
  const CgErrorState({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: CgType.b14.copyWith(color: c.text2),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 44),
                foregroundColor: c.primary,
              ),
              child: Text(
                'Retry',
                style: CgType.b14.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Label on the left, value on the right, separated by a divider.
class CgInfoRow extends StatelessWidget {
  const CgInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: showDivider
          ? BoxDecoration(
              border: Border(bottom: BorderSide(color: c.line)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: CgType.b14.copyWith(color: c.text2)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: CgType.t16.copyWith(
                fontSize: 15,
                color: valueColor ?? c.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small square badge button used inside cards (favourite, edit, delete).
class CgIconAction extends StatelessWidget {
  const CgIconAction({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Semantics(
      button: true,
      label: semanticLabel,
      child: CgPressable(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: c.gMint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 18, color: color ?? c.primary),
        ),
      ),
    );
  }
}
