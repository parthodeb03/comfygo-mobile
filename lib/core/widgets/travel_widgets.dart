import 'dart:math' as math;

import 'package:flutter/material.dart';

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

  /// Get a unique photo for a destination by name
  static String forDestination(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('sundarbans') || lower.contains('mangrove')) {
      return sundarbans;
    }
    if (lower.contains('cox') ||
        lower.contains('sea') ||
        lower.contains('beach')) {
      return coxsBazar;
    }
    if (lower.contains('sylhet') || lower.contains('tea')) return sylhet;
    if (lower.contains('bandarban') || lower.contains('hill')) return bandarban;
    if (lower.contains('dhaka') || lower.contains('city')) return dhaka;
    if (lower.contains('forest') || lower.contains('nature')) return forest;
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
        color: Color(0xFF1B5E43),
        child: Center(
          child: Icon(Icons.landscape_rounded, color: Colors.white, size: 40),
        ),
      ),
    );
    final source = url?.trim();
    if (source == null || source.isEmpty) return fallback();
    return Image.network(
      source,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      semanticLabel: label,
      errorBuilder: (_, _, _) => fallback(),
      frameBuilder: (context, child, frame, sync) =>
          frame == null ? fallback() : child,
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
  const TravelScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.maxContentWidth = 1200,
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
                child: body,
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
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

class TravelBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String asset;
  final String eyebrow;
  const TravelBanner({
    super.key,
    required this.title,
    required this.subtitle,
    this.asset = TravelPhotos.home,
    this.eyebrow = 'COMFYGO / BANGLADESH',
  });
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
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
                if (showBack && Navigator.of(context).canPop())
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
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
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
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
            ),
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
