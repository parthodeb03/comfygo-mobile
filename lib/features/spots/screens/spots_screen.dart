// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
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
    final c = CgColors.of(context);
    final spots = _results;
    const divisions = ['All', ...spotDivisions];

    return CgPageScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Tourist Spots',
            subtitle: 'Explore Bangladesh, division by division',
            onBack: () => goBack(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgTextField(
              label: 'Search spots',
              controller: _searchController,
              icon: Icons.search_rounded,
              hint: 'Search spots, districts…',
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              itemCount: divisions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final value = divisions[index];
                return CgChip(
                  label: value,
                  icon: Icons.place_outlined,
                  selected: _selected == value,
                  onTap: () => setState(() => _selected = value),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Text(
              '${spots.length} spot${spots.length == 1 ? '' : 's'} found',
              style: CgType.l12.copyWith(color: c.text2),
            ),
          ),
          const SizedBox(height: 12),
          if (spots.isEmpty)
            const CgEmptyState(
              icon: Icons.explore_off_rounded,
              message: 'No spots match your search.',
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  for (var i = 0; i < spots.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == spots.length - 1 ? 0 : 12,
                      ),
                      child: CgTile(
                        icon: Icons.place_outlined,
                        title: spots[i].name,
                        subtitle:
                            '${spots[i].tagline} · ${spots[i].district}',
                        trailingText: spots[i].division,
                        onTap: () => context.push('/spots/${spots[i].id}'),
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
