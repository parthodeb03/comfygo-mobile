// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Folders, theme, routes and reusable widgets from the Phase 1 plan.

import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

class OneUIButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final OneUIButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final double? width;
  final double? height;

  const OneUIButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = OneUIButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDanger = type == OneUIButtonType.danger;
    final isPrimary = type == OneUIButtonType.primary || isDanger;
    final background = isDanger ? scheme.error : scheme.primary;
    final foreground = isDanger ? scheme.onError : scheme.onPrimary;
    final accent = isDanger ? scheme.error : scheme.primary;

    final isText = type == OneUIButtonType.text;
    final isSecondary = type == OneUIButtonType.secondary;

    final buttonStyle = isText
        ? TextButton.styleFrom(
            foregroundColor: accent,
            minimumSize: const Size(
              OneUISpacingTokens.touchMin,
              OneUISpacingTokens.buttonHeight,
            ),
            textStyle: ComfyType.button,
            shape: const StadiumBorder(),
          )
        : isSecondary
        ? OutlinedButton.styleFrom(
            foregroundColor: accent,
            minimumSize: const Size(
              OneUISpacingTokens.touchMin,
              OneUISpacingTokens.buttonHeight,
            ),
            side: BorderSide(color: scheme.outline),
            textStyle: ComfyType.button,
            shape: const StadiumBorder(),
          )
        : FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: foreground,
            minimumSize: const Size(
              OneUISpacingTokens.touchMin,
              OneUISpacingTokens.buttonHeight,
            ),
            textStyle: ComfyType.button.copyWith(color: foreground),
            shape: const StadiumBorder(),
            elevation: 0,
          );

    final child = isLoading
        ? SizedBox(
            width: ComfySpacing.xl,
            height: ComfySpacing.xl,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isPrimary ? foreground : accent,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: ComfySpacing.xl),
                const SizedBox(width: ComfySpacing.sm),
              ],
              Flexible(child: Text(text, textAlign: TextAlign.center)),
            ],
          );

    final effectiveOnPressed = isLoading ? null : onPressed;
    final button = isText
        ? TextButton(
            onPressed: effectiveOnPressed,
            style: buttonStyle,
            child: child,
          )
        : isSecondary
        ? OutlinedButton(
            onPressed: effectiveOnPressed,
            style: buttonStyle,
            child: child,
          )
        : FilledButton(
            onPressed: effectiveOnPressed,
            style: buttonStyle,
            child: child,
          );

    return SizedBox(
      width: isExpanded ? double.infinity : width,
      height: height,
      child: button,
    );
  }
}

enum OneUIButtonType { primary, secondary, text, danger }

/// Local sizing aliases for this file only.
abstract final class OneUISpacingTokens {
  static const double touchMin = 48;
  static const double buttonHeight = 52;
}
