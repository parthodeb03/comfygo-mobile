// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../data/comfy_destinations.dart';

class DestinationsScreen extends ConsumerWidget {
  const DestinationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = CgColors.of(context);
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
                  'Explore',
                  style: CgType.h1Bold.copyWith(color: c.text),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimationLimiter(
                  child: Column(
                    children: [
                      for (var i = 0; i < comfyDestinations.length; i++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: i == comfyDestinations.length - 1 ? 0 : 16,
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
                                  key: ValueKey(comfyDestinations[i].id),
                                  item: comfyDestinations[i],
                                  onOpen: () => context.push(
                                    '/trip/${comfyDestinations[i].id}',
                                  ),
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
