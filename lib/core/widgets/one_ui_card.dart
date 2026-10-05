import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// One UI styled card with elevation and rounded corners
class OneUICard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final double borderRadius;

  const OneUICard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.borderRadius = OneUISpacing.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: OneUISpacing.animNormal,
      margin:
          margin ??
          const EdgeInsets.symmetric(
            horizontal: OneUISpacing.pageHorizontal,
            vertical: OneUISpacing.sm,
          ),
      child: Material(
        color: backgroundColor ?? theme.cardTheme.color,
        elevation: elevation ?? 1,
        shadowColor: theme.cardTheme.shadowColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(OneUISpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// One UI Image Card - for destinations, hotels, etc.
class OneUIImageCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double? height;
  final bool isNetworkImage;

  const OneUIImageCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.height = 200,
    this.isNetworkImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: OneUISpacing.animNormal,
      margin: const EdgeInsets.symmetric(
        horizontal: OneUISpacing.pageHorizontal,
        vertical: OneUISpacing.sm,
      ),
      child: Material(
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(OneUISpacing.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(OneUISpacing.radiusLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(OneUISpacing.radiusLg),
                ),
                child: Container(
                  height: height,
                  width: double.infinity,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: imageUrl != null
                      ? isNetworkImage
                            ? Image.network(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder(context);
                                },
                              )
                            : Image.asset(
                                imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder(context);
                                },
                              )
                      : _buildPlaceholder(context),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(OneUISpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: OneUISpacing.xs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (trailing != null) ...[
                      const SizedBox(height: OneUISpacing.sm),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 48,
        color: Theme.of(context).colorScheme.outline,
      ),
    );
  }
}

/// One UI List Card - for settings-style lists
class OneUIListCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;

  const OneUIListCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.cardTheme.color,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              padding ??
              const EdgeInsets.symmetric(
                horizontal: OneUISpacing.lg,
                vertical: OneUISpacing.md,
              ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: OneUISpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}
