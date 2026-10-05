import 'package:flutter/material.dart';

import '../theme/theme.dart';

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
    final theme = Theme.of(context);
    final primary =
        type == OneUIButtonType.primary || type == OneUIButtonType.danger;
    final color = type == OneUIButtonType.danger
        ? OneUIColors.error
        : theme.colorScheme.primary;
    return SizedBox(
      width: isExpanded ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          backgroundColor: primary ? color : Colors.transparent,
          foregroundColor: primary ? Colors.white : color,
          shadowColor: Colors.transparent,
          side: type == OneUIButtonType.secondary
              ? BorderSide(color: color)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: Text(text, textAlign: TextAlign.center)),
                ],
              ),
      ),
    );
  }
}

enum OneUIButtonType { primary, secondary, text, danger }
