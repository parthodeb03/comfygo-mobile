import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// Responsive breakpoints (Material 3 window size classes)
/// ─────────────────────────────────────────────────────────────
class Breakpoints {
  Breakpoints._();

  /// Phones (portrait) — single column layouts
  static const double compact = 600;

  /// Small tablets / landscape phones — 2 column layouts
  static const double medium = 840;

  /// Tablets / small desktops — 3 column layouts
  static const double expanded = 1200;
}

/// ─────────────────────────────────────────────────────────────
/// Responsive extensions on BuildContext
/// ─────────────────────────────────────────────────────────────
extension ResponsiveContext on BuildContext {
  /// Shortest-side media query width (window width on phones/tablets)
  double get mediaWidth => MediaQuery.sizeOf(this).width;

  /// Compact window (phone portrait)
  bool get isCompact => mediaWidth < Breakpoints.compact;

  /// Medium window (tablet portrait / large phone landscape)
  bool get isMedium =>
      mediaWidth >= Breakpoints.compact && mediaWidth < Breakpoints.medium;

  /// Expanded window (tablet landscape / desktop)
  bool get isExpanded => mediaWidth >= Breakpoints.medium;

  /// Phone-sized window (compact OR medium)
  bool get isPhone => mediaWidth < Breakpoints.medium;

  /// Content max width for centered layouts on wide screens
  double get contentMaxWidth => mediaWidth > 1200 ? 1100 : double.infinity;

  /// Adaptive page horizontal padding — wider on large screens
  double get pagePadding {
    final w = mediaWidth;
    if (w >= Breakpoints.medium) return 32;
    if (w >= Breakpoints.compact) return 24;
    return 16;
  }

  /// Horizontal centered content padding constrained to max width
  EdgeInsets get contentPadding => EdgeInsets.symmetric(
    horizontal: mediaWidth > 1200 ? (mediaWidth - 1100) / 2 : pagePadding,
  );

  /// Number of columns for card grids based on available width
  int gridColumns({double minTileWidth = 320, double? maxWidth}) {
    final w = (maxWidth ?? mediaWidth) - contentPadding.horizontal;
    final cols = (w / minTileWidth).floor().clamp(1, 4);
    return cols;
  }
}

/// ─────────────────────────────────────────────────────────────
/// Adaptive grid delegate for card grids
/// ─────────────────────────────────────────────────────────────
SliverGridDelegateWithFixedCrossAxisCount adaptiveGridDelegate(
  BuildContext context, {
  double minTileWidth = 320,
  double mainAxisExtent = 300,
  double childAspectRatio = 0.72,
  double crossAxisSpacing = 16,
  double mainAxisSpacing = 16,
}) {
  final cols = context.gridColumns(minTileWidth: minTileWidth);
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: cols,
    mainAxisExtent: mainAxisExtent,
    crossAxisSpacing: crossAxisSpacing,
    mainAxisSpacing: mainAxisSpacing,
  );
}

/// ─────────────────────────────────────────────────────────────
/// Responsive section header with optional action
/// ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = context.mediaWidth >= Breakpoints.compact;
    final titleStyle = isWide
        ? theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)
        : theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700);

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: context.pagePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: titleStyle),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
