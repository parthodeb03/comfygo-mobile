import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// One UI Collapsing Large Title App Bar
/// Matches Samsung's signature big-to-small title transition on scroll
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
    final isDark = theme.brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor:
          backgroundColor ??
          (isDark ? OneUIColors.backgroundDark : OneUIColors.backgroundLight),
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: OneUISpacing.lg,
          bottom: OneUISpacing.lg,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark
                ? OneUIColors.textPrimaryDark
                : OneUIColors.textPrimaryLight,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          padding: EdgeInsets.only(
            left: OneUISpacing.lg,
            right: OneUISpacing.lg,
            top:
                kToolbarHeight +
                MediaQuery.of(context).padding.top +
                OneUISpacing.lg,
          ),
          alignment: Alignment.bottomLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark
                      ? OneUIColors.textPrimaryDark
                      : OneUIColors.textPrimaryLight,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: OneUISpacing.xs),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: isDark
                        ? OneUIColors.textSecondaryDark
                        : OneUIColors.textSecondaryLight,
                    fontSize: 14,
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

/// One UI Simple AppBar (non-collapsing)
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
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor:
          backgroundColor ??
          (isDark ? OneUIColors.backgroundDark : OneUIColors.backgroundLight),
      foregroundColor: isDark
          ? OneUIColors.textPrimaryDark
          : OneUIColors.textPrimaryLight,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      title: Text(
        title,
        style: TextStyle(
          color: isDark
              ? OneUIColors.textPrimaryDark
              : OneUIColors.textPrimaryLight,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
    );
  }
}

/// One UI Search Bar
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
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: OneUISpacing.lg,
        vertical: OneUISpacing.sm,
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        style: TextStyle(
          color: isDark
              ? OneUIColors.textPrimaryDark
              : OneUIColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: isDark
                ? OneUIColors.textHintDark
                : OneUIColors.textHintLight,
          ),
          prefixIcon:
              prefix ??
              Icon(
                Icons.search_rounded,
                color: isDark
                    ? OneUIColors.textSecondaryDark
                    : OneUIColors.textSecondaryLight,
              ),
          suffixIcon: suffix,
          filled: true,
          fillColor: isDark
              ? OneUIColors.surfaceVariantDark
              : OneUIColors.surfaceVariantLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(OneUISpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(OneUISpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(OneUISpacing.radiusMd),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: OneUISpacing.lg,
            vertical: OneUISpacing.md,
          ),
        ),
      ),
    );
  }
}
