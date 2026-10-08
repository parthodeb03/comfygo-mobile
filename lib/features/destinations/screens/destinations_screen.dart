import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';
import '../../../models/favorite_model.dart';

class DestinationsScreen extends ConsumerStatefulWidget {
  const DestinationsScreen({super.key});

  @override
  ConsumerState<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends ConsumerState<DestinationsScreen> {
  final _search = TextEditingController();
  String _selected = 'All';
  List<int> _favoriteIds = [];
  bool _showFavorites = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => ref
      .read(destinationsProvider.notifier)
      .loadDestinations(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
      );

  Future<void> _refreshFavorites() async {
    try {
      _favoriteIds = (await ref
              .read(favoriteServiceProvider)
              .getFavorites()
              .catchError((Object _) => <Favorite>[]))
          .map((f) => f.itemId)
          .toList();
    } catch (_) {
      // Keep the local list as a fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(destinationsProvider);
    final destinations = data.destinations.where((item) {
      if (_showFavorites && !_favoriteIds.contains(item.id)) return false;
      if (_selected == 'All') return true;
      final text = '${item.name} ${item.division}'.toLowerCase();
      return switch (_selected) {
        'Beach' =>
          text.contains('beach') ||
              text.contains('cox') ||
              text.contains('kuakata') ||
              text.contains('martin'),
        'Hills' =>
          text.contains('hill') ||
              text.contains('bandarban') ||
              text.contains('sajek') ||
              text.contains('rangamati'),
        'Forest' =>
          text.contains('forest') ||
              text.contains('sundarban') ||
              text.contains('sylhet') ||
              text.contains('ratargul'),
        'River' =>
          text.contains('river') ||
              text.contains('kaptai') ||
              text.contains('rangamati'),
        'Heritage' =>
          text.contains('heritage') ||
              text.contains('dhaka') ||
              text.contains('paharpur') ||
              text.contains('sonargaon'),
        _ => true,
      };
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    _RoundIcon(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.go('/'),
                    ),
                    const Spacer(),
                    _RoundIcon(
                      icon: Icons.tune_rounded,
                      onTap: () => _showCategoryFilters(context),
                    ),
                    const SizedBox(width: 10),
                    _RoundIcon(
                      icon: _showFavorites
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      onTap: () {
                        setState(() => _showFavorites = !_showFavorites);
                        _refreshFavorites();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Select\ndestination',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 34,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.1,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              sliver: SliverToBoxAdapter(
                child: TextField(
                  controller: _search,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search destinations',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 9),
                  itemBuilder: (context, index) {
                    final value = _categories[index];
                    final selected = _selected == value;
                    return                    ChoiceChip(
                      label: Text(value),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selected = value);
                        _refreshFavorites();
                      },
                      showCheckmark: false,
                      backgroundColor: Colors.white,
                      selectedColor: const Color(0xFFD9E6D2),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      labelStyle: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (data.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (data.error != null)
              SliverFillRemaining(
                child: Center(
                  child: TravelEmpty(
                    message: 'Unable to load destinations. Please try again.',
                    onRetry: _load,
                  ),
                ),
              )
            else if (destinations.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: TravelEmpty(
                    message: 'No destinations in this category yet.',
                  ),
                ),
              )              else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = destinations[index];
                    final asset = TravelPhotos.forDestination(
                      item.name,
                      item.division,
                    );
                    return _DestinationTile(
                      name: item.name,
                      division: item.division,
                      asset: asset,
                      imageUrl: item.images.isEmpty ? null : item.images.first,
                      isFavorite: !_showFavorites
                          ? _favoriteIds.contains(item.id)
                          : false,
                      onFavorite: () async {
                        if (_showFavorites) return;
                        if (_favoriteIds.contains(item.id)) {
                          await ref.read(favoriteServiceProvider).removeFavorite(
                                'destination',
                                item.id,
                              );
                          _favoriteIds.remove(item.id);
                        } else {
                          await ref.read(favoriteServiceProvider).toggleFavorite(
                                'destination',
                                item.id,
                              );
                          _favoriteIds.add(item.id);
                        }
                        setState(() {});
                      },
                      onTap: () => context.push('/destinations/${item.id}'),
                    );
                  }, childCount: destinations.length),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
          child: SizedBox(
            height: 58,
            child: FilledButton(
              onPressed: destinations.isEmpty
                  ? null
                  : () =>
                        context.push('/destinations/${destinations.first.id}'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFB6CC35),
                foregroundColor: const Color(0xFF20271A),
                disabledBackgroundColor: const Color(0xFFD9D9C9),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text(
                'Explore',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF3F0E6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _categories
              .map(
                (category) => ChoiceChip(
                  label: Text(category),
                  selected: _selected == category,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() => _selected = category);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  static const _categories = [
    'All',
    'Beach',
    'Hills',
    'Forest',
    'River',
    'Heritage',
  ];
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Icon(icon, size: 21, color: const Color(0xFF20271A)),
      ),
    ),
  );
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.name,
    required this.division,
    required this.asset,
    required this.imageUrl,
    required this.isFavorite,
    required this.onFavorite,
    required this.onTap,
  });
  final String name;
  final String division;
  final String asset;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFD9E6D2),
    borderRadius: BorderRadius.circular(27),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TravelPhoto(url: imageUrl, asset: asset, label: name),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Colors.transparent,
                  Color(0xB8000000),
                ],
                stops: [0, .43, 1],
              ),
            ),
          ),
          Positioned(
            top: 11,
            left: 11,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x8820271A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                child: Text(
                  'BD · ${division.toUpperCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: const Color(0x5560676B),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onFavorite,
                child: SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 10,
            bottom: 14,
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
