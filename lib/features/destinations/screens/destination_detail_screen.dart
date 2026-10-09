import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/one_ui_colors.dart';
import '../../../core/widgets/travel_widgets.dart';
import '../../../models/destination_model.dart';
import '../../../state/service_providers.dart';

class DestinationDetailScreen extends ConsumerStatefulWidget {
  final int id;
  const DestinationDetailScreen({super.key, required this.id});

  @override
  ConsumerState<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends ConsumerState<DestinationDetailScreen> {
  late Future<Destination?> _future;
  String _query = '';
  int _sortMode = 0;

  @override
  void initState() {
    super.initState();
    _future = _loadDestination();
  }

  Future<Destination?> _loadDestination() =>
      ref.read(destinationServiceProvider).getDestinationById(widget.id);

  Future<void> _showSearch() async {
    final query = await showDialog<String>(
      context: context,
      builder: (_) => _ActivitySearchDialog(initialValue: _query),
    );
    if (query != null && mounted) setState(() => _query = query.trim());
  }

  void _cycleSort() {
    setState(() => _sortMode = (_sortMode + 1) % 3);
    final label = switch (_sortMode) {
      1 => 'Price: low to high',
      2 => 'Rating: high to low',
      _ => 'Recommended order',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label), duration: const Duration(seconds: 1)),
    );
  }

  void _showLocation(Destination destination) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.location_on,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(destination.name),
        content: Text(
          '${destination.location}\n${destination.division}, Bangladesh',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      body: FutureBuilder<Destination?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final destination = snapshot.data;
          if (destination == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('This destination could not be loaded.'),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () =>
                          setState(() => _future = _loadDestination()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final activities = (destination.activities ?? []).where((activity) {
            final query = _query.toLowerCase();
            return query.isEmpty ||
                activity.name.toLowerCase().contains(query) ||
                activity.type.toLowerCase().contains(query);
          }).toList();
          if (_sortMode == 1) {
            activities.sort((a, b) => a.price.compareTo(b.price));
          } else if (_sortMode == 2) {
            activities.sort((a, b) => b.rating.compareTo(a.rating));
          }

          final destinationImage = destination.images.isEmpty
              ? null
              : destination.images.first;
          final destinationPhoto = TravelPhotos.forDestination(
            destination.name,
            destination.division,
          );
          return Column(
            children: [
              _DestinationHero(
                destination: destination,
                onSearch: _showSearch,
                onSort: _cycleSort,
                onLocation: () => _showLocation(destination),
              ),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Opacity(
                        opacity: .24,
                        child: TravelPhoto(
                          url: destinationImage,
                          asset: destinationPhoto,
                          label: '${destination.name} background',
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ColoredBox(
                        color: OneUIColors.backgroundLight.withValues(
                          alpha: .82,
                        ),
                      ),
                    ),
                    if (activities.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            _query.isEmpty
                                ? 'No activities available yet.'
                                : 'No activities match "$_query".',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 20),
                        itemCount: activities.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 0),
                        itemBuilder: (context, index) => _ActivityCard(
                          activity: activities[index],
                          fallbackImage: destinationImage,
                          fallbackAsset: destinationPhoto,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActivitySearchDialog extends StatefulWidget {
  const _ActivitySearchDialog({required this.initialValue});
  final String initialValue;

  @override
  State<_ActivitySearchDialog> createState() => _ActivitySearchDialogState();
}

class _ActivitySearchDialogState extends State<_ActivitySearchDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Search activities'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Activity name or type',
        prefixIcon: Icon(Icons.search),
      ),
      onSubmitted: (value) => Navigator.pop(context, value),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, _controller.text),
        child: const Text('Search'),
      ),
    ],
  );
}

class _DestinationHero extends StatelessWidget {
  const _DestinationHero({
    required this.destination,
    required this.onSearch,
    required this.onSort,
    required this.onLocation,
  });

  final Destination destination;
  final VoidCallback onSearch;
  final VoidCallback onSort;
  final VoidCallback onLocation;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final heroHeight = math
        .min(width * .92, math.max(190.0, size.height * .43))
        .toDouble();
    final imagePath = destination.images.isEmpty
        ? TravelPhotos.forDestination(destination.name, destination.division)
        : destination.images.first;
    final primary = Theme.of(context).colorScheme.primary;
    final safeTop = MediaQuery.paddingOf(context).top;

    return SizedBox(
      width: width,
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Hero(
              tag: imagePath,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: TravelPhoto(
                  url: destination.images.isEmpty
                      ? null
                      : destination.images.first,
                  asset: TravelPhotos.forDestination(
                    destination.name,
                    destination.division,
                  ),
                  label: destination.name,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: .28),
                  Colors.transparent,
                  Colors.black.withValues(alpha: .5),
                ],
                stops: const [0, .38, 1],
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            top: safeTop + 8,
            child: Row(
              children: [
                _HeroButton(
                  icon: Icons.arrow_back,
                  label: 'Back to destinations',
                  color: primary,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/destinations');
                    }
                  },
                ),
                const Spacer(),
                _HeroButton(
                  icon: Icons.search,
                  label: 'Search activities',
                  color: primary,
                  onPressed: onSearch,
                ),
                const SizedBox(width: 8),
                _HeroButton(
                  icon: Icons.sort,
                  label: 'Sort activities',
                  color: primary,
                  onPressed: onSort,
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 76,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (width * .085).clamp(25, 35),
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${destination.division}, Bangladesh',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .9),
                    fontSize: (width * .048).clamp(15, 20),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _HeroButton(
              icon: Icons.location_on,
              label: 'Show location',
              color: primary,
              onPressed: onLocation,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroButton extends StatelessWidget {
  const _HeroButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: label,
    onPressed: onPressed,
    icon: Icon(icon),
    style: IconButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      fixedSize: const Size(46, 46),
      padding: EdgeInsets.zero,
    ),
  );
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.fallbackImage,
    required this.fallbackAsset,
  });

  final DestinationActivity activity;
  final String? fallbackImage;
  final String fallbackAsset;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final compact = width < 420 || textScale > 1.2;
    final imageUrl = activity.imageUrl.isNotEmpty
        ? activity.imageUrl
        : fallbackImage;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 8),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _photo(imageUrl, double.infinity, 148),
                const SizedBox(height: 12),
                _ActivityInfo(activity: activity),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _photo(imageUrl, 112, 164),
                const SizedBox(width: 14),
                Expanded(child: _ActivityInfo(activity: activity)),
              ],
            ),
    );
  }

  Widget _photo(String? imageUrl, double width, double height) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: width,
      height: height,
      child: TravelPhoto(
        url: imageUrl,
        asset: fallbackAsset,
        label: activity.name,
      ),
    ),
  );
}

class _ActivityInfo extends StatelessWidget {
  const _ActivityInfo({required this.activity});
  final DestinationActivity activity;

  @override
  Widget build(BuildContext context) {
    final times = activity.startTimes;
    final firstTime = times.isNotEmpty ? times[0] : '9:00 AM';
    final secondTime = times.length > 1 ? times[1] : firstTime;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          activity.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 7),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 2,
          children: [
            Text(
              '\u09F3${activity.price.toStringAsFixed(0)}',
              style: textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'per pax',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          activity.type,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
        ),
        if (activity.rating > 0) ...[
          const SizedBox(height: 4),
          Text(
            List.filled(activity.rating.clamp(0, 5), '\u2B50 ').join(),
            maxLines: 1,
            overflow: TextOverflow.clip,
            style: const TextStyle(
              fontFamilyFallback: ['Noto Color Emoji', 'Segoe UI Emoji'],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _TimeChip(text: firstTime),
            _TimeChip(text: secondTime),
          ],
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    width: 88,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    ),
  );
}
