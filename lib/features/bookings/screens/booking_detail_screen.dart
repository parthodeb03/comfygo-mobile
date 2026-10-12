import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel booking?'),
        content: const Text(
          'Your booking will be cancelled and any reserved availability '
          'will be released. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Cancel Booking',
              style: TextStyle(color: OneUIColors.error),
            ),
          ),
        ],
      ),
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
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontSize: 13)),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => goBack(context),
        ),
        title: const Text('Booking Details'),
      ),
      body: NatureBackground.wrap(child: FutureBuilder<Booking?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final booking = snapshot.data;
          if (booking == null) {
            return TravelEmpty(
              message: 'This booking could not be loaded. '
                  'Check your connection and try again.',
              onRetry: _refresh,
            );
          }
          return _buildContent(booking);
        },
      )),
    );
  }

  Widget _buildContent(Booking booking) {
    final statusLabel = _statusLabel(booking.status);
    final canPay = booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;
    final canCancel = booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor(statusLabel).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CGStatusBadge(
                  label: statusLabel,
                  color: _getStatusColor(statusLabel),
                ),
                const SizedBox(height: 12),
                Text(
                  booking.itemName.isEmpty
                      ? 'Booking #${booking.id}'
                      : booking.itemName,
                  style:  TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Booking info
          _buildSection('Booking Information', [
            _buildRow('Booking ID', '#${booking.id}'),
            _buildRow('Type', _typeLabel(booking.type)),
            _buildRow('Check-in', _fmtDate(booking.checkIn)),
            if (booking.checkOut != null)
              _buildRow('Check-out', _fmtDate(booking.checkOut!)),
            _buildRow('Guests', '${booking.guests}'),
            _buildRow('Notes', booking.notes ?? 'None'),
          ]),

          const SizedBox(height: 16),

          // Price summary — total is computed server-side
          _buildSection('Price Summary', [
            _buildRow('Total', '৳${_fmtPrice(booking.totalPrice)}', isBold: true),
          ]),

          const SizedBox(height: 16),

          CGButton(
            key: const Key('download-invoice'),
            label: 'Download Invoice (PDF)',
            icon: Icons.picture_as_pdf_outlined,
            isOutlined: true,
            onPressed: () => _downloadInvoice(booking),
          ),

          const SizedBox(height: 24),

          // Actions
          if (canPay || canCancel)
            Row(
              children: [
                if (canPay)
                  Expanded(
                    child: CGButton(
                      label: 'Pay Now',
                      onPressed: () => context.push('/payments/${booking.id}'),
                    ),
                  ),
                if (canPay && canCancel) const SizedBox(width: 12),
                if (canCancel)
                  Expanded(
                    child: CGButton(
                      label: 'Cancel',
                      isOutlined: true,
                      isLoading: _cancelling,
                      onPressed: _cancelling ? null : _confirmCancel,
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:  TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold
                    ? AppColors.primary(context)
                    : AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OneUIColors.statusPending;
      case 'confirmed':
        return OneUIColors.statusConfirmed;
      case 'cancelled':
        return OneUIColors.statusCancelled;
      case 'completed':
        return OneUIColors.statusCompleted;
      default:
        return Colors.grey;
    }
  }

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
