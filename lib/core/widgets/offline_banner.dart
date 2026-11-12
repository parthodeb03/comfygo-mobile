import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/design_tokens.dart';

/// Non-blocking offline notice shown under the status bar.
///
/// Uses the amber status pair, keeps the retry action at 48dp, and announces
/// itself to screen readers.
class OfflineBanner extends StatelessWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  final VoidCallback onRetry;
  final String title;
  final String message;

  const OfflineBanner({
    super.key,
    required this.onRetry,
    this.title = 'You are offline',
    this.message = 'Showing saved content. Retry when the connection returns.',
  });

  @override
  Widget build(BuildContext context) {
    final pair = AppColors.statusColors(context, 'pending');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ComfySpacing.lg,
        vertical: ComfySpacing.sm,
      ),
      child: Semantics(
        liveRegion: true,
        label: '$title. $message',
        child: Material(
          color: pair.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ComfyRadii.md),
            side: BorderSide(color: pair.foreground.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ComfySpacing.md,
              vertical: ComfySpacing.sm,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  color: pair.foreground,
                  size: ComfySpacing.xl,
                ),
                const SizedBox(width: ComfySpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: ComfyType.label.copyWith(color: pair.foreground),
                      ),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ComfyType.caption.copyWith(
                          color: pair.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: ComfySpacing.sm),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                    foregroundColor: pair.foreground,
                    minimumSize: const Size(48, 48),
                    textStyle: ComfyType.label.copyWith(color: pair.foreground),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
