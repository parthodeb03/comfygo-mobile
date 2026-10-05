import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../state/service_providers.dart';

class GuideDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const GuideDetailScreen({super.key, required this.id});

  @override
  ConsumerState<GuideDetailScreen> createState() => _GuideDetailScreenState();
}

class _GuideDetailScreenState extends ConsumerState<GuideDetailScreen> {
  late Future<Guide?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<Guide?> _fetch() =>
      ref.read(guideServiceProvider).getGuideById(widget.id);

  void _retry() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Guide Profile'),
      ),
      body: FutureBuilder<Guide?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final guide = snapshot.data;
          if (guide == null) {
            return TravelEmpty(
              message: 'This guide profile could not be loaded. '
                  'Check your connection and try again.',
              onRetry: _retry,
            );
          }
          return _buildContent(guide);
        },
      ),
    );
  }

  Widget _buildContent(Guide guide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: OneUIColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: OneUIColors.dividerLight, width: 0.5),
            ),
            child: Column(
              children: [
                Hero(
                  tag: 'guide_image_${widget.id}',
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: OneUIColors.primarySoft,
                    child: guide.profileImage == null ||
                            guide.profileImage!.isEmpty
                        ? Text(
                            guide.name.isEmpty
                                ? '?'
                                : guide.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: OneUIColors.primaryLight,
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : ClipOval(
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: TravelPhoto(
                                url: guide.profileImage,
                                asset: TravelPhotos.guides,
                                label: guide.name,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  guide.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: OneUIColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  guide.specialization,
                  style: const TextStyle(
                    fontSize: 14,
                    color: OneUIColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFFFB300),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      guide.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (guide.experience > 0) ...[
                      const SizedBox(width: 16),
                      Text(
                        '${guide.experience} years experience',
                        style: const TextStyle(
                          fontSize: 13,
                          color: OneUIColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    if (guide.location != null &&
                        guide.location!.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: OneUIColors.primaryLight,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        guide.location!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: OneUIColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // About
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'About',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OneUIColors.textPrimaryLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              guide.bio == null || guide.bio!.isEmpty
                  ? '${guide.name} is a verified ComfyGo guide.'
                  : guide.bio!,
              style: const TextStyle(
                fontSize: 14,
                color: OneUIColors.textSecondaryLight,
                height: 1.6,
              ),
            ),
          ),

          // Languages
          if (guide.languages.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Languages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OneUIColors.textPrimaryLight,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: guide.languages.map((l) => CGChip(label: l)).toList(),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Rate + hire
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: OneUIColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Daily Rate',
                        style: TextStyle(
                          fontSize: 12,
                          color: OneUIColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        '৳${_fmtPrice(guide.dailyRate)}/day',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: OneUIColors.primaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                CGButton(
                  label: 'Hire Guide',
                  width: 130,
                  height: 44,
                  onPressed: () => context.push('/book/guide/${guide.id}'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _fmtPrice(double value) {
    final s = value.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }
}
