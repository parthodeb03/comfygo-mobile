import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// One UI Status Chip
class OneUIStatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const OneUIStatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: OneUISpacing.animFast,
        padding: const EdgeInsets.symmetric(
          horizontal: OneUISpacing.md,
          vertical: OneUISpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(OneUISpacing.radiusRound),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: OneUISpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One UI Category Chip
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: OneUISpacing.animFast,
        padding: const EdgeInsets.symmetric(
          horizontal: OneUISpacing.lg,
          vertical: OneUISpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(OneUISpacing.radiusRound),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
              ),
              const SizedBox(width: OneUISpacing.xs),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One UI Booking Status Chip
class OneUIBookingStatusChip extends StatelessWidget {
  final String status;

  const OneUIBookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'pending':
        color = OneUIColors.statusPending;
        icon = Icons.schedule_rounded;
        label = 'Pending';
        break;
      case 'confirmed':
        color = OneUIColors.statusConfirmed;
        icon = Icons.check_circle_rounded;
        label = 'Confirmed';
        break;
      case 'cancelled':
        color = OneUIColors.statusCancelled;
        icon = Icons.cancel_rounded;
        label = 'Cancelled';
        break;
      case 'completed':
        color = OneUIColors.statusCompleted;
        icon = Icons.done_all_rounded;
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_rounded;
        label = status;
    }

    return OneUIStatusChip(label: label, color: color, icon: icon);
  }
}

/// One UI Package Tier Chip
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
    Color color;
    String label;

    switch (tier.toLowerCase()) {
      case 'basic':
        color = OneUIColors.tierBasic;
        label = 'Basic';
        break;
      case 'pro':
        color = OneUIColors.tierPro;
        label = 'Pro';
        break;
      case 'premium':
        color = OneUIColors.tierPremium;
        label = 'Premium';
        break;
      case 'ultimate':
        color = OneUIColors.tierUltimate;
        label = 'Ultimate';
        break;
      default:
        color = Colors.grey;
        label = tier;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: OneUISpacing.animFast,
        padding: const EdgeInsets.symmetric(
          horizontal: OneUISpacing.lg,
          vertical: OneUISpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(OneUISpacing.radiusRound),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
