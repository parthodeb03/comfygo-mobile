// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/service_providers.dart';

/// Browse hotels and jump straight into a stay.
class HotelsScreen extends ConsumerStatefulWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const HotelsScreen({super.key});

  @override
  ConsumerState<HotelsScreen> createState() => _HotelsScreenState();
}

class _HotelsScreenState extends ConsumerState<HotelsScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => ref
      .read(hotelsProvider.notifier)
      .loadHotels(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(hotelsProvider);

    return CgPageScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Hotels',
            subtitle: 'Find a comfortable base for your next adventure',
            onBack: () => goBack(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgTextField(
              label: 'Search hotels',
              controller: _search,
              icon: Icons.search_rounded,
              hint: 'Hotel name or city…',
              onChanged: (_) => _load(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgSection(
              title: 'Available stays',
              actionLabel: data.isLoading
                  ? null
                  : '${data.hotels.length} found',
            ),
          ),
          if (data.isLoading)
            const CgLoadingState()
          else if (data.error != null)
            CgErrorState(
              message: 'Unable to load hotels. Please try again.',
              onRetry: _load,
            )
          else if (data.hotels.isEmpty)
            CgEmptyState(
              icon: Icons.hotel_outlined,
              message: 'No hotels found. Try another search.',
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  for (var i = 0; i < data.hotels.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == data.hotels.length - 1 ? 0 : 12,
                      ),
                      child: _HotelTile(
                        name: data.hotels[i].name,
                        location: data.hotels[i].location,
                        price: data.hotels[i].pricePerNight,
                        onTap: () => context.push(
                          '/hotels/${data.hotels[i].id}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _HotelTile extends StatelessWidget {
  const _HotelTile({
    required this.name,
    required this.location,
    required this.price,
    required this.onTap,
  });

  final String name;
  final String location;
  final double price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgTile(
      icon: Icons.hotel_rounded,
      title: name,
      subtitle: location,
      onTap: onTap,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '৳${price.round()}',
            style: CgType.t16.copyWith(color: c.primary),
          ),
          Text('/night', style: CgType.l12.copyWith(color: c.text2)),
        ],
      ),
    );
  }
}
