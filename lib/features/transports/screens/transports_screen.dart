import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../state/service_providers.dart';

/// Bus / train / flight / car ticket search.
class TransportsScreen extends ConsumerStatefulWidget {
  const TransportsScreen({super.key});

  @override
  ConsumerState<TransportsScreen> createState() => _TransportsScreenState();
}

class _TransportsScreenState extends ConsumerState<TransportsScreen> {
  final _search = TextEditingController();
  String _type = 'All';
  bool _roundTrip = false;
  int _selectedDay = 1;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => ref
      .read(transportsProvider.notifier)
      .loadTransports(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
        type: _type == 'All' ? null : _type.toLowerCase(),
      );

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final data = ref.watch(transportsProvider);

    return CgPageScaffold(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Transport',
            subtitle: 'Where are you heading today?',
            onBack: () => goBack(context),
          ),

          // ─── One way / round trip ─────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.mint,
                borderRadius: BorderRadius.circular(CgRadii.pill),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TripPill(
                      label: 'One way',
                      selected: !_roundTrip,
                      onTap: () => setState(() => _roundTrip = false),
                    ),
                  ),
                  Expanded(
                    child: _TripPill(
                      label: 'Round trip',
                      selected: _roundTrip,
                      onTap: () => setState(() => _roundTrip = true),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Route card ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: CgCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: _RoutePoint(city: 'Dhaka', code: 'DAC'),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: c.gMain,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _roundTrip
                              ? Icons.sync_alt_rounded
                              : Icons.flight_rounded,
                          color: c.onPrimary,
                          size: 19,
                        ),
                      ),
                      const Expanded(
                        child: _RoutePoint(
                          city: 'Sylhet',
                          code: 'ZYL',
                          alignEnd: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CgPillButton(
                          onTap: _load,
                          height: 52,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded, size: 18),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Search',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CgOutlineButton(
                          onTap: () => _showRouteSearch(context),
                          height: 52,
                          child: const Text('Change'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Date strip ───────────────────────────────────────
          SizedBox(
            height: 88,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = DateTime.now().add(Duration(days: index));
                final selected = index == _selectedDay;
                return CgPressable(
                  onTap: () => setState(() => _selectedDay = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    width: 60,
                    decoration: BoxDecoration(
                      gradient: selected ? c.gMain : c.gCard,
                      borderRadius: BorderRadius.circular(CgRadii.card),
                      boxShadow: c.cardShadow,
                    ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ['S', 'M', 'T', 'W', 'T', 'F', 'S'][
                            day.weekday %
                            7],
                        style: CgType.l12.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected ? c.onPrimary : c.text2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.day}',
                        style: CgType.t20.copyWith(
                          fontSize: 18,
                          color: selected ? c.onPrimary : c.text,
                        ),
                      ),
                    ],
                  ),
                ),
                  ),
                );
              },
            ),
          ),

          // ─── Results heading ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: CgSection(
              title: '${data.transports.length} tickets found',
              actionLabel: _type == 'All' ? 'Filter' : _type,
              onAction: () => _showTypes(context),
            ),
          ),

          if (data.isLoading)
            const CgLoadingState()
          else if (data.error != null)
            CgErrorState(
              message: 'Unable to load tickets.',
              onRetry: _load,
            )
          else if (data.transports.isEmpty)
            CgEmptyState(
              icon: Icons.airline_seat_recline_normal_rounded,
              message: 'No tickets found. Try a different route or type.',
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  for (var i = 0; i < data.transports.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == data.transports.length - 1 ? 0 : 12,
                      ),
                      child: _TicketCard(
                        type: data.transports[i].type,
                        operatorName: data.transports[i].operatorName ??
                            data.transports[i].name,
                        from: data.transports[i].fromLocation,
                        to: data.transports[i].toLocation,
                        departure: data.transports[i].departureTime,
                        arrival: data.transports[i].arrivalTime ?? '—',
                        seats: data.transports[i].availableSeats,
                        price: data.transports[i].price,
                        onTap: () => context.push(
                          '/book/transport/${data.transports[i].id}',
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showRouteSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CgSheet(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Find a route or operator',
                style: CgType.t20.copyWith(color: CgColors.of(context).text),
              ),
              const SizedBox(height: 16),
              CgTextField(
                label: 'Route or operator',
                controller: _search,
                icon: Icons.search_rounded,
                hint: 'e.g. Dhaka, Sylhet, Green Line',
                textInputAction: TextInputAction.search,
                onSubmitted: (_) {
                  Navigator.pop(context);
                  _load();
                },
              ),
              const SizedBox(height: 16),
              CgPillButton(
                onTap: () {
                  Navigator.pop(context);
                  _load();
                },
                child: const Text('Search tickets'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTypes(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => CgSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by transport',
              style: CgType.t20.copyWith(color: CgColors.of(context).text),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                for (final type in _types)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: CgOutlineButton(
                        height: 44,
                        onTap: () {
                          setState(() => _type = type);
                          Navigator.pop(context);
                          _load();
                        },
                        child: Text(
                          type,
                          style: CgType.l12.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static const _types = ['All', 'Bus', 'Train', 'Flight', 'Car'];
}

class _TripPill extends StatelessWidget {
  const _TripPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? c.gMain : null,
          borderRadius: BorderRadius.circular(CgRadii.pill),
        ),
        child: Text(
          label,
          style: CgType.b14.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? c.onPrimary : c.text2,
          ),
        ),
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.city,
    required this.code,
    this.alignEnd = false,
  });

  final String city;
  final String code;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: CgType.h1Bold.copyWith(fontSize: 24, color: c.text),
        ),
        const SizedBox(height: 4),
        Text(city, style: CgType.l12.copyWith(color: c.text2)),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.type,
    required this.operatorName,
    required this.from,
    required this.to,
    required this.departure,
    required this.arrival,
    required this.seats,
    required this.price,
    required this.onTap,
  });

  final String type;
  final String operatorName;
  final String from;
  final String to;
  final String departure;
  final String arrival;
  final int seats;
  final double price;
  final VoidCallback onTap;

  static IconData _iconFor(String type) => switch (type.toLowerCase()) {
    'train' => Icons.train_rounded,
    'flight' => Icons.flight_rounded,
    'car' => Icons.directions_car_rounded,
    _ => Icons.directions_bus_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPressable(
      onTap: onTap,
      child: CgCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: c.gMint,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_iconFor(type), size: 21, color: c.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'OPERATOR',
                        style: CgType.l12.copyWith(
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                          color: c.text2,
                        ),
                      ),
                      Text(
                        operatorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CgType.t16.copyWith(color: c.text),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                CgTextPill(label: type.toUpperCase()),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    from,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.t16.copyWith(color: c.text),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: c.sage,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 16,
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: c.line,
                      ),
                      Icon(_iconFor(type), size: 15, color: c.sage),
                      Container(
                        width: 16,
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: c.line,
                      ),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: c.sage,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Text(
                    to,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.t16.copyWith(color: c.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    departure,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.l12.copyWith(color: c.text2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    arrival,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.l12.copyWith(color: c.text2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: c.line),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.event_seat_rounded,
                  size: 15,
                  color: c.text2,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$seats seats left',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.l12.copyWith(color: c.text2),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '৳${price.round()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.t20.copyWith(color: c.primary),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: c.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
