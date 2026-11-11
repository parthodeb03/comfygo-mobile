// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/booking_model.dart';
import '../../../state/service_providers.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  @override
  void initState() {
    super.initState();
    // The provider loads on first watch; refresh explicitly so returning to
    // the tab always shows the latest status.
    Future.microtask(() => ref.read(bookingsProvider.notifier).loadBookings());
  }

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final data = ref.watch(bookingsProvider);
    final bookings = data.bookings;

    return Scaffold(
      backgroundColor: c.bg,
      body: CgBackground(
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: c.primary,
            onRefresh: () => ref.read(bookingsProvider.notifier).loadBookings(),
            child: ListView(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'My bookings',
                    style: CgType.h1Bold.copyWith(color: c.text),
                  ),
                ),
                const SizedBox(height: 16),
                if (data.isLoading && bookings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: CircularProgressIndicator(color: c.primary),
                    ),
                  )
                else if (bookings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.error == null
                              ? 'No bookings yet. Start exploring '
                                    'destinations!'
                              : 'Unable to load bookings right now.',
                          style: CgType.b14.copyWith(color: c.text2),
                        ),
                        if (data.error != null) ...[
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => ref
                                .read(bookingsProvider.notifier)
                                .loadBookings(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 40),
                              foregroundColor: c.primary,
                            ),
                            child: Text(
                              'Retry',
                              style: CgType.b14.copyWith(
                                fontWeight: FontWeight.w700,
                                color: c.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimationLimiter(
                      child: Column(
                        children: [
                          for (var i = 0; i < bookings.length; i++)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: i == bookings.length - 1 ? 0 : 12,
                              ),
                              child: AnimationConfiguration.staggeredList(
                                position: i,
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  verticalOffset: .04,
                                  curve: Curves.easeOutCubic,
                                  child: FadeInAnimation(
                                    curve: Curves.easeOutCubic,
                                    child: _BookingCard(
                                      key: ValueKey(bookings[i].id),
                                      booking: bookings[i],
                                    ),
                                  ),
                                ),
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
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPressable(
      onTap: () => context.push('/bookings/${booking.id}'),
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
              child: Icon(_iconFor(booking.status), size: 20, color: c.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _titleFor(booking),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.t16.copyWith(color: c.text),
                  ),
                  Text(
                    _dateRange(booking),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.l12.copyWith(color: c.text2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: c.mint,
                  borderRadius: BorderRadius.circular(CgRadii.pill),
                ),
                child: Text(
                  _statusLabel(booking.status),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CgType.l12.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: c.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Icons.check_rounded;
      case BookingStatus.completed:
        return Icons.star_rounded;
      case BookingStatus.cancelled:
        return Icons.close_rounded;
      case BookingStatus.pending:
        return Icons.schedule_rounded;
    }
  }

  static String _statusLabel(BookingStatus status) {
    final name = status.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  static String _titleFor(Booking booking) {
    if (booking.itemName.trim().isNotEmpty) return booking.itemName.trim();
    switch (booking.type) {
      case BookingType.hotel:
        return 'Hotel stay';
      case BookingType.transport:
        return 'Transport';
      case BookingType.guide:
        return 'Local guide';
      case BookingType.destination:
        return 'Destination trip';
    }
  }

  static String _dateRange(Booking booking) {
    final start = booking.checkIn;
    final end = booking.checkOut;
    if (end == null) return DateFormat('d MMM').format(start);
    if (start.month == end.month && start.year == end.year) {
      return '${start.day}–${end.day} ${DateFormat('MMM').format(start)}';
    }
    return '${DateFormat('d MMM').format(start)} – '
        '${DateFormat('d MMM').format(end)}';
  }
}
