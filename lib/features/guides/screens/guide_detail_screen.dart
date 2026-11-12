// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/models.dart';
import '../../../state/service_providers.dart';

class GuideDetailScreen extends ConsumerStatefulWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
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
    final c = CgColors.of(context);
    return FutureBuilder<Guide?>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final guide = snapshot.data;
        return CgPageScaffold(
          bottom: guide == null
              ? null
              : Container(
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
                                'Daily Rate',
                                style: CgType.l12.copyWith(color: c.text2),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '৳${_fmtPrice(guide.dailyRate)}/day',
                                  style: CgType.t20.copyWith(
                                    color: c.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        CgPillButton(
                          width: 170,
                          height: 52,
                          onTap: () => context.push('/hotels'),
                          child: const Text('View Hotels'),
                        ),
                      ],
                    ),
                  ),
                ),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              CgPageTitle(
                title: 'Guide Profile',
                subtitle: guide?.specialization,
                onBack: () => goBack(context),
              ),
              if (loading)
                const CgLoadingState()
              else if (guide == null)
                CgErrorState(
                  message:
                      'This guide profile could not be loaded. '
                      'Check your connection and try again.',
                  onRetry: _retry,
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: c.gMint,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            guide.name.isEmpty
                                ? '?'
                                : guide.name[0].toUpperCase(),
                            style: CgType.h1Bold.copyWith(
                              fontSize: 32,
                              color: c.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          guide.name,
                          textAlign: TextAlign.center,
                          style: CgType.t20.copyWith(color: c.text),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          guide.specialization,
                          textAlign: TextAlign.center,
                          style: CgType.b14.copyWith(color: c.text2),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            CgTextPill(
                              label: '★ ${guide.rating.toStringAsFixed(1)}',
                            ),
                            if (guide.experience > 0)
                              CgTextPill(
                                label: '${guide.experience} yrs experience',
                                icon: Icons.workspace_premium_outlined,
                              ),
                            if (guide.location != null &&
                                guide.location!.isNotEmpty)
                              CgTextPill(
                                label: guide.location!,
                                icon: Icons.place_outlined,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: CgSection(title: 'About'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      guide.bio == null || guide.bio!.isEmpty
                          ? '${guide.name} is a verified ComfyGo guide.'
                          : guide.bio!,
                      style: CgType.b14.copyWith(
                        color: c.text2,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                if (guide.languages.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: CgSection(title: 'Languages'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final language in guide.languages)
                          CgTextPill(
                            label: language,
                            icon: Icons.translate_rounded,
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
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
