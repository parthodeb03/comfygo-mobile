import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../state/service_providers.dart';

class HotelDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const HotelDetailScreen({super.key, required this.id});

  @override
  ConsumerState<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends ConsumerState<HotelDetailScreen> {
  late Future<Hotel?> _future;
  Hotel? _hotel;
  bool _isFavorited = false;

  String get _favKey => 'fav_hotel_${widget.id}';

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

  Future<Hotel?> _fetch() async {
    final hotel = await ref.read(hotelServiceProvider).getHotelById(widget.id);
    if (mounted) setState(() => _hotel = hotel);
    return hotel;
  }

  void _retry() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      bottomNavigationBar: _hotel == null ? null : _buildBookBar(_hotel!),
      body: NatureBackground.wrap(
        child: FutureBuilder<Hotel?>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final hotel = snapshot.data;
            if (hotel == null) return _buildErrorState();
            return _buildContent(hotel);
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
                  'This hotel could not be loaded. '
                  'Check your connection and try again.',
              onRetry: _retry,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(Hotel hotel) {
    return CustomScrollView(
      slivers: [
        _appBar(hotel),
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFD9E6D2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
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
                          hotel.name,
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
                              hotel.rating.toStringAsFixed(1),
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
                          '${hotel.address}, ${hotel.division}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary(context),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Amenities
                  if (hotel.amenities.isNotEmpty) ...[
                    Text(
                      'Amenities',
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
                      children: hotel.amenities
                          .map((a) => CGChip(label: a))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

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
                    hotel.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stay details — real availability instead of mock room cards
                  Text(
                    'Stay Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.payments_rounded,
                    'Price per night',
                    '৳${_fmtPrice(hotel.pricePerNight)}',
                  ),
                  _buildInfoRow(
                    Icons.meeting_room_rounded,
                    'Rooms available',
                    '${hotel.availableRooms} of ${hotel.totalRooms}',
                  ),
                  if (hotel.phone != null && hotel.phone!.isNotEmpty)
                    _buildInfoRow(Icons.phone_rounded, 'Phone', hotel.phone!),
                  if (hotel.email != null && hotel.email!.isNotEmpty)
                    _buildInfoRow(Icons.email_rounded, 'Email', hotel.email!),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _appBar(Hotel? hotel) {
    final name = hotel?.name ?? '';
    return SliverAppBar(
      expandedHeight: 380,
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
        CGFavoriteButton(isFavorited: _isFavorited, onChanged: _toggleFavorite),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'hotel_image_${widget.id}',
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: AppColors.surfaceVariant(context),
            child: Stack(
              fit: StackFit.expand,
              children: [
                TravelPhoto(
                  url: (hotel?.images.isNotEmpty ?? false)
                      ? hotel!.images.first
                      : null,
                  asset: TravelPhotos.hotels,
                  label: name.isEmpty ? null : name,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x22000000),
                        Colors.transparent,
                        Color(0xBB000000),
                      ],
                      stops: [0, .42, 1],
                    ),
                  ),
                ),
                if (name.isNotEmpty)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 42,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${hotel?.division ?? ''}  ·  ${hotel?.rating.toStringAsFixed(1) ?? ''} ★',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sticky Book Now button ──────────────────────────────────
  Widget _buildBookBar(Hotel hotel) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Starting from',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '৳${_fmtPrice(hotel.pricePerNight)}/night',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CGButton(
                    height: 48,
                    label: hotel.availableRooms > 0 ? 'Book Now' : 'Sold Out',
                    onPressed: hotel.availableRooms > 0
                        ? () => context.push('/book/hotel/${hotel.id}')
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: AppColors.primary(context)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
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
