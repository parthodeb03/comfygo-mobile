import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../services/api_exception.dart';
import '../../../state/service_providers.dart';

/// Booking form for hotels, destinations, guides and transport.
///
/// Reached from the "Book Now" buttons on the detail screens. Creates a real
/// booking through [BookingService] (server-side pricing) and hands the user
/// straight over to the payment screen.
class BookingFormScreen extends ConsumerStatefulWidget {
  final String type;
  final int itemId;

  const BookingFormScreen({super.key, required this.type, required this.itemId});

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  Object? _item;
  bool _loading = true;
  bool _submitting = false;

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  final _notesController = TextEditingController();

  bool get _isTransport => widget.type == 'transport';

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    setState(() {
      _loading = true;
      _item = null;
    });
    try {
      Object? item;
      switch (widget.type) {
        case 'hotel':
          item = await ref.read(hotelServiceProvider).getHotelById(widget.itemId);
        case 'destination':
          item = await ref
              .read(destinationServiceProvider)
              .getDestinationById(widget.itemId);
        case 'guide':
          item = await ref.read(guideServiceProvider).getGuideById(widget.itemId);
        case 'transport':
          item = await ref
              .read(transportServiceProvider)
              .getTransportById(widget.itemId);
        default:
          item = null;
      }
      if (!mounted) return;
      setState(() {
        _item = item;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ── Item accessors ──────────────────────────────────────────────────────

  String get _itemName => switch (_item) {
    final Hotel h => h.name,
    final Destination d => d.name,
    final Guide g => g.name,
    final Transport t => t.name,
    _ => 'Booking',
  };

  String get _itemSubtitle => switch (_item) {
    final Hotel h => h.location,
    final Destination d => d.location,
    final Guide g => g.specialization,
    final Transport t => '${t.fromLocation} → ${t.toLocation}',
    _ => '',
  };

  double get _unitPrice => switch (_item) {
    final Hotel h => h.pricePerNight,
    final Destination d => d.price,
    final Guide g => g.dailyRate,
    final Transport t => t.price,
    _ => 0,
  };

  String get _priceLabel => switch (widget.type) {
    'hotel' => 'per night',
    'guide' => 'per day',
    'transport' => 'per seat',
    _ => 'per person',
  };

  // ── Estimate (mirrors the server-side calculation) ──────────────────────

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 1;
    final days = _checkOut!.difference(_checkIn!).inDays;
    return days < 1 ? 1 : days;
  }

  double get _estimate {
    if (_item == null) return 0;
    switch (widget.type) {
      case 'hotel':
        return _unitPrice * _nights;
      case 'guide':
        return _unitPrice * _nights;
      case 'transport':
        return _unitPrice * _guests;
      case 'destination':
        return _unitPrice * _guests;
      default:
        return 0;
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _pickDates() async {
    if (_isTransport) {
      final picked = await showDatePicker(
        context: context,
        initialDate: _checkIn ?? DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) setState(() => _checkIn = picked);
      return;
    }

    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _checkIn != null
          ? DateTimeRange(start: _checkIn!, end: _checkOut ?? _checkIn!)
          : null,
    );
    if (range != null) {
      setState(() {
        _checkIn = range.start;
        _checkOut = range.end;
      });
    }
  }

  String get _dateButtonText {
    if (_checkIn == null) return 'Select dates';
    if (_isTransport) return _fmtDate(_checkIn!);
    if (_checkOut == null) return '${_fmtDate(_checkIn!)} — …';
    return '${_fmtDate(_checkIn!)} — ${_fmtDate(_checkOut!)}';
  }

  Future<void> _submit() async {
    if (_submitting || _item == null) return;

    if (_checkIn == null) {
      _showSnack('Please select your dates first');
      return;
    }
    if (!_isTransport && _checkOut == null) {
      _showSnack('Please select a date range');
      return;
    }

    setState(() => _submitting = true);
    try {
      final booking = await ref.read(bookingServiceProvider).createBooking(
        type: widget.type,
        itemId: widget.itemId,
        checkIn: _checkIn!,
        checkOut: _isTransport ? null : _checkOut,
        guests: _guests,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      if (booking == null) {
        _showSnack('Could not create the booking. Please try again.');
      } else {
        // Keep the bookings list fresh for the next screen
        ref.read(bookingsProvider.notifier).loadBookings();
        context.pushReplacement('/payments/${booking.id}');
      }
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message);
    } catch (_) {
      if (mounted) _showSnack('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
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

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          key: const Key('booking-form-back'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Book Now'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _item == null
          ? TravelEmpty(
              message: 'Sorry, this item could not be loaded.',
              onRetry: _loadItem,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildItemSummary(),
                  const SizedBox(height: 20),
                  _buildSection(
                    'When',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          key: const Key('date-field'),
                          onTap: _submitting ? null : _pickDates,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: OneUIColors.surfaceVariantLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: OneUIColors.primaryLight,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _dateButtonText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: OneUIColors.textPrimaryLight,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: OneUIColors.textSecondaryLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_checkIn != null && !_isTransport && _checkOut != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '$_nights night${_nights == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: OneUIColors.textSecondaryLight,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection('Guests', _buildGuestsRow()),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Notes (optional)',
                    TextField(
                      key: const Key('booking-notes'),
                      controller: _notesController,
                      maxLines: 3,
                      maxLength: 300,
                      enabled: !_submitting,
                      decoration: InputDecoration(
                        hintText: 'Anything the host should know…',
                        counterText: '',
                        filled: true,
                        fillColor: OneUIColors.surfaceVariantLight,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildEstimateBox(),
                  const SizedBox(height: 24),
                  CGButton(
                    key: const Key('confirm-booking'),
                    label: 'Confirm Booking',
                    isLoading: _submitting,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildItemSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OneUIColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OneUIColors.dividerLight, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: OneUIColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              switch (widget.type) {
                'hotel' => Icons.hotel_rounded,
                'guide' => Icons.person_rounded,
                'transport' => Icons.directions_bus_rounded,
                _ => Icons.location_on_rounded,
              },
              color: OneUIColors.primaryLight,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: OneUIColors.textPrimaryLight,
                  ),
                ),
                if (_itemSubtitle.isNotEmpty)
                  Text(
                    _itemSubtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: OneUIColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${_fmtPrice(_unitPrice)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: OneUIColors.primaryLight,
                ),
              ),
              Text(
                _priceLabel,
                style: const TextStyle(
                  fontSize: 11,
                  color: OneUIColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: OneUIColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildGuestsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: OneUIColors.surfaceVariantLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_rounded,
            size: 18,
            color: OneUIColors.primaryLight,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Guests',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: OneUIColors.textPrimaryLight,
              ),
            ),
          ),
          IconButton(
            key: const Key('guests-decrease'),
            onPressed: _submitting || _guests <= 1
                ? null
                : () => setState(() => _guests--),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: OneUIColors.primaryLight,
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$_guests',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: OneUIColors.textPrimaryLight,
              ),
            ),
          ),
          IconButton(
            key: const Key('guests-increase'),
            onPressed: _submitting || _guests >= 20
                ? null
                : () => setState(() => _guests++),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: OneUIColors.primaryLight,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OneUIColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Estimated total',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: OneUIColors.textPrimaryLight,
            ),
          ),
          Text(
            '৳${_fmtPrice(_estimate)}',
            key: const Key('booking-estimate'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: OneUIColors.primaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // ── Formatting ──────────────────────────────────────────────────────────

  static String _fmtPrice(double value) {
    final rounded = value.round();
    final s = rounded.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
