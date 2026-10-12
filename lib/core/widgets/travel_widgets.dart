import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../theme/app_colors.dart';
import '../utils/navigation.dart';
import 'nature_background.dart';

/// Unique photography for each section of the app
abstract final class TravelPhotos {
  // Home & General
  static const String home = 'assets/images/bg_home.jfif';
  static const String login = 'assets/images/bg_login.jfif';

  // Destinations
  static const String explore = 'assets/images/bg_explore.jfif';
  static const String bandarban = 'assets/images/bg_bandarban.jfif';
  static const String sundarbans = 'assets/images/bg_sundarbans.jpg';
  static const String coxsBazar = 'assets/images/bg_coxs_bazar.jpg';
  static const String sylhet = 'assets/images/bg_sylhet.jpg';
  static const String dhaka = 'assets/images/bg_dhaka.jpg';

  // Hotels
  static const String hotels = 'assets/images/bg_hotels.jpg';

  // List screens backdrop (photo from the project photos/ folder)
  static const String listGreen = 'assets/images/bg_list_green.jpg';

  // Transport
  static const String transport = journey;

  // Guides
  static const String guides = 'assets/images/bg_guides.jpg';

  // Bookings
  static const String bookings = 'assets/images/bg_bookings.jpg';

  // Forest & Nature
  static const String forest = 'assets/images/bg_forest.jfif';

  // Journey
  static const String journey = 'assets/images/bg_thanchi.jfif';

  // ───────────────────────────────────────────────────────────
  // DIVISION PHOTOS — real photography, one per division
  // ───────────────────────────────────────────────────────────
  static const String divDhaka = 'assets/images/divisions/dhaka.jpg';
  static const String divChittagong = 'assets/images/divisions/chittagong.jpg';
  static const String divSylhet = 'assets/images/divisions/sylhet.jpg';
  static const String divRajshahi = 'assets/images/divisions/rajshahi.jpg';
  static const String divKhulna = 'assets/images/divisions/khulna.jpg';
  static const String divBarisal = 'assets/images/divisions/barisal.jpg';
  static const String divRangpur = 'assets/images/divisions/rangpur.jpg';
  static const String divMymensingh = 'assets/images/divisions/mymensingh.jpg';

  // ───────────────────────────────────────────────────────────
  // SPOT PHOTOS — real photography, one per tourist spot
  // ───────────────────────────────────────────────────────────
  static const String spotCoxsBazar = 'assets/images/spots/coxs_bazar.jpg';
  static const String spotSundarbans = 'assets/images/spots/sundarbans.jpg';
  static const String spotBandarban = 'assets/images/spots/bandarban.jpg';
  static const String spotNilgiri = 'assets/images/spots/nilgiri.jpg';
  static const String spotSrimangal = 'assets/images/spots/srimangal.jpg';
  static const String spotJaflong = 'assets/images/spots/jaflong.jpg';
  static const String spotRatargul = 'assets/images/spots/ratargul.jpg';
  static const String spotAhsanManzil = 'assets/images/spots/ahsan_manzil.jpg';
  static const String spotLalbagh = 'assets/images/spots/lalbagh.jpg';
  static const String spotParliament = 'assets/images/spots/parliament.jpg';
  static const String spotSonargaon = 'assets/images/spots/sonargaon.jpg';
  static const String spotPaharpur = 'assets/images/spots/paharpur.jpg';
  static const String spotKantanagar = 'assets/images/spots/kantanagar.jpg';
  static const String spotBagerhat = 'assets/images/spots/bagerhat.jpg';
  static const String spotKuakata = 'assets/images/spots/kuakata.jpg';
  static const String spotKaptai = 'assets/images/spots/kaptai.jpg';
  static const String spotPatenga = 'assets/images/spots/patenga.jpg';
  static const String spotSajek = 'assets/images/spots/sajek.jpg';
  static const String spotTajhat = 'assets/images/spots/tajhat.jpg';
  static const String spotBagha = 'assets/images/spots/bagha.jpg';
  static const String spotRajbari =
      'assets/images/spots/mymensingh_rajbari.jpg';
  static const String spotSaintMartin = 'assets/images/spots/saint_martin.jpg';

  /// Division name (as stored in data) -> photo asset.
  static const Map<String, String> divisionPhotos = {
    'dhaka': divDhaka,
    'chittagong': divChittagong,
    'chattogram': divChittagong,
    'sylhet': divSylhet,
    'rajshahi': divRajshahi,
    'khulna': divKhulna,
    'barisal': divBarisal,
    'barishal': divBarisal,
    'rangpur': divRangpur,
    'mymensingh': divMymensingh,
  };

  /// Spot keyword -> photo asset. Checked in order, so put the most
  /// specific keywords first.
  static const List<MapEntry<String, String>> spotPhotos = [
    MapEntry('sundarban', spotSundarbans),
    MapEntry('mangrove', spotSundarbans),
    MapEntry('st. martin', spotSaintMartin),
    MapEntry('st martin', spotSaintMartin),
    MapEntry('saint martin', spotSaintMartin),
    MapEntry('cox', spotCoxsBazar),
    MapEntry('nilgiri', spotNilgiri),
    MapEntry('thanchi', spotNilgiri),
    MapEntry('bandarban', spotBandarban),
    MapEntry('sajek', spotSajek),
    MapEntry('rangamati', spotKaptai),
    MapEntry('kaptai', spotKaptai),
    MapEntry('patenga', spotPatenga),
    MapEntry('srimangal', spotSrimangal),
    MapEntry('srimongol', spotSrimangal),
    MapEntry('tea', spotSrimangal),
    MapEntry('jaflong', spotJaflong),
    MapEntry('ratargul', spotRatargul),
    MapEntry('ahsan', spotAhsanManzil),
    MapEntry('pink palace', spotAhsanManzil),
    MapEntry('lalbagh', spotLalbagh),
    MapEntry('sangsad', spotParliament),
    MapEntry('parliament', spotParliament),
    MapEntry('sonargaon', spotSonargaon),
    MapEntry('panam', spotSonargaon),
    MapEntry('paharpur', spotPaharpur),
    MapEntry('somapura', spotPaharpur),
    MapEntry('kantanagar', spotKantanagar),
    MapEntry('bagerhat', spotBagerhat),
    MapEntry('sixty dome', spotBagerhat),
    MapEntry('shat gombuj', spotBagerhat),
    MapEntry('kuakata', spotKuakata),
    MapEntry('bagha', spotBagha),
    MapEntry('tajhat', spotTajhat),
    MapEntry('rajbari', spotRajbari),
    MapEntry('island', spotSaintMartin),
    MapEntry('forest', spotRatargul),
    MapEntry('hill', spotBandarban),
    MapEntry('beach', spotCoxsBazar),
    MapEntry('sea', spotCoxsBazar),
  ];

  /// Photo for a division name ("Dhaka", "Chittagong", "Barisal", ...).
  static String forDivision(String? division) {
    if (division == null || division.trim().isEmpty) return explore;
    final key = division.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z ]'),
      '',
    );
    return divisionPhotos[key] ??
        divisionPhotos[key.split(' ').first] ??
        explore;
  }

  /// Get the best photo for a destination: spot first, then division.
  static String forDestination(String name, [String? division]) {
    final lower = name.toLowerCase();
    for (final entry in spotPhotos) {
      if (lower.contains(entry.key)) return entry.value;
    }
    final fromDivision = forDivision(division);
    if (fromDivision != explore) return fromDivision;
    for (final entry in divisionPhotos.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    if (lower.contains('journey') || lower.contains('road')) return journey;
    return explore;
  }
}

class TravelPhoto extends StatelessWidget {
  final String? url;
  final String asset;
  final String? label;
  const TravelPhoto({
    super.key,
    this.url,
    this.asset = TravelPhotos.explore,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    Widget fallback() => Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: label ?? 'Bangladesh travel scenery',
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFFD9E6D2),
        child: Center(
          child: Icon(
            Icons.landscape_rounded,
            color: Color(0xFF707266),
            size: 40,
          ),
        ),
      ),
    );
    final source = url?.trim();
    if (source == null || source.isEmpty) return fallback();
    return CachedNetworkImage(
      imageUrl: source,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      imageBuilder: (context, provider) => Image(
        image: provider,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        semanticLabel: label,
      ),
      placeholder: (context, _) => Shimmer.fromColors(
        baseColor: const Color(0xFFE6E3D7),
        highlightColor: const Color(0xFFF5F2E9),
        child: const SizedBox.expand(child: ColoredBox(color: Colors.white)),
      ),
      errorWidget: (context, _, _) => fallback(),
    );
  }
}

/// Constrains reading width and reports actual content width, including beside a rail.
class TravelScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final double maxContentWidth;

  /// When set, a photo + gradient backdrop replaces the plain nature wash.
  final String? photoBackground;
  const TravelScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.maxContentWidth = 1200,
    this.photoBackground,
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: backgroundColor,
    appBar: appBar,
    bottomNavigationBar: bottomNavigationBar,
    body: SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(constraints.maxWidth, maxContentWidth);
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: width,
              height: constraints.maxHeight,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(width, MediaQuery.sizeOf(context).height),
                ),
                child: photoBackground == null
                    ? NatureBackground.wrap(child: body)
                    : PhotoBackground.wrap(
                        child: body,
                        asset: photoBackground!,
                      ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

/// Natural-height cards avoid fixed grid ratios truncating larger text.
class TravelGrid extends StatelessWidget {
  final List<Widget> children;
  final double minWidth;
  final double spacing;
  const TravelGrid({
    super.key,
    required this.children,
    this.minWidth = 300,
    this.spacing = 20,
  });
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final columns =
          ((constraints.maxWidth + spacing) /
                  (minWidth * math.max(1, scale * .8) + spacing))
              .floor()
              .clamp(1, 4);
      final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
      return AnimationLimiter(
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (int i = 0; i < children.length; i++)
              SizedBox(
                width: width,
                child: AnimationConfiguration.staggeredList(
                  position: i,
                  duration: const Duration(milliseconds: 420),
                  child: SlideAnimation(
                    verticalOffset: 26.0,
                    child: FadeInAnimation(child: children[i]),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class TravelBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final String eyebrow;

  /// When false the banner renders as a solid nature-green card with no
  /// photo behind the copy.
  final bool showImage;
  const TravelBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.asset = TravelPhotos.home,
    this.eyebrow = 'COMFYGO / BANGLADESH',
    this.showImage = true,
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B5E43), Color(0xFF123F2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            if (showImage)
              Positioned.fill(child: TravelPhoto(asset: asset)),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xE61B5E43), Color(0x501B5E43)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(
              MediaQuery.sizeOf(context).width < 400 ? 22 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Color(0xFFFFDA79),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.sizeOf(context).width < 600
                          ? 30
                          : 42,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          ],
        ),
      ),
    ),
  );
}

class TravelHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final bool showBack;
  const TravelHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.asset = TravelPhotos.explore,
    this.showBack = true,
  });
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (showBack)
                  IconButton(
                    onPressed: () => goBack(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                  ),
                const Icon(
                  Icons.travel_explore_rounded,
                  color: Color(0xFF1F6E4D),
                ),
                const SizedBox(width: 8),
                Text(
                  'ComfyGo',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TravelBanner(title: title, subtitle: subtitle, asset: asset),
          ],
        ),
      ),
    ),
  );
}

class TravelCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? description;
  final String? imageUrl;
  final String asset;
  final String? badge;
  final String? price;
  final String? priceLabel;
  final String? heroTag;
  final VoidCallback? onTap;
  const TravelCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.description,
    this.imageUrl,
    this.asset = TravelPhotos.explore,
    this.badge,
    this.price,
    this.priceLabel,
    this.heroTag,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = AspectRatio(
      aspectRatio: 1.65,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TravelPhoto(
            url: imageUrl,
            asset: asset,
            label: imageUrl == null ? null : title,
          ),
          if (badge != null)
            Positioned(
              left: 14,
              right: 14,
              top: 14,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B5E43),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (heroTag != null) Hero(tag: heroTag!, child: image) else image,
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                  if (price != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          price!,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (priceLabel != null)
                          Text(priceLabel!, style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                  if (onTap != null) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 4,
                      children: [
                        Text(
                          'View details',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row-directional card: photo on the left, content on the right.
/// Used for spots, bookings, transports and other list-style browsing.
class TravelRowCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? meta;
  final String? trailing;
  final String asset;
  final String? imageUrl;
  final String? heroTag;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final double imageSize;

  const TravelRowCard({
    super.key,
    required this.title,
    required this.asset,
    this.subtitle,
    this.meta,
    this.trailing,
    this.imageUrl,
    this.heroTag,
    this.leadingIcon,
    this.onTap,
    this.imageSize = 92,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photo = SizedBox(
      width: imageSize,
      height: imageSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: TravelPhoto(url: imageUrl, asset: asset, label: title),
      ),
    );
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.divider(context), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 13, 12, 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (heroTag != null) Hero(tag: heroTag!, child: photo) else photo,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (meta != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leadingIcon != null) ...[
                            Icon(
                              leadingIcon,
                              size: 14,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                          ],
                          Flexible(
                            child: Text(
                              meta!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (trailing != null)
                Text(
                  trailing!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TravelSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback? onSeeAll;
  const TravelSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.onSeeAll,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 5),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            if (onSeeAll != null)
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

class TravelEmpty extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const TravelEmpty({super.key, required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.travel_explore_rounded, size: 40),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
        if (onRetry != null)
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
          ),
      ],
    ),
  );
}

/// Photo tile for browsing destinations division by division.
class TravelDivisionCard extends StatelessWidget {
  final String label;
  final String asset;
  final bool isSelected;
  final bool showCheck;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const TravelDivisionCard({
    super.key,
    required this.label,
    required this.asset,
    this.isSelected = false,
    this.showCheck = true,
    this.width = 124,
    this.height = 104,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? scheme.primary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              TravelPhoto(asset: asset, label: label),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xCC000000)],
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 8,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    shadows: [Shadow(blurRadius: 6, color: Color(0xFF000000))],
                  ),
                ),
              ),
              if (isSelected && showCheck)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
