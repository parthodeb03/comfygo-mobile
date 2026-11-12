// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/models.dart';
import '../../../services/api_exception.dart';
import '../../../state/service_providers.dart';

/// Seat label for a 1-based seat number.
///
/// Numbers run down the columns: the first row of seats is `1A 1B | 2A 2B`,
/// the next is `3A 3B | 4A 4B`, and so on — each number is a seat pair and
/// `A`/`B` are its two seats.
String transportSeatLabel(int seatNumber) { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  final idx = seatNumber - 1;
  return '${idx ~/ 2 + 1}${idx.isEven ? 'A' : 'B'}';
}

/// Booking form for hotels and transport.
///
/// Reached from the "Book Now" buttons on the detail screens. Creates a real
/// booking through [BookingService] (server-side pricing) and hands the user
/// straight over to the payment screen.
class BookingFormScreen extends ConsumerStatefulWidget {
  final String type;
  final int itemId;

  const BookingFormScreen({
    super.key,
    required this.type,
    required this.itemId,
  });

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

  // Seat planning (transport only)
  final Set<int> _selectedSeats = {};
  Set<int> _occupiedSeats = {};

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
          item = await ref
              .read(hotelServiceProvider)
              .getHotelById(widget.itemId);
        case 'destination':
          item = await ref
              .read(destinationServiceProvider)
              .getDestinationById(widget.itemId);
        case 'guide':
          item = await ref
              .read(guideServiceProvider)
              .getGuideById(widget.itemId);
        case 'transport':
          item = await ref
              .read(transportServiceProvider)
              .getTransportById(widget.itemId);
        default:
          item = null;
      }
      if (!mounted) return;
      if (item is Transport) {
        _buildSeatMap(item);
      }
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
        return _unitPrice * max(1, _selectedSeats.length);
      case 'destination':
        return _unitPrice * _guests;
      default:
        return 0;
    }
  }

  // ── Seat map helpers (transport) ───────────────────────────────────────

  void _buildSeatMap(Transport transport) {
    final total = max(1, transport.totalSeats);
    final taken = (transport.totalSeats - transport.availableSeats)
        .clamp(0, total);
    final rnd = Random(transport.id * 7919 + total);
    final all = List<int>.generate(total, (i) => i + 1)..shuffle(rnd);
    _occupiedSeats = all.take(taken).toSet();
    _selectedSeats.clear();
  }

  /// Seat numbering matches [transportSeatLabel]: `1A 1B | 2A 2B` on the
  /// first row, `3A 3B | 4A 4B` on the next.
  String seatLabel(int seatNumber) => transportSeatLabel(seatNumber);

  List<String> get _selectedSeatLabels =>
      (_selectedSeats.toList()..sort())
          .map(seatLabel)
          .toList(growable: false);

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
    if (_isTransport && _selectedSeats.isEmpty) {
      _showSnack('Please choose at least one seat');
      return;
    }

    setState(() => _submitting = true);
    try {
      String? notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      if (_isTransport) {
        final seatNote = 'Seats: ${_selectedSeatLabels.join(', ')}';
        notes = notes == null ? seatNote : '$notes. $seatNote';
      }
      final booking = await ref
          .read(bookingServiceProvider)
          .createBooking(
            type: widget.type,
            itemId: widget.itemId,
            checkIn: _checkIn!,
            checkOut: _isTransport ? null : _checkOut,
            guests: _isTransport ? max(1, _selectedSeats.length) : _guests,
            notes: notes,
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
    if (mounted) showCgToast(context, message);
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);

    // Booking is available for hotels and transport only — tourist spots
    // and guides are for exploring, not booking.
    if (widget.type != 'hotel' && widget.type != 'transport') {
      return CgPageScaffold(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            CgPageTitle(title: 'Booking', onBack: () => goBack(context)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: CgCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: c.gMint,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.forest_outlined,
                        size: 30,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tourist spots are for exploring, not booking.',
                      textAlign: TextAlign.center,
                      style: CgType.t16.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book hotels and transport for your trip instead.',
                      textAlign: TextAlign.center,
                      style: CgType.b14.copyWith(color: c.text2),
                    ),
                    const SizedBox(height: 24),
                    CgPillButton(
                      onTap: () => context.go('/hotels'),
                      child: const Text('Browse Hotels'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    final canConfirm = !_loading && _item != null && !_submitting;

    return CgPageScaffold(
      bottom: Container(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Estimated total',
                      style: CgType.l12.copyWith(color: c.text2),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '৳${_fmtPrice(_estimate)}',
                        key: const Key('booking-estimate'),
                        style: CgType.t20.copyWith(color: c.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Opacity(
                opacity: canConfirm ? 1 : .55,
                child: CgPillButton(
                  key: const Key('confirm-booking'),
                  width: 170,
                  height: 52,
                  loading: _submitting,
                  onTap: canConfirm ? _submit : null,
                  child: const Text(
                    'Confirm Booking',
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
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          CgPageTitle(
            title: 'Book Now',
            subtitle:
                _loading || _item == null ? null : 'Step 1 of 2 · Details',
            onBack: () => goBack(context),
          ),
          if (_loading)
            const CgLoadingState()
          else if (_item == null)
            CgErrorState(
              message: 'Sorry, this item could not be loaded.',
              onRetry: _loadItem,
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _buildItemSummary(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: CgSection(title: 'When'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: CgCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      key: const Key('date-field'),
                      onTap: _submitting ? null : _pickDates,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: c.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _dateButtonText,
                                style: CgType.body15.copyWith(color: c.text),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: c.text2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_checkIn != null &&
                        !_isTransport &&
                        _checkOut != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          '$_nights night${_nights == 1 ? '' : 's'}',
                          style: CgType.l12.copyWith(color: c.text2),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: CgSection(
                title: _isTransport
                    ? 'Choose your seats  ·  ${_selectedSeats.length} selected'
                    : 'Guests',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _isTransport ? _buildSeatPicker() : _buildGuestsRow(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: CgTextField(
                key: const Key('booking-notes'),
                label: 'Notes (optional)',
                controller: _notesController,
                icon: Icons.edit_note_rounded,
                hint: 'Anything the host should know…',
                maxLines: 3,
                enabled: !_submitting,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Bus-style seat grid: two blocks of two seats with a central aisle.
  Widget _buildSeatPicker() {
    final c = CgColors.of(context);
    final transport = _item! as Transport;
    final total = max(1, transport.totalSeats);
    final freeCount = total - _occupiedSeats.length;
    final full = _selectedSeats.length >= freeCount;

    // Fixed block widths keep the aisle straight on a partial last row.
    const tile = 44.0;
    const tileGap = 8.0;
    const aisle = 26.0;

    Widget seatTile(int n) {
      final occupied = _occupiedSeats.contains(n);
      final selected = _selectedSeats.contains(n);
      final canTap = !occupied && (!selected && full ? false : true);
      final label = seatLabel(n);
      return GestureDetector(
        onTap: !canTap
            ? null
            : () => setState(() {
                if (!_selectedSeats.remove(n)) _selectedSeats.add(n);
              }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: tile,
          height: tile,
          decoration: BoxDecoration(
            gradient: selected ? c.gMain : null,
            color: occupied
                ? c.line
                : selected
                ? null
                : c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? c.primary
                  : occupied
                  ? c.line
                  : c.sage,
              width: selected ? 2 : 1.2,
            ),
          ),
          child: Center(
            child: occupied
                ? Icon(Icons.close_rounded, size: 15, color: c.text2)
                : Text(
                    label,
                    style: CgType.l12.copyWith(
                      fontWeight: FontWeight.w800,
                      color: selected ? c.onPrimary : c.text,
                    ),
                  ),
          ),
        ),
      );
    }

    Widget seatSlot(int n) =>
        n <= total ? seatTile(n) : const SizedBox(width: tile);

    Widget seatRow(int base) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: tile * 2 + tileGap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [seatSlot(base), seatSlot(base + 1)],
          ),
        ),
        const SizedBox(width: aisle),
        SizedBox(
          width: tile * 2 + tileGap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [seatSlot(base + 2), seatSlot(base + 3)],
          ),
        ),
      ],
    );

    Widget legendDot(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(width: 5),
        Text(label, style: CgType.l12.copyWith(color: c.text2)),
      ],
    );

    Widget legendSwatch({Gradient? gradient, Color? color, bool muted = false}) =>
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            gradient: gradient,
            color: muted ? c.line : color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: c.line),
          ),
        );

    return CgCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: c.gMint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  size: 17,
                  color: c.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Front of vehicle',
                  style: CgType.l12.copyWith(
                    fontWeight: FontWeight.w600,
                    color: c.text2,
                  ),
                ),
              ),
              Text(
                '$freeCount of $total free',
                style: CgType.l12.copyWith(
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              for (var row = 0; row < (total + 3) ~/ 4; row++)
                Padding(
                  padding: EdgeInsets.only(top: row == 0 ? 0 : 8),
                  child: seatRow(row * 4 + 1),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              legendDot(
                legendSwatch(color: c.surface),
                'Free',
              ),
              legendDot(legendSwatch(gradient: c.gMain), 'Selected'),
              legendDot(legendSwatch(muted: true), 'Taken'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemSummary() {
    final c = CgColors.of(context);
    return CgCard(
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
              switch (widget.type) {
                'hotel' => Icons.hotel_rounded,
                'guide' => Icons.person_rounded,
                'transport' => Icons.directions_bus_rounded,
                _ => Icons.location_on_rounded,
              },
              color: c.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CgType.t16.copyWith(color: c.text),
                ),
                if (_itemSubtitle.isNotEmpty)
                  Text(
                    _itemSubtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CgType.l12.copyWith(color: c.text2),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${_fmtPrice(_unitPrice)}',
                style: CgType.t16.copyWith(color: c.primary),
              ),
              Text(_priceLabel, style: CgType.l12.copyWith(color: c.text2)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuestsRow() {
    final c = CgColors.of(context);
    return CgCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(Icons.people_rounded, size: 18, color: c.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Guests',
              style: CgType.body15.copyWith(color: c.text),
            ),
          ),
          IconButton(
            key: const Key('guests-decrease'),
            onPressed: _submitting || _guests <= 1
                ? null
                : () => setState(() => _guests--),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: c.primary,
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$_guests',
              textAlign: TextAlign.center,
              style: CgType.t16.copyWith(color: c.text),
            ),
          ),
          IconButton(
            key: const Key('guests-increase'),
            onPressed: _submitting || _guests >= 20
                ? null
                : () => setState(() => _guests++),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: c.primary,
            visualDensity: VisualDensity.compact,
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
