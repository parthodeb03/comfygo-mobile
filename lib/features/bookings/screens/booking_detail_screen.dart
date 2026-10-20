import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/models.dart';
import '../../../services/invoice_pdf.dart';
import '../../../state/service_providers.dart';

class BookingDetailScreen extends ConsumerStatefulWidget {
  final int id;

  const BookingDetailScreen({super.key, required this.id});

  @override
  ConsumerState<BookingDetailScreen> createState() =>
      _BookingDetailScreenState();
}

class _BookingDetailScreenState extends ConsumerState<BookingDetailScreen> {
  late Future<Booking?> _future;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<Booking?> _fetch() =>
      ref.read(bookingServiceProvider).getBookingById(widget.id);

  void _refresh() => setState(() => _future = _fetch());

  // ── Cancel flow ─────────────────────────────────────────────────────────

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final c = CgColors.of(dialogContext);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CgRadii.card),
          ),
          title: Text(
            'Cancel booking?',
            style: CgType.t20.copyWith(color: c.text),
          ),
          content: Text(
            'Your booking will be cancelled and any reserved availability '
            'will be released. This cannot be undone.',
            style: CgType.b14.copyWith(color: c.text2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: c.text2),
              child: const Text('Keep Booking'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: CgColorConstants.danger,
              ),
              child: const Text('Cancel Booking'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      final updated = await ref
          .read(bookingServiceProvider)
          .cancelBooking(widget.id);
      if (!mounted) return;

      if (updated == null) {
        _showSnack('Could not cancel the booking. Please try again.');
      } else {
        // Keep the bookings list in sync with the server
        ref.read(bookingsProvider.notifier).loadBookings();
        _showSnack('Booking cancelled');
      }
      _refresh();
    } catch (_) {
      if (mounted) _showSnack('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  Future<void> _downloadInvoice(Booking booking) async {
    try {
      await InvoicePdf.share(booking);
    } catch (_) {
      if (mounted) {
        _showSnack('Could not create the invoice. Please try again.');
      }
    }
  }

  void _showSnack(String message) {
    if (mounted) showCgToast(context, message);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return FutureBuilder<Booking?>(
      future: _future,
      builder: (context, snapshot) {
        final loading = snapshot.connectionState != ConnectionState.done;
        final booking = snapshot.data;
        final canAct =
            booking != null &&
            (booking.status == BookingStatus.pending ||
                booking.status == BookingStatus.confirmed);

        return CgPageScaffold(
          bottom: !canAct
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
                          child: CgOutlineButton(
                            height: 52,
                            onTap: _cancelling ? null : _confirmCancel,
                            child: const Text(
                              'Cancel',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CgPillButton(
                            height: 52,
                            loading: _cancelling,
                            onTap: () =>
                                context.push('/payments/${booking.id}'),
                            child: const Text(
                              'Pay Now',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              CgPageTitle(
                title: 'Booking Details',
                onBack: () => goBack(context),
              ),
              if (loading)
                const CgLoadingState()
              else if (booking == null)
                CgErrorState(
                  message:
                      'This booking could not be loaded. '
                      'Check your connection and try again.',
                  onRetry: _refresh,
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: c.gMint,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _statusIcon(booking.status),
                            size: 28,
                            color: c.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CgTextPill(label: _statusLabel(booking.status)),
                        const SizedBox(height: 10),
                        Text(
                          booking.itemName.isEmpty
                              ? 'Booking #${booking.id}'
                              : booking.itemName,
                          textAlign: TextAlign.center,
                          style: CgType.t20.copyWith(color: c.text),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: CgSection(title: 'Booking Information'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        CgInfoRow(label: 'Booking ID', value: '#${booking.id}'),
                        CgInfoRow(
                          label: 'Type',
                          value: _typeLabel(booking.type),
                        ),
                        CgInfoRow(
                          label: 'Check-in',
                          value: _fmtDate(booking.checkIn),
                        ),
                        if (booking.checkOut != null)
                          CgInfoRow(
                            label: 'Check-out',
                            value: _fmtDate(booking.checkOut!),
                          ),
                        CgInfoRow(label: 'Guests', value: '${booking.guests}'),
                        CgInfoRow(
                          label: 'Notes',
                          value: booking.notes ?? 'None',
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: CgSection(title: 'Price Summary'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: CgCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total',
                            style: CgType.b14.copyWith(color: c.text2),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '৳${_fmtPrice(booking.totalPrice)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CgType.h1Bold.copyWith(
                              fontSize: 24,
                              color: c.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: CgOutlineButton(
                    key: const Key('download-invoice'),
                    onTap: () => _downloadInvoice(booking),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_outlined, size: 18),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Download Invoice (PDF)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static IconData _statusIcon(BookingStatus status) => switch (status) {
    BookingStatus.pending => Icons.hourglass_bottom_rounded,
    BookingStatus.confirmed => Icons.verified_rounded,
    BookingStatus.cancelled => Icons.event_busy_rounded,
    BookingStatus.completed => Icons.check_circle_rounded,
  };

  static String _statusLabel(BookingStatus status) {
    final name = status.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  static String _typeLabel(BookingType type) {
    switch (type) {
      case BookingType.hotel:
        return 'Hotel';
      case BookingType.transport:
        return 'Transport';
      case BookingType.guide:
        return 'Guide';
      case BookingType.destination:
        return 'Destination';
    }
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
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
