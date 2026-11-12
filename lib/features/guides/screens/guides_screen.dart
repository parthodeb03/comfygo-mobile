// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/service_providers.dart';

/// Browse local guides and their specialities.
class GuidesScreen extends ConsumerStatefulWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
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

    return CgPageScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Guides',
            subtitle: 'Explore with a local',
            onBack: () => goBack(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgTextField(
              label: 'Search guides',
              controller: _search,
              icon: Icons.search_rounded,
              hint: 'Name, city or speciality…',
              onChanged: (_) => _load(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgSection(
              title: 'Local experts',
              actionLabel: data.isLoading ? null : '${data.guides.length} found',
            ),
          ),
          if (data.isLoading)
            const CgLoadingState()
          else if (data.error != null)
            CgErrorState(
              message: 'Unable to load guides. Please try again.',
              onRetry: _load,
            )
          else if (data.guides.isEmpty)
            const CgEmptyState(
              icon: Icons.hiking_rounded,
              message: 'No guides found. Try another search.',
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  for (var i = 0; i < data.guides.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == data.guides.length - 1 ? 0 : 12,
                      ),
                      child: _GuideTile(
                        name: data.guides[i].name,
                        specialization: data.guides[i].specialization,
                        rating: data.guides[i].rating,
                        dailyRate: data.guides[i].dailyRate,
                        onTap: () =>
                            context.push('/guides/${data.guides[i].id}'),
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

class _GuideTile extends StatelessWidget {
  const _GuideTile({
    required this.name,
    required this.specialization,
    required this.rating,
    required this.dailyRate,
    required this.onTap,
  });

  final String name;
  final String specialization;
  final double rating;
  final double dailyRate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgTile(
      title: name,
      subtitle: '$specialization · ★ ${rating.toStringAsFixed(1)}',
      onTap: onTap,
      leading: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: CgType.t16.copyWith(color: c.primary),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '৳${dailyRate.round()}',
            style: CgType.t16.copyWith(color: c.primary),
          ),
          Text('/day', style: CgType.l12.copyWith(color: c.text2)),
        ],
      ),
    );
  }
}
