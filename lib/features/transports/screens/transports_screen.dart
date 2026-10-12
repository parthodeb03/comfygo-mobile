import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/nature_background.dart';
import '../../../state/service_providers.dart';

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
    final data = ref.watch(transportsProvider);
    final theme = Theme.of(context);
    // Theme-aware ink for text and icons (deep green in light, cream in dark).
    final dark = AppColors.textPrimary(context);
    // Solid nature-green fill for shapes that carry white content.
    const solid = AppColors.brandGreen;
    final fieldFill = AppColors.surfaceVariant(context);
    final lime = theme.colorScheme.primary;
    final cream = AppColors.background(context);
    return Scaffold(
      backgroundColor: cream,
      body: PhotoBackground.wrap(
        child: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => goBack(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: fieldFill,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TripPill(
                                  label: 'One way',
                                  selected: !_roundTrip,
                                  onTap: () =>
                                      setState(() => _roundTrip = false),
                                ),
                              ),
                              Expanded(
                                child: _TripPill(
                                  label: 'Round trip',
                                  selected: _roundTrip,
                                  onTap: () =>
                                      setState(() => _roundTrip = true),
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
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _RoutePoint(
                                city: 'Dhaka',
                                code: 'DAC',
                                alignEnd: false,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              children: [
                                Row(
                                  children: List.generate(
                                    3,
                                    (_) => Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: solid,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: solid,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(
                                    Icons.flight_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(
                                    3,
                                    (_) => Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: solid,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _RoutePoint(
                                city: 'Sylhet',
                                code: 'ZYL',
                                alignEnd: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _load,
                                icon: const Icon(
                                  Icons.search_rounded,
                                  size: 18,
                                ),
                                label: const Text('Searching'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: solid,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showRouteSearch(context),
                                icon: const Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 18,
                                ),
                                label: const Text('Change'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: fieldFill,
                                  foregroundColor: dark,
                                  side: BorderSide.none,
                                  shape: const StadiumBorder(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _InfoPill(
                        icon: Icons.calendar_month_rounded,
                        label: 'Today',
                      ),
                      const SizedBox(width: 8),
                      const _InfoPill(
                        icon: Icons.event_rounded,
                        label: 'October, 2026',
                      ),
                      const SizedBox(width: 8),
                      const _InfoPill(
                        icon: Icons.people_alt_rounded,
                        label: '2',
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 83,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final day = DateTime.now().add(Duration(days: index));
                      final selected = index == _selectedDay;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDay = index),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            color: selected ? lime : fieldFill,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                [
                                  'S',
                                  'M',
                                  'T',
                                  'W',
                                  'T',
                                  'F',
                                  'S',
                                ][day.weekday % 7],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected
                                      ? theme.colorScheme.onPrimary.withValues(
                                          alpha: .75,
                                        )
                                      : dark.withValues(alpha: .65),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? theme.colorScheme.onPrimary
                                      : dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${data.transports.length} Tickets found',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                      _CircleButton(
                        icon: Icons.tune_rounded,
                        onTap: () => _showTypes(context),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: data.isLoading
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      )
                    : data.error != null || data.transports.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Text(
                              data.error != null
                                  ? 'Unable to load tickets.'
                                  : 'No tickets found.',
                              style: TextStyle(
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final item = data.transports[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _TicketCard(
                              type: item.type,
                              operatorName: item.operatorName ?? item.name,
                              from: item.fromLocation,
                              to: item.toLocation,
                              departure: item.departureTime,
                              arrival: item.arrivalTime ?? '—',
                              seats: item.availableSeats,
                              price: item.price,
                              onTap: () =>
                                  context.push('/book/transport/${item.id}'),
                            ),
                          );
                        }, childCount: data.transports.length),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRouteSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface(context),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          24,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Find a route or operator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Dhaka, Sylhet, Green Line',
                filled: true,
                fillColor: AppColors.inputFill(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) {
                Navigator.pop(context);
                _load();
              },
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _load();
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: const StadiumBorder(),
              ),
              child: const Text('Search tickets'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypes(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Wrap(
          spacing: 9,
          runSpacing: 4,
          children: _types
              .map(
                (type) => ChoiceChip(
                  label: Text(type),
                  selected: _type == type,
                  showCheckmark: false,
                  onSelected: (_) {
                    setState(() => _type = type);
                    Navigator.pop(context);
                    _load();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  static const _types = ['All', 'Bus', 'Train', 'Flight', 'Car'];
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.surface(context),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Icon(icon, color: AppColors.textPrimary(context), size: 21),
      ),
    ),
  );
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected
              ? Theme.of(context).colorScheme.onPrimary
              : AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    ),
  );
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.city,
    required this.code,
    required this.alignEnd,
  });
  final String city;
  final String code;
  final bool alignEnd;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        code,
        style: TextStyle(
          fontSize: 24,
          height: 1,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary(context),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        city,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary(context),
        ),
      ),
    ],
  );
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.textPrimary(context)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    ),
  );
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
    final logoBg = AppColors.greenSoft(context);
    final logoFg = AppColors.accentGreen(context);
    final hint = AppColors.textSecondary(context);
    final strong = AppColors.textPrimary(context);
    return Material(
      color: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: BorderSide(color: AppColors.divider(context), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Operator: badge on the left, name in its own slot ──
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: logoBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_iconFor(type), color: logoFg, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OPERATOR',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                            color: hint,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          operatorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: strong,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // ─── Route ──────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Text(
                      from,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: strong,
                      ),
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
                            color: logoFg,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: AppColors.divider(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Icon(_iconFor(type), size: 16, color: logoFg),
                        Container(
                          width: 18,
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: AppColors.divider(context),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: logoFg,
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: strong,
                      ),
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
                      style: TextStyle(fontSize: 12.5, color: hint),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      arrival,
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: hint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Container(height: 1, color: AppColors.divider(context)),
              const SizedBox(height: 11),
              // ─── Seats + price ──────────────────────────────────
              Row(
                children: [
                  Icon(Icons.event_seat_rounded, size: 15, color: hint),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$seats seats left',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: hint),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'BDT ${price.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accentGreen(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.accentGreen(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
