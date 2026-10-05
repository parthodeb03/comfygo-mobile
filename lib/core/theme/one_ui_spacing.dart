/// Samsung One UI Spacing & Dimension Constants
/// Matches Samsung's generous padding and touch target sizes
class OneUISpacing {
  OneUISpacing._();

  // ═══════════════════════════════════════════════════
  // SPACING SCALE (8px base grid)
  // ═══════════════════════════════════════════════════
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  // ═══════════════════════════════════════════════════
  // BORDER RADIUS - One UI generous radii
  // ═══════════════════════════════════════════════════
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusRound = 100;

  // ═══════════════════════════════════════════════════
  // TOUCH TARGETS - Minimum 48dp per One UI
  // ═══════════════════════════════════════════════════
  static const double touchTargetMin = 48;
  static const double touchTargetComfortable = 56;
  static const double touchTargetLarge = 64;

  // ═══════════════════════════════════════════════════
  // ELEVATION / SHADOW
  // ═══════════════════════════════════════════════════
  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMedium = 4;
  static const double elevationHigh = 8;

  // ═══════════════════════════════════════════════════
  // PAGE PADDING
  // ═══════════════════════════════════════════════════
  static const double pageHorizontal = 16;
  static const double pageVertical = 24;

  // ═══════════════════════════════════════════════════
  // APP BAR HEIGHT
  // ═══════════════════════════════════════════════════
  static const double appBarHeight = 56;
  static const double bottomNavHeight = 64;

  // ═══════════════════════════════════════════════════
  // CARD DIMENSIONS
  // ═══════════════════════════════════════════════════
  static const double cardMinHeight = 80;
  static const double cardImageHeight = 200;
  static const double cardThumbnailSize = 56;

  // ═══════════════════════════════════════════════════
  // LIST ITEM HEIGHTS
  // ═══════════════════════════════════════════════════
  static const double listItemCompact = 48;
  static const double listItemStandard = 56;
  static const double listItemComfortable = 64;
  static const double listItemExpanded = 72;

  // ═══════════════════════════════════════════════════
  // AVATAR / ICON SIZES
  // ═══════════════════════════════════════════════════
  static const double iconSm = 16;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;
  static const double avatarXl = 80;

  // ═══════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 250);
  static const Duration animSlow = Duration(milliseconds: 400);
  static const Duration animVerySlow = Duration(milliseconds: 600);
}
