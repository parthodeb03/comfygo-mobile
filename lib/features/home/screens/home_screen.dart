import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/travel_widgets.dart';
import '../../../models/destination_model.dart';
import '../../../models/hotel_model.dart';
import '../../../state/service_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destinations = ref.watch(destinationsProvider);
    final hotels = ref.watch(hotelsProvider);
    final dark = AppColors.isDark(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // ─── Backdrop: travel photo, clearly visible at the top and
        // fading into the page background so every section stays readable.
        Positioned.fill(
          child: Image.asset(
            TravelPhotos.home,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: dark
                    ? const [
                        Color(0xB3141D17),
                        Color(0x8C141D17),
                        Color(0xF216231A),
                        Color(0xFF16231A),
                      ]
                    : const [
                        Color(0xB3EEF4EC),
                        Color(0x8CEEF4EC),
                        Color(0xF2F3F5F7),
                        Color(0xFFF3F5F7),
                      ],
                stops: const [0.0, 0.22, 0.45, 0.7],
              ),
            ),
          ),
        ),
        SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                ref.read(destinationsProvider.notifier).loadDestinations(),
                ref.read(hotelsProvider.notifier).loadHotels(),
              ]);
            },
            child: ListView(
              padding: const EdgeInsets.only(top: 22, bottom: 28),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What would you like to find?',
                        style: TextStyle(
                          fontSize: 27,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Green escapes, sea beaches and cosy stays across Bangladesh.',
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.35,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ─── Quick actions ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.directions_bus_rounded,
                          label: 'Transport',
                          background: AppColors.primarySoft(context),
                          foreground: AppColors.primary(context),
                          onTap: () => context.go('/transports'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.hotel_rounded,
                          label: 'Hotels',
                          background: AppColors.creamSoft(context),
                          foreground: AppColors.amber,
                          onTap: () => context.go('/hotels'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.person_pin_circle_rounded,
                          label: 'Guides',
                          background: AppColors.greenMist(context),
                          foreground: AppColors.lime,
                          onTap: () => context.go('/guides'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.travel_explore_rounded,
                          label: 'Explore',
                          background: AppColors.greenSoft(context),
                          foreground: AppColors.accentGreen(context),
                          onTap: () => context.go('/destinations'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _DestinationRow(
                  items: destinations.destinations,
                  loading: destinations.isLoading,
                  error: destinations.error,
                  retry: () =>
                      ref.read(destinationsProvider.notifier).loadDestinations(),
                ),
                const SizedBox(height: 26),
                _HotelRow(
                  items: hotels.hotels,
                  loading: hotels.isLoading,
                  error: hotels.error,
                  retry: () => ref.read(hotelsProvider.notifier).loadHotels(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Rounded square shortcut with a coloured fill.
class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: background,
    borderRadius: BorderRadius.circular(18),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: foreground),
            const SizedBox(height: 8),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Section title + coloured "See All" pill.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.onSeeAll,
  });

  final String title;
  final String subtitle;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 13),
                child: Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: AppColors.greenSoft(context),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: onSeeAll,
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 8, 10, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentGreen(context),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 15,
                    color: AppColors.accentGreen(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Horizontal row of destination cards — photo, rating, place and price each
/// get their own slot so nothing overlaps or clips.
class _DestinationRow extends StatelessWidget {
  const _DestinationRow({
    required this.items,
    required this.loading,
    required this.error,
    required this.retry,
  });

  final List<Destination> items;
  final bool loading;
  final String? error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width * .66).clamp(
      232.0,
      310.0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Top Destinations',
          subtitle: 'Handpicked places travellers love most',
          onSeeAll: () => context.go('/destinations'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 300,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? _RetryBox(onRetry: retry)
              : items.isEmpty
              ? const _EmptyBox(message: 'No destinations available')
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) => _DestinationRowCard(
                    item: items[index],
                    width: cardWidth,
                  ),
                ),
        ),
      ],
    );
  }
}

class _DestinationRowCard extends StatelessWidget {
  const _DestinationRowCard({required this.item, required this.width});

  final Destination item;
  final double width;

  @override
  Widget build(BuildContext context) {
    final imagePath = item.images.isEmpty
        ? TravelPhotos.forDestination(item.name, item.division)
        : item.images.first;
    final activities = item.activities?.length ?? 0;
    final price = item.price <= 0
        ? 'Free'
        : '৳${item.price.toStringAsFixed(0)}';

    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface(context),
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => context.push('/destinations/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 138,
                    width: double.infinity,
                    child: Hero(
                      tag: imagePath,
                      child: TravelPhoto(
                        url: item.images.isEmpty ? null : item.images.first,
                        asset: TravelPhotos.forDestination(
                          item.name,
                          item.division,
                        ),
                        label: item.name,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x66102A1D)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _PhotoPill(
                      icon: Icons.star_rounded,
                      label: item.rating > 0
                          ? item.rating.toStringAsFixed(1)
                          : 'New',
                      background: AppColors.brandGreen,
                      foreground: Colors.white,
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: _PhotoPill(
                      icon: Icons.place_rounded,
                      label: item.division.isEmpty ? 'Bangladesh' : item.division,
                      background: Colors.white.withValues(alpha: 0.92),
                      foreground: AppColors.brandGreenDeep,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.landscape_rounded,
                            size: 14,
                            color: AppColors.accentGreen(context),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              activities > 0
                                  ? '$activities activities'
                                  : 'Sightseeing & tours',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentGreen(context),
                              ),
                            ),
                          ),
                          if (item.price > 0) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  'per person',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: AppColors.textHint(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
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

/// Horizontal row of hotel cards with the same structure as destinations.
class _HotelRow extends StatelessWidget {
  const _HotelRow({
    required this.items,
    required this.loading,
    required this.error,
    required this.retry,
  });

  final List<Hotel> items;
  final bool loading;
  final String? error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final cardWidth = (MediaQuery.sizeOf(context).width * .74).clamp(
      252.0,
      330.0,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Exclusive Hotels',
          subtitle: 'Comfortable stays with the best views',
          onSeeAll: () => context.push('/hotels'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 300,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? _RetryBox(onRetry: retry)
              : items.isEmpty
              ? const _EmptyBox(message: 'No hotels available')
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) =>
                      _HotelRowCard(item: items[index], width: cardWidth),
                ),
        ),
      ],
    );
  }
}

class _HotelRowCard extends StatelessWidget {
  const _HotelRowCard({required this.item, required this.width});

  final Hotel item;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: AppColors.surface(context),
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: () => context.push('/hotels/${item.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 138,
                    width: double.infinity,
                    child: TravelPhoto(
                      url: item.images.isEmpty ? null : item.images.first,
                      asset: TravelPhotos.hotels,
                      label: item.name,
                    ),
                  ),
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0x66102A1D)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: _PhotoPill(
                      icon: Icons.star_rounded,
                      label: item.rating > 0
                          ? item.rating.toStringAsFixed(1)
                          : 'New',
                      background: AppColors.amber,
                      foreground: Colors.white,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: _PhotoPill(
                      icon: Icons.bed_rounded,
                      label: item.availableRooms > 0
                          ? '${item.availableRooms} rooms'
                          : 'Sold out',
                      background: Colors.white.withValues(alpha: 0.92),
                      foreground: AppColors.brandGreenDeep,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.creamSoft(context),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: AppColors.amber.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_rounded,
                            size: 14,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item.address.isEmpty
                                  ? item.division
                                  : item.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              '৳${item.pricePerNight.toStringAsFixed(0)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentGreen(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '/ night',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.textHint(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

/// Compact coloured pill used over photos.
class _PhotoPill extends StatelessWidget {
  const _PhotoPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(999),
      boxShadow: const [
        BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: foreground),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ),
      ],
    ),
  );
}

class _RetryBox extends StatelessWidget {
  const _RetryBox({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: TextButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded),
      label: const Text('Retry'),
    ),
  );
}

class _EmptyBox extends StatelessWidget {
  const _EmptyBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      message,
      style: TextStyle(color: AppColors.textSecondary(context)),
    ),
  );
}
