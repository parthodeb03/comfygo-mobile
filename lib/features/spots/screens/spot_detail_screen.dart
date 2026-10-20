import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../data/tourist_spots.dart';

/// Rich spot detail: description, how to get there, best time and tips.
/// Spots are informational — the call to action books a hotel stay.
class SpotDetailScreen extends StatelessWidget {
  final String id;

  const SpotDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final spot = spotById(id);
    if (spot == null) {
      return CgPageScaffold(
        child: Column(
          children: [
            CgPageTitle(
              title: 'Tourist Spot',
              onBack: () => goBack(context),
            ),
            const CgEmptyState(message: 'Sorry, this spot could not be found.'),
          ],
        ),
      );
    }

    return CgPageScaffold(
      bottom: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(CgRadii.nav),
          ),
          boxShadow: c.navShadow,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Enjoy the day, sleep nearby',
                      style: CgType.l12.copyWith(color: c.text2),
                    ),
                    Text(
                      'Hotels in ${spot.district}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CgType.t16.copyWith(
                        fontSize: 15,
                        color: c.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CgPillButton(
                width: 190,
                height: 52,
                semanticLabel: 'Find places to stay',
                onTap: () => context.push('/hotels'),
                child: const Text('Find Places to Stay'),
              ),
            ],
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: spot.name,
            subtitle: '${spot.district} · ${spot.division} Division',
            onBack: () => goBack(context),
            trailing: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: c.gMint,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.place_outlined, size: 22, color: c.primary),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CgTextPill(label: spot.tagline),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: CgCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'About this place',
                    style: CgType.t16.copyWith(color: c.text),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    spot.description,
                    style: CgType.b14.copyWith(color: c.text2, height: 1.55),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _InfoCard(
              icon: Icons.directions_rounded,
              title: 'How to get there',
              body: spot.howToReach,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _InfoCard(
              icon: Icons.wb_sunny_outlined,
              title: 'Best time to visit',
              body: spot.bestTime,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: CgSection(title: 'Highlights'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final highlight in spot.highlights)
                  CgTextPill(label: highlight, icon: Icons.check_rounded),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: CgSection(title: 'Travel tips'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: CgCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  for (var i = 0; i < spot.tips.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: c.gMain,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${i + 1}',
                            style: CgType.l12.copyWith(
                              fontWeight: FontWeight.w800,
                              color: c.onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            spot.tips[i],
                            style: CgType.b14.copyWith(
                              fontSize: 13.5,
                              height: 1.45,
                              color: c.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: c.gMint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: c.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CgType.t16.copyWith(color: c.text),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: CgType.b14.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: c.text2,
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
