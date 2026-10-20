import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Compact badge/chip with a semantic foreground and optional explicit fill.
class OneUIStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const OneUIStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background =
        backgroundColor ?? color.withValues(alpha: isSelected ? 0.18 : 0.10);
    final border = color.withValues(alpha: isSelected ? 1 : 0.35);
    final shape = StadiumBorder(
      side: BorderSide(color: border, width: isSelected ? 2 : 1),
    );

    return Semantics(
      button: onTap != null,
      label: label,
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ComfySpacing.md,
                vertical: ComfySpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: ComfySpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: ComfyType.label.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Selectable category pill used on Home and list screens.
class OneUICategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const OneUICategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = isSelected ? scheme.onPrimary : scheme.onSurface;
    final background = isSelected
        ? scheme.primary
        : scheme.surfaceContainerHighest;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: background,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ComfySpacing.md,
                vertical: ComfySpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: foreground),
                    const SizedBox(width: ComfySpacing.xs),
                  ],
                  Text(
                    label,
                    style: ComfyType.label.copyWith(color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Booking status: colour + icon + text, never colour alone.
class OneUIBookingStatusChip extends StatelessWidget {
  final String status;

  const OneUIBookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final pair = AppColors.statusColors(context, status);
    final IconData icon;
    switch (status.toLowerCase()) {
      case 'confirmed':
        icon = Icons.check_circle_rounded;
        break;
      case 'cancelled':
        icon = Icons.cancel_rounded;
        break;
      case 'completed':
        icon = Icons.done_all_rounded;
        break;
      case 'pending':
      default:
        icon = Icons.schedule_rounded;
    }

    return OneUIStatusChip(
      label: _labelFor(status),
      color: pair.foreground,
      backgroundColor: pair.background,
      icon: icon,
    );
  }

  String _labelFor(String value) {
    switch (value.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      default:
        return value;
    }
  }
}

/// Package tier badge (Basic / Pro / Premium / Ultimate).
class OneUIPackageChip extends StatelessWidget {
  final String tier;
  final bool isSelected;
  final VoidCallback? onTap;

  const OneUIPackageChip({
    super.key,
    required this.tier,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pair = AppColors.tierColors(context, tier);
    final label = tier.isEmpty
        ? ''
        : '${tier[0].toUpperCase()}${tier.substring(1).toLowerCase()}';

    return Semantics(
      button: onTap != null,
      selected: isSelected,
      label: label,
      child: Material(
        color: pair.background,
        shape: StadiumBorder(
          side: BorderSide(
            color: isSelected ? pair.foreground : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ComfySpacing.md,
                vertical: ComfySpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 18,
                    color: pair.foreground,
                  ),
                  const SizedBox(width: ComfySpacing.xs),
                  Text(
                    label,
                    style: ComfyType.label.copyWith(color: pair.foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
