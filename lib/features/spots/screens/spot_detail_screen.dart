import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../data/tourist_spots.dart';

/// Rich spot detail: description, how to get there, best time and tips.
/// Spots are informational — the call to action books a hotel stay.
class SpotDetailScreen extends StatelessWidget {
  final String id;

  const SpotDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final spot = spotById(id);
    if (spot == null) {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Tourist Spot')),
        body: NatureBackground.wrap(
          child: Center(
            child: Text(
              'Sorry, this spot could not be found.',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
        ),
      );
    }

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
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
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    Text(
                      'Hotels in ${spot.district}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              CGButton(
                label: 'Find Places to Stay',
                width: 190,
                height: 48,
                onPressed: () => context.push('/hotels'),
              ),
            ],
          ),
        ),
      ),
      body: NatureBackground.wrap(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.background(context),
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                onPressed: () => context.canPop() ? context.pop() : context.go('/'),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'spot_${spot.id}',
                      child: TravelPhoto(asset: spot.photo, label: spot.name),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xB3000000)],
                          stops: [0.4, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            spot.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              shadows: [
                                Shadow(blurRadius: 8, color: Color(0xFF000000)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.place_rounded,
                                size: 15,
                                color: Color(0xFFD7F5E3),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${spot.district} · ${spot.division} Division',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFD7F5E3),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tagline
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        spot.tagline,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    _sectionTitle(context, 'About this place'),
                    const SizedBox(height: 8),
                    Text(
                      spot.description,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
                    ),
                    const SizedBox(height: 20),

                    _infoCard(
                      context,
                      icon: Icons.directions_rounded,
                      title: 'How to get there',
                      body: spot.howToReach,
                    ),
                    const SizedBox(height: 14),
                    _infoCard(
                      context,
                      icon: Icons.wb_sunny_rounded,
                      title: 'Best time to visit',
                      body: spot.bestTime,
                    ),
                    const SizedBox(height: 20),

                    _sectionTitle(context, 'Highlights'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final highlight in spot.highlights)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.divider(context),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 15,
                                  color: AppColors.primary(context),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  highlight,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _sectionTitle(context, 'Travel tips'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.divider(context),
                          width: 0.5,
                        ),
                      ),
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
                                    color: AppColors.primary(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    spot.tips[i],
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      height: 1.45,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Text(
    title,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary(context),
    ),
  );

  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary(context)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textSecondary(context),
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
