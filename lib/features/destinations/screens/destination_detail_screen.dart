import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../state/service_providers.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const DestinationDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends ConsumerState<DestinationDetailScreen> {
  late Future<Destination?> _future;
  Destination? _destination;
  bool _isFavorited = false;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final favorite = await ref
        .read(favoriteServiceProvider)
        .getFavorites()
        .catchError((Object _) => <Favorite>[]);
    if (!mounted) return;
    setState(() => _isFavorited = favorite.any((f) => f.itemId == widget.id));
  }

  Future<void> _toggleFavorite(bool value) async {
    setState(() => _isFavorited = value);
    if (value) {
      await ref.read(favoriteServiceProvider).toggleFavorite(
            'destination',
            widget.id,
          );
    } else {
      // find and remove the local favourite
      final list = await ref
          .read(favoriteServiceProvider)
          .getFavorites()
          .catchError((Object _) => <Favorite>[]);
      final target = list.firstWhere(
        (f) => f.itemType == 'destination' && f.itemId == widget.id,
        orElse: () => throw Exception('missing'),
      );
      await ref.read(favoriteServiceProvider).removeFavorite(
            'destination',
            target.itemId,
          );
    }
  }

  Future<Destination?> _fetch() async {
    final destination = await ref
        .read(destinationServiceProvider)
        .getDestinationById(widget.id);
    if (mounted) setState(() => _destination = destination);
    return destination;
  }

  void _retry() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      bottomNavigationBar: _destination == null
          ? null
          : _buildBookBar(_destination!),
      body: NatureBackground.wrap(
        child: FutureBuilder<Destination?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final destination = snapshot.data;
            if (destination == null) {
              return _buildErrorState();
            }
            return _buildContent(destination);
          },
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return CustomScrollView(
      slivers: [
        _appBar(null),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TravelEmpty(
              message:
                  'This destination could not be loaded. '
                  'Check your connection and try again.',
              onRetry: _retry,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Destination destination) {
    return CustomScrollView(
      slivers: [
        _appBar(destination),

        // ─── Content ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        destination.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFFB300),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE6A100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: AppColors.primary(context),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${destination.location}, ${destination.division}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Quick info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (destination.bestTimeToVisit != null &&
                        destination.bestTimeToVisit!.isNotEmpty)
                      _buildInfoChip(
                        Icons.access_time_rounded,
                        'Best: ${destination.bestTimeToVisit}',
                      ),
                    _buildInfoChip(
                      Icons.groups_rounded,
                      '${destination.reviewCount} reviews',
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // About
                Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  destination.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary(context),
                    height: 1.6,
                  ),
                ),

                // Activities
                if (destination.activities != null &&
                    destination.activities!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: destination.activities!
                        .map((a) => CGChip(label: a))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _appBar(Destination? destination) {
    final name = destination?.name ?? '';
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.background(context),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary(context),
            size: 18,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        CGFavoriteButton(
          isFavorited: _isFavorited,
          onChanged: _toggleFavorite,
          key: ValueKey('_fav_${widget.id}'),
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'destination_image_${widget.id}',
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.surfaceVariant(context),
            child: TravelPhoto(
              url: (destination?.images.isNotEmpty ?? false)
                  ? destination!.images.first
                  : null,
              asset: TravelPhotos.forDestination(name, destination?.division),
              label: name.isEmpty ? null : name,
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sticky Book Now button ──────────────────────────────────
  Widget _buildBookBar(Destination destination) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final price = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Packages from',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                Text(
                  'BDT ${_fmtPrice(destination.price)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary(context),
                  ),
                ),
              ],
            );
            final action = CGButton(
              label: 'Find Places to Stay',
              onPressed: () => context.push('/hotels'),
            );
            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [price, const SizedBox(height: 10), action],
              );
            }
            return Row(
              children: [
                price,
                const SizedBox(width: 16),
                Expanded(child: action),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary(context)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtPrice(double value) {
    final s = value.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}
