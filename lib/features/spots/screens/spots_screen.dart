import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/tourist_spots.dart';

/// Division-wise tourist spots — browse inspiration, then book a hotel.
class SpotsScreen extends StatefulWidget {
  const SpotsScreen({super.key});

  @override
  State<SpotsScreen> createState() => _SpotsScreenState();
}

class _SpotsScreenState extends State<SpotsScreen> {
  String _selected = 'All';
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TouristSpot> get _results {
    var list = spotsForDivision(_selected);
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.district.toLowerCase().contains(q) ||
                s.tagline.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _results;
    const divisions = ['All', ...spotDivisions];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text('Tourist Spots'),
      ),
      body: NatureBackground.wrap(
        child: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              // ─── Intro + search ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Explore Bangladesh, division by division',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _search = v.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search spots, districts…',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _search.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _search = '');
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // ─── Division chips ──────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 24 + MediaQuery.textScalerOf(context).scale(20),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: divisions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final value = divisions[index];
                      return CGChip(
                        label: value,
                        isSelected: _selected == value,
                        onTap: () => setState(() => _selected = value),
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${spots.length} spot${spots.length == 1 ? '' : 's'} found',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // ─── Spot list (row-directional cards) ───────────
              if (spots.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.explore_off_rounded,
                          size: 48,
                          color: AppColors.textHint(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No spots match your search.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                  sliver: SliverList.list(
                    children: [
                      for (final spot in spots) ...[
                        TravelRowCard(
                          title: spot.name,
                          subtitle: '${spot.tagline} · ${spot.district}',
                          meta: spot.division,
                          leadingIcon: Icons.place_rounded,
                          asset: spot.photo,
                          heroTag: 'spot_${spot.id}',
                          onTap: () => context.push('/spots/${spot.id}'),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
