// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../data/comfy_destinations.dart';
import '../../../state/saved_destinations_provider.dart';
import '../../../state/theme_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _categoryIcons = <String, IconData>{
    'All': Icons.grid_view_rounded,
    'Beach': Icons.wb_sunny_outlined,
    'Mountain': Icons.terrain_rounded,
    'Forest': Icons.forest_outlined,
    'Tea': Icons.eco_outlined,
  };

  /// Direct links to every bookable section of the app.
  static const _services = <({String label, IconData icon, String route})>[
    (
      label: 'Hotels',
      icon: Icons.hotel_rounded,
      route: '/hotels',
    ),
    (
      label: 'Transport',
      icon: Icons.directions_bus_rounded,
      route: '/transports',
    ),
    (
      label: 'Guides',
      icon: Icons.record_voice_over_rounded,
      route: '/guides',
    ),
    (
      label: 'Packages',
      icon: Icons.luggage_rounded,
      route: '/packages',
    ),
    (
      label: 'Spots',
      icon: Icons.camera_alt_outlined,
      route: '/spots',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = CgColors.of(context);
    final category = ref.watch(selectedCategoryProvider);
    final items = comfyDestinationsFor(category);

    return Scaffold(
      backgroundColor: c.bg,
      body: CgBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: c.text,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Sylhet, Bangladesh',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: CgType.l12.copyWith(color: c.text),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Where Do You\n',
                                  style: CgType.h1.copyWith(color: c.text),
                                ),
                                TextSpan(
                                  text: 'Want To Go?',
                                  style: CgType.h1Bold.copyWith(color: c.text),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CgRoundButton(
                      icon: Icons.notifications_none_rounded,
                      semanticLabel: 'Toggle dark mode',
                      onTap: () {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: CgPressable(
                  onTap: () => context.go('/destinations'),
                  child: CgCard(
                    radius: CgRadii.pill,
                    child: SizedBox(
                      height: 56,
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Text(
                            'Sylhet',
                            style: CgType.b14.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: c.text,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(height: 20, width: 1, color: c.line),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Search destination',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CgType.b14.copyWith(
                                fontSize: 13,
                                color: c.text2,
                              ),
                            ),
                          ),
                          Icon(Icons.search_rounded, size: 20, color: c.text),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Text(
                  'Category',
                  style: CgType.t16.copyWith(fontSize: 18, color: c.text),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  itemCount: comfyCategories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final name = comfyCategories[index];
                    return CgChip(
                      label: name,
                      icon: _categoryIcons[name] ?? Icons.grid_view_rounded,
                      selected: category == name,
                      onTap: () =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              name,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: CgSection(
                  title: 'Services',
                  actionLabel: 'See all',
                  onAction: () => context.push('/packages'),
                ),
              ),
              SizedBox(
                height: 116,
                child: AnimationLimiter(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _services.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final service = _services[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 400),
                        child: SlideAnimation(
                          horizontalOffset: .05,
                          curve: Curves.easeOutCubic,
                          child: FadeInAnimation(
                            curve: Curves.easeOutCubic,
                            child: CgPressable(
                              onTap: () => context.push(service.route),
                              child: CgCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 12,
                                ),
                                child: SizedBox(
                                  width: 76,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: c.gMint,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          service.icon,
                                          size: 22,
                                          color: c.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        service.label,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: CgType.l12.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: c.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Popular Destinations',
                  style: CgType.t16.copyWith(fontSize: 18, color: c.text),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == items.length - 1 ? 0 : 16,
                          ),
                          child: AnimationConfiguration.staggeredList(
                            position: i,
                            duration: const Duration(milliseconds: 400),
                            child: SlideAnimation(
                              verticalOffset: .04,
                              curve: Curves.easeOutCubic,
                              child: FadeInAnimation(
                                curve: Curves.easeOutCubic,
                                child: CgTripCard(
                                  key: ValueKey(items[i].id),
                                  item: items[i],
                                  onOpen: () =>
                                      context.push('/trip/${items[i].id}'),
                                ),
                              ),
                            ),
                          ),
                        ),
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
