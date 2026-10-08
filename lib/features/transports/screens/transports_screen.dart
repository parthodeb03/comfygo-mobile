import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
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
    final dark = const Color(0xFF20271A);
    final lime = const Color(0xFFB6CC35);
    final cream = AppColors.background(context);
    return Scaffold(
      backgroundColor: cream,
      body: SafeArea(
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
                      onTap: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EDDF),
                          borderRadius: BorderRadius.circular(30),
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
                    color: const Color(0xFFE5E6CF),
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
                                      color: dark,
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
                                  color: dark,
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
                                      color: dark,
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
                              icon: const Icon(Icons.search_rounded, size: 18),
                              label: const Text('Searching'),
                              style: FilledButton.styleFrom(
                                backgroundColor: dark,
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
                                backgroundColor: Colors.white,
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
                    const _InfoPill(icon: Icons.people_alt_rounded, label: '2'),
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
                          color: selected ? lime : const Color(0xFFE9E6D8),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ['S', 'M', 'T', 'W', 'T', 'F', 'S'][day.weekday %
                                  7],
                              style: TextStyle(
                                fontSize: 12,
                                color: dark.withValues(alpha: .65),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: dark,
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
    );
  }

  void _showRouteSearch(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF3F0E6),
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
            const Text(
              'Find a route or operator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF20271A),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _search,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Dhaka, Sylhet, Green Line',
                filled: true,
                fillColor: Colors.white,
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
                backgroundColor: const Color(0xFFB6CC35),
                foregroundColor: const Color(0xFF20271A),
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
      backgroundColor: const Color(0xFFF3F0E6),
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
    color: Colors.white,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: SizedBox(
        width: 46,
        height: 46,
        child: Icon(icon, color: const Color(0xFF20271A), size: 21),
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
        color: selected ? const Color(0xFF20271A) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.white : const Color(0xFF20271A),
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
        style: const TextStyle(
          fontSize: 24,
          height: 1,
          fontWeight: FontWeight.w800,
          color: Color(0xFF20271A),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        city,
        style: const TextStyle(fontSize: 12, color: Color(0xFF66695E)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF20271A)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF20271A),
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
    required this.operatorName,
    required this.from,
    required this.to,
    required this.departure,
    required this.arrival,
    required this.seats,
    required this.price,
    required this.onTap,
  });
  final String operatorName;
  final String from;
  final String to;
  final String departure;
  final String arrival;
  final int seats;
  final double price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(26),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 176),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 70,
                child: ColoredBox(
                  color: const Color(0xFFB6CC35),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      RotatedBox(
                        quarterTurns: 3,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            operatorName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              letterSpacing: 1.3,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF66721B),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 13,
                        child: Icon(
                          Icons.flight_rounded,
                          size: 27,
                          color: Color(0xFF20271A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 14, 15, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              from,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF20271A),
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.flight_rounded,
                            size: 21,
                            color: Color(0xFF20271A),
                          ),
                          Expanded(
                            child: Text(
                              to,
                              maxLines: 1,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF20271A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              departure,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF55584E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              arrival,
                              maxLines: 2,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF55584E),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(height: 1, color: const Color(0xFFEAE8DF)),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$seats seats left',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF66695E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'BDT ${price.toStringAsFixed(0)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF20271A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
