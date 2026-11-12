// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/models.dart';
import '../../../state/service_providers.dart';

class HotelDetailScreen extends ConsumerStatefulWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  final int id;

  const HotelDetailScreen({super.key, required this.id});

  @override
  ConsumerState<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends ConsumerState<HotelDetailScreen> {
  late Future<Hotel?> _future;
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

  Future<Hotel?> _fetch() =>
      ref.read(hotelServiceProvider).getHotelById(widget.id);

  void _retry() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return FutureBuilder<Hotel?>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final hotel = snapshot.data;
        return CgPageScaffold(
          bottom: (loading || hotel == null)
              ? null
              : Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(CgRadii.nav),
                    ),
                    boxShadow: c.navShadow,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Starting from',
                                style: CgType.l12.copyWith(color: c.text2),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '৳${_fmtPrice(hotel.pricePerNight)}/night',
                                  style: CgType.t20.copyWith(
                                    color: c.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        CgPillButton(
                          width: 170,
                          height: 52,
                          onTap: hotel.availableRooms > 0
                              ? () => context.push('/book/hotel/${hotel.id}')
                              : null,
                          child: Text(
                            hotel.availableRooms > 0 ? 'Book Now' : 'Sold Out',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              CgPageTitle(
                title: loading ? 'Hotel' : (hotel?.name ?? 'Hotel'),
                subtitle: hotel == null
                    ? null
                    : '${hotel.address}, ${hotel.division}',
                onBack: () => goBack(context),
                trailing: CgIconAction(
                  icon: _isFavorited
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _isFavorited ? c.accent : c.primary,
                  semanticLabel: _isFavorited
                      ? 'Remove from favourites'
                      : 'Save to favourites',
                  onTap: () => _toggleFavorite(!_isFavorited),
                ),
              ),
              if (loading)
                const CgLoadingState()
              else if (hotel == null)
                CgErrorState(
                  message:
                      'This hotel could not be loaded. '
                      'Check your connection and try again.',
                  onRetry: _retry,
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CgTextPill(
                        label: '★ ${hotel.rating.toStringAsFixed(1)}',
                        icon: Icons.star_rounded,
                      ),
                      CgTextPill(
                        label: hotel.availableRooms > 0
                            ? '${hotel.availableRooms} rooms left'
                            : 'Sold out',
                        icon: Icons.meeting_room_outlined,
                      ),
                    ],
                  ),
                ),
                if (hotel.amenities.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: CgSection(title: 'Amenities'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final amenity in hotel.amenities)
                          CgTextPill(
                            label: amenity,
                            icon: Icons.check_rounded,
                          ),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: CgSection(title: 'About'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      hotel.description,
                      style: CgType.b14.copyWith(
                        color: c.text2,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: CgSection(title: 'Stay Details'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        CgInfoRow(
                          label: 'Price per night',
                          value: '৳${_fmtPrice(hotel.pricePerNight)}',
                          valueColor: c.primary,
                        ),
                        CgInfoRow(
                          label: 'Rooms available',
                          value: '${hotel.availableRooms} of ${hotel.totalRooms}',
                        ),
                        if (hotel.phone != null && hotel.phone!.isNotEmpty)
                          CgInfoRow(label: 'Phone', value: hotel.phone!),
                        if (hotel.email != null && hotel.email!.isNotEmpty)
                          CgInfoRow(
                            label: 'Email',
                            value: hotel.email!,
                            showDivider: false,
                          ),
                      ],
                    ),
                  ),
                ),
                if (hotel.phone == null || hotel.phone!.isEmpty) const SizedBox(height: 4),
              ],
            ],
          ),
        );
      },
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
