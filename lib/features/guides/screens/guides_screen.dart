import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => ref
      .read(guidesProvider.notifier)
      .loadGuides(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(guidesProvider);

    return TravelScaffold(
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Guides'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: TravelBanner(
                  title: 'Explore with a local',
                  subtitle: 'Discover local stories and memorable experiences.',
                  asset: TravelPhotos.guides,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search guides...',
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
            if (data.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (data.error != null || data.guides.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmpty(
                  data.error != null
                      ? 'Unable to load guides.'
                      : 'No guides found.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: TravelGrid(
                    children: List.generate(data.guides.length, (index) {
                      final item = data.guides[index];
                      return CGListingCard(
                        imageAsset: TravelPhotos.guides,
                        imageUrl: item.profileImage,
                        name: item.name,
                        subtitle: item.specialization,
                        price: '৳${item.dailyRate.toStringAsFixed(0)}/day',
                        heroTag: 'guide_image_${item.id}',
                        onTap: () => context.push('/guides/${item.id}'),
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

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.hiking_rounded,
              size: 48,
              color: OneUIColors.textHintLight,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: OneUIColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
