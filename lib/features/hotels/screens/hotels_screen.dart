import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';

class HotelsScreen extends ConsumerStatefulWidget {
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

    return TravelScaffold(
      backgroundColor: AppColors.background(context),
      photoBackground: TravelPhotos.listGreen,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => goBack(context),
        ),
        title: const Text('Hotels'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: TravelBanner(
                  title: 'Stay somewhere special',
                  subtitle: 'Find a comfortable base for your next adventure.',
                  asset: TravelPhotos.hotels,
                  showImage: false,
                ),
              ),
            ),
            // ─── Search bar ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search hotels...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _search.clear();
                        _load();
                      },
                    ),
                  ),
                ),
              ),
            ),

            // ─── Results ────────────────────────────────────
            if (data.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (data.error != null)
              SliverToBoxAdapter(
                child: _buildEmpty(
                  'Unable to load hotels. Please try again.',
                  onRetry: _load,
                ),
              )
            else if (data.hotels.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmpty('No hotels found. Try another search.'),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: TravelGrid(
                    children: List.generate(data.hotels.length, (index) {
                      final item = data.hotels[index];
                      return CGListingCard(
                        imageAsset: TravelPhotos.hotels,
                        imageUrl: item.images.isEmpty
                            ? null
                            : item.images.first,
                        name: item.name,
                        subtitle: item.location,
                        price:
                            '৳${item.pricePerNight.toStringAsFixed(0)}/night',
                        heroTag: 'hotel_image_${item.id}',
                        onTap: () => context.push('/hotels/${item.id}'),
                      );
                    }),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String message, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(
              Icons.hotel_rounded,
              size: 48,
              color: AppColors.textHint(context),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onRetry, child: const Text('Try Again')),
            ],
          ],
        ),
      ),
    );
  }
}
