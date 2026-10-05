import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';

class DestinationsScreen extends ConsumerStatefulWidget {
  const DestinationsScreen({super.key});

  @override
  ConsumerState<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends ConsumerState<DestinationsScreen> {
  final _search = TextEditingController();
  String _selected = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => ref
      .read(destinationsProvider.notifier)
      .loadDestinations(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
        division: _selected == 'All' ? null : _selected,
      );

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(destinationsProvider);

    return TravelScaffold(
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Explore Bangladesh'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: TravelBanner(
                  title: 'Find your next escape',
                  subtitle: 'From quiet tea gardens to the coast, discover Bangladesh.',
                  asset: TravelPhotos.explore,
                ),
              ),
            ),
            // ─── Search bar ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search destinations...',
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

            // ─── Category pills ──────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24 + MediaQuery.textScalerOf(context).scale(20),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _divisions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final value = _divisions[index];
                    return CGChip(
                      label: value,
                      isSelected: _selected == value,
                      onTap: () {
                        setState(() => _selected = value);
                        _load();
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ─── Results count ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '${data.destinations.length} destinations found',
                  style: const TextStyle(
                    fontSize: 13,
                    color: OneUIColors.textSecondaryLight,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // ─── Loading / Error / Empty / Grid ─────────────
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
                  'Unable to load destinations. Please try again.',
                  onRetry: _load,
                ),
              )
            else if (data.destinations.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmpty(
                  'No destinations found. Try another search.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: TravelGrid(
                    children: List.generate(data.destinations.length, (index) {
                      final item = data.destinations[index];
                      return TravelCard(
                        asset: TravelPhotos.forDestination(item.name),
                        priceLabel: 'per person',
                        imageUrl: item.images.isEmpty
                            ? null
                            : item.images.first,
                        title: item.name,
                        subtitle: item.division,
                        price: '৳${item.price.toStringAsFixed(0)}',
                        onTap: () => context.push('/destinations/${item.id}'),
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
            const Icon(
              Icons.explore_off_rounded,
              size: 48,
              color: OneUIColors.textHintLight,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: OneUIColors.textSecondaryLight,
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

  static const _divisions = [
    'All',
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna',
    'Barisal',
    'Rangpur',
    'Mymensingh',
  ];
}
