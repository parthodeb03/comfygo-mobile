import 'design_tokens.dart';

/// Spacing, shape and motion names used across the app.
///
/// Values live only in `design_tokens.dart`. The legacy names are preserved so
/// existing widgets keep compiling while they migrate.
class OneUISpacing {
  OneUISpacing._();

  // Spacing scale (4pt grid)
  static const double xxs = ComfySpacing.xxs;
  static const double xs = ComfySpacing.xs;
  static const double sm = ComfySpacing.sm;
  static const double md = ComfySpacing.md;
  static const double lg = ComfySpacing.lg;
  static const double xl = ComfySpacing.xl;
  static const double xxl = ComfySpacing.xxl;
  static const double xxxl = ComfySpacing.xxxl;
  static const double xxxxl = ComfySpacing.xxxxl;
  static const double huge = ComfySpacing.huge;
  static const double massive = ComfySpacing.massive;

  // Radii
  static const double radiusSm = ComfyRadii.sm;
  static const double radiusInput = ComfyRadii.input;
  static const double radiusMd = ComfyRadii.md;
  static const double radiusLg = ComfyRadii.lg;
  static const double radiusCard = ComfyRadii.card;
  static const double radiusXl = ComfyRadii.xl;
  static const double radiusXxl = ComfyRadii.xxl;
  static const double radiusSheet = ComfyRadii.sheet;
  static const double radiusRound = ComfyRadii.pill;

  // Touch targets
  static const double touchTargetMin = 48;
  static const double touchTargetComfortable = 56;
  static const double touchTargetLarge = 64;

  // Elevation
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;

  // Page padding
  static const double pageCompact = ComfySpacing.pageCompact;
  static const double pageMedium = ComfySpacing.pageMedium;
  static const double pageExpanded = ComfySpacing.pageExpanded;
  static const double pageHorizontal = ComfySpacing.pageCompact;
  static const double pageVertical = ComfySpacing.xxl;

  // Chrome
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 80;

  // Cards
  static const double cardMinHeight = 80;
  static const double cardImageHeight = 200;
  static const double cardThumbnailSize = 56;

  // Lists
  static const double listItemCompact = 48;
  static const double listItemStandard = 56;
  static const double listItemComfortable = 64;
  static const double listItemExpanded = 72;

  // Icons/avatars
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 80;

  // Motion
  static const Duration animFast = ComfyDurations.fast;
  static const Duration animNormal = ComfyDurations.base;
  static const Duration animSlow = ComfyDurations.slow;
  static const Duration animVerySlow = ComfyDurations.verySlow;
}
