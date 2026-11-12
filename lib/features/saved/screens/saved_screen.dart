// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../data/comfy_destinations.dart';
import '../../../state/saved_destinations_provider.dart';

class SavedScreen extends ConsumerWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = CgColors.of(context);
    final saved = ref.watch(savedDestinationsProvider);
    final items = comfyDestinations
        .where((item) => saved.contains(item.id))
        .toList();

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
                child: Text(
                  'Saved',
                  style: CgType.h1Bold.copyWith(color: c.text),
                ),
              ),
              const SizedBox(height: 16),
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Nothing saved yet. Tap the heart on a destination to '
                    'keep it here.',
                    style: CgType.b14.copyWith(color: c.text2),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimationLimiter(
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
