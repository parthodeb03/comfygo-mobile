// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Folders, theme, routes and reusable widgets from the Phase 1 plan.

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Collapsing large-title app bar for detail screens.
class OneUILargeTitleAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final double expandedHeight;
  final bool centerTitle;

  const OneUILargeTitleAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.bottom,
    this.backgroundColor,
    this.expandedHeight = 120,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? scheme.surface,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: ComfySpacing.xl),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: ComfySpacing.lg,
          bottom: ComfySpacing.lg,
        ),
        title: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        background: Container(
          padding: EdgeInsets.only(
            left: ComfySpacing.lg,
            right: ComfySpacing.lg,
            top:
                kToolbarHeight +
                MediaQuery.of(context).padding.top +
                ComfySpacing.lg,
          ),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: ComfySpacing.xs),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Non-collapsing app bar.
class OneUISimpleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final bool centerTitle;

  const OneUISimpleAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.onBackPressed,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: ComfySpacing.xl),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              tooltip: 'Back',
            )
          : leading,
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(color: scheme.onSurface),
      ),
      actions: actions,
    );
  }
}

/// Search field used by list screens.
class OneUISearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;

  const OneUISearchBar({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ComfySpacing.lg,
        vertical: ComfySpacing.sm,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon:
              prefix ??
              Icon(Icons.search_rounded, color: scheme.onSurfaceVariant),
          suffixIcon: suffix,
          filled: true,
          fillColor: scheme.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: ComfySpacing.lg,
            vertical: ComfySpacing.md,
          ),
        ),
      ),
    );
  }
}
