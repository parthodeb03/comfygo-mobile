import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/destination_model.dart';
import '../../../state/service_providers.dart';

/// Destination detail: activities, times and per-person pricing.
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

  void _retry() => setState(() => _future = _loadDestination());

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
    showCgToast(context, label);
  }

  void _showLocation(Destination destination) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final c = CgColors.of(dialogContext);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CgRadii.card),
          ),
          icon: Icon(Icons.place_rounded, color: c.primary),
          title: Text(
            destination.name,
            textAlign: TextAlign.center,
            style: CgType.t20.copyWith(color: c.text),
          ),
          content: Text(
            '${destination.location}\n${destination.division}, Bangladesh',
            textAlign: TextAlign.center,
            style: CgType.b14.copyWith(color: c.text2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: c.primary),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return FutureBuilder<Destination?>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final destination = snapshot.data;

        final activities = (destination?.activities ?? []).where((activity) {
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

        return CgPageScaffold(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              CgPageTitle(
                title: loading ? 'Destination' : (destination?.name ?? ''),
                subtitle: destination == null
                    ? null
                    : '${destination.location} · ${destination.division}, '
                          'Bangladesh',
                onBack: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/destinations');
                  }
                },
                trailing: destination == null
                    ? null
                    : CgIconAction(
                        icon: _sortMode == 1
                            ? Icons.south_rounded
                            : _sortMode == 2
                            ? Icons.star_rounded
                            : Icons.sort_rounded,
                        semanticLabel: 'Sort activities',
                        onTap: _cycleSort,
                      ),
              ),
              if (loading)
                const CgLoadingState()
              else if (destination == null)
                CgErrorState(
                  message: 'This destination could not be loaded.',
                  onRetry: _retry,
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: c.gMint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.explore_rounded,
                            size: 20,
                            color: c.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pick your activities',
                                style: CgType.t16.copyWith(color: c.text),
                              ),
                              Text(
                                _query.isEmpty
                                    ? 'Tap the search icon to filter'
                                    : 'Filtered by "$_query"',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: CgType.l12.copyWith(color: c.text2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        CgIconAction(
                          icon: Icons.search_rounded,
                          semanticLabel: 'Search activities',
                          onTap: _showSearch,
                        ),
                        const SizedBox(width: 8),
                        CgIconAction(
                          icon: Icons.place_outlined,
                          semanticLabel: 'Show location',
                          onTap: () => _showLocation(destination),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: CgSection(
                    title: activities.isEmpty
                        ? 'Activities'
                        : 'Activities · ${activities.length}',
                  ),
                ),
                if (activities.isEmpty)
                  CgEmptyState(
                    icon: Icons.hiking_outlined,
                    message: _query.isEmpty
                        ? 'No activities available yet.'
                        : 'No activities match "$_query".',
                  )
                else
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      children: [
                        for (var i = 0; i < activities.length; i++)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: i == activities.length - 1 ? 0 : 12,
                            ),
                            child: _ActivityCard(activity: activities[i]),
                          ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        );
      },
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
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return AlertDialog(
      backgroundColor: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(CgRadii.card),
      ),
      title: Text(
        'Search activities',
        style: CgType.t20.copyWith(color: c.text),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textInputAction: TextInputAction.search,
        style: CgType.b14.copyWith(color: c.text),
        decoration: InputDecoration(
          hintText: 'Activity name or type',
          hintStyle: CgType.b14.copyWith(color: c.text2),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: c.text2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(CgRadii.input),
          ),
        ),
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(foregroundColor: c.text2),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          style: TextButton.styleFrom(foregroundColor: c.primary),
          child: const Text('Search'),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity});

  final DestinationActivity activity;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final times = activity.startTimes;
    final firstTime = times.isNotEmpty ? times[0] : '9:00 AM';
    final secondTime = times.length > 1 ? times[1] : firstTime;

    return CgCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: c.gMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.terrain_rounded,
                  size: 20,
                  color: c.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: CgType.t16.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activity.type,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CgType.l12.copyWith(color: c.text2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (activity.rating > 0)
                CgTextPill(
                  label: '★ ${activity.rating}',
                  icon: Icons.star_rounded,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '৳${activity.price.toStringAsFixed(0)}',
                  style: CgType.t20.copyWith(color: c.primary),
                ),
              ),
              Flexible(
                child: Text(
                  'per pax',
                  textAlign: TextAlign.end,
                  style: CgType.l12.copyWith(color: c.text2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              CgTextPill(label: firstTime, icon: Icons.schedule_rounded),
              CgTextPill(label: secondTime, icon: Icons.schedule_rounded),
            ],
          ),
        ],
      ),
    );
  }
}
