// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../data/comfy_destinations.dart';
import '../../../state/saved_destinations_provider.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.id});

  final int id;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  String _tab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final item = comfyDestinationById(widget.id);
    if (item == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(
          child: Text(
            'Destination not found',
            style: CgType.b14.copyWith(color: c.text2),
          ),
        ),
      );
    }

    final saved = ref.watch(savedDestinationsProvider).contains(item.id);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: c.bg,
      body: CgBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              ListView(
                padding: EdgeInsets.only(top: 16, bottom: 116 + bottomInset),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: SizedBox(
                            height: 300,
                            width: double.infinity,
                            child: CgImage(path: item.cover, cacheWidth: 900),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          top: 14,
                          child: CgRoundButton(
                            size: 40,
                            iconSize: 18,
                            icon: Icons.arrow_back_ios_new_rounded,
                            semanticLabel: 'Back',
                            onTap: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                          ),
                        ),
                        Positioned(
                          right: 14,
                          top: 14,
                          child: CgRoundButton(
                            size: 40,
                            iconSize: 18,
                            icon: saved
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: saved ? CgColorConstants.heart : c.text,
                            semanticLabel: saved
                                ? 'Remove from saved'
                                : 'Save destination',
                            onTap: () => ref
                                .read(savedDestinationsProvider.notifier)
                                .toggle(item.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CgCard(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CgType.t20.copyWith(color: c.text),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: c.mint,
                                borderRadius: BorderRadius.circular(
                                  CgRadii.pill,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 13,
                                    color: CgColorConstants.star,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.reviews,
                                    style: CgType.l12.copyWith(color: c.text),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoItem(
                                icon: Icons.place_outlined,
                                label: 'Location',
                                value: item.region,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: _InfoItem(
                                icon: Icons.schedule_rounded,
                                label: 'Open',
                                value: '24H',
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: _InfoItem(
                                icon: Icons.wb_sunny_outlined,
                                label: 'Temp',
                                value: '28°C',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _Tabs(
                          value: _tab,
                          onChanged: (value) => setState(() => _tab = value),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _TabContent(
                            key: ValueKey(_tab),
                            tab: _tab,
                            item: item,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gallery',
                          style: CgType.t16.copyWith(color: c.text),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 62,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: item.images.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 84,
                                height: 62,
                                child: CgImage(
                                  path: item.images[index],
                                  cacheWidth: 180,
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 92 + bottomInset,
                  padding: EdgeInsets.only(bottom: bottomInset),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(CgRadii.nav),
                    ),
                    boxShadow: c.navShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trip Cost',
                                style: CgType.l12.copyWith(color: c.text2),
                              ),
                              Text(
                                'Total: ${item.priceLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CgType.t16.copyWith(
                                  fontSize: 18,
                                  color: c.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        CgPillButton(
                          width: 180,
                          semanticLabel: 'Book now',
                          onTap: () =>
                              showCgToast(context, 'Booking request sent'),
                          child: const Text('Book Now'),
                        ),
                      ],
                    ),
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

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: c.mint, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: c.primary),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CgType.l12.copyWith(fontSize: 11, color: c.text2),
              ),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CgType.t16.copyWith(fontSize: 14, color: c.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _tabs = ['Overview', 'Details', 'Reviews'];

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(height: 1, color: c.line),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final tab in _tabs)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(tab),
                    child: IntrinsicWidth(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              tab,
                              style: CgType.b14.copyWith(
                                fontWeight: FontWeight.w600,
                                color: value == tab ? c.text : c.text2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: 2,
                              decoration: BoxDecoration(
                                color: value == tab
                                    ? c.accent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _TabContent extends StatelessWidget {
  const _TabContent({super.key, required this.tab, required this.item});

  final String tab;
  final ComfyDestination item;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final style = CgType.b14.copyWith(color: c.text2);
    final bold = CgType.b14.copyWith(
      color: c.text,
      fontWeight: FontWeight.w700,
    );

    switch (tab) {
      case 'Details':
        return Text.rich(
          TextSpan(
            style: style,
            children: [
              const TextSpan(text: 'Duration: 3 days, 2 nights\n'),
              const TextSpan(
                text:
                    'Includes: local guide, hotel stay, transport and meals\n',
              ),
              const TextSpan(text: 'Best season: October to March'),
            ],
          ),
        );
      case 'Reviews':
        return Text.rich(
          TextSpan(
            style: style,
            children: [
              const TextSpan(text: '“Calm, green and beautifully organised.” '),
              TextSpan(text: 'Nusrat', style: bold),
              const TextSpan(text: '\n“Our guide knew every trail.” '),
              TextSpan(text: 'Tanvir', style: bold),
            ],
          ),
        );
      case 'Overview':
      default:
        return Text(item.description, style: style);
    }
  }
}
