import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/theme.dart';
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

  String get _favKey => 'fav_destination_${widget.id}';

  @override
  void initState() {
    super.initState();
    _future = _fetch();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _isFavorited = prefs.getBool(_favKey) ?? false);
  }

  Future<void> _toggleFavorite(bool value) async {
    setState(() => _isFavorited = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_favKey, value);
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
      backgroundColor: OneUIColors.backgroundLight,
      bottomNavigationBar: _destination == null
          ? null
          : _buildBookBar(_destination!),
      body: FutureBuilder<Destination?>(
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
              message: 'This destination could not be loaded. '
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: OneUIColors.textPrimaryLight,
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
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: OneUIColors.primaryLight,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${destination.location}, ${destination.division}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: OneUIColors.primaryLight,
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
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: OneUIColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  destination.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: OneUIColors.textSecondaryLight,
                    height: 1.6,
                  ),
                ),

                // Activities
                if (destination.activities != null &&
                    destination.activities!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Activities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: OneUIColors.textPrimaryLight,
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
      backgroundColor: OneUIColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: OneUIColors.textPrimaryLight,
            size: 18,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        CGFavoriteButton(
          isFavorited: _isFavorited,
          onChanged: _toggleFavorite,
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'destination_image_${widget.id}',
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: OneUIColors.surfaceVariantLight,
            child: TravelPhoto(
              url: (destination?.images.isNotEmpty ?? false)
                  ? destination!.images.first
                  : null,
              asset: TravelPhotos.forDestination(name),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Starting from',
                  style: TextStyle(
                    fontSize: 12,
                    color: OneUIColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '৳${_fmtPrice(destination.price)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: OneUIColors.primaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CGButton(
                label: 'Book Now',
                onPressed: () =>
                    context.push('/book/destination/${destination.id}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: OneUIColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: OneUIColors.textSecondaryLight),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: OneUIColors.textSecondaryLight,
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
