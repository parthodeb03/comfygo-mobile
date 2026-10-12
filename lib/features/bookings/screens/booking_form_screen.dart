import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/theme/one_ui_colors.dart';
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

  String seatLabel(int seatNumber) {
    const cols = ['A', 'B', 'C', 'D'];
    final idx = seatNumber - 1;
    return '${idx ~/ 4 + 1}${cols[idx % 4]}';
  }

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
      final booking = await ref.read(bookingServiceProvider).createBooking(
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
    // Booking is available for hotels and transport only — tourist spots
    // and guides are for exploring, not booking.
    if (widget.type != 'hotel' && widget.type != 'transport') {
      return Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(title: const Text('Booking')),
        body: NatureBackground.wrap(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.forest_outlined,
                    size: 64,
                    color: AppColors.primary(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tourist spots are for exploring, not booking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Book hotels and transport for your trip instead.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CGButton(
                    label: 'Browse Hotels',
                    width: 220,
                    onPressed: () => context.go('/hotels'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          key: const Key('booking-form-back'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => goBack(context),
        ),
        title: const Text('Book Now'),
      ),
      body: NatureBackground.wrap(child: _loading
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
                              color: AppColors.surfaceVariant(context),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                 Icon(
                                  Icons.calendar_today_rounded,
                                  size: 18,
                                  color: AppColors.primary(context),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _dateButtonText,
                                    style:  TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                ),
                                 Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.textSecondary(context),
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
                              style:  TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isTransport)
                    _buildSection(
                      'Choose your seats  ·  ${_selectedSeats.length} selected',
                      _buildSeatPicker(),
                    )
                  else
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
                        fillColor: AppColors.surfaceVariant(context),
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
            )),
    );
  }

  /// Bus-style seat grid: 4 seats per row with a central aisle.
  Widget _buildSeatPicker() {
    final transport = _item! as Transport;
    final total = max(1, transport.totalSeats);
    final freeCount = total - _occupiedSeats.length;
    final full = _selectedSeats.length >= freeCount;

    const cols = ['A', 'B', 'C', 'D'];

    Widget seatTile(int n) {
      final occupied = _occupiedSeats.contains(n);
      final selected = _selectedSeats.contains(n);
      final canTap =
          !occupied && (!selected && full ? false : true);
      final idx = n - 1;
      final label = '${idx ~/ 4 + 1}${cols[idx % 4]}';
      return GestureDetector(
        onTap: !canTap
            ? null
            : () => setState(() {
                if (!_selectedSeats.remove(n)) _selectedSeats.add(n);
              }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: occupied
                ? AppColors.surfaceVariant(context)
                : selected
                ? OneUIColors.buttonGreen
                : AppColors.surface(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? OneUIColors.buttonGreen
                  : occupied
                  ? AppColors.divider(context)
                  : AppColors.primary(context).withValues(alpha: 0.45),
              width: selected ? 2 : 1.2,
            ),
            boxShadow: selected
                ? [
                    const BoxShadow(
                      color: Color(0x551B7A4F),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : const [],
          ),
          child: Center(
            child: occupied
                ? Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: AppColors.textHint(context),
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? Colors.white
                          : AppColors.textPrimary(context),
                    ),
                  ),
          ),
        ),
      );
    }

    Widget legendDot(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );

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
          Row(
            children: [
              Icon(
                Icons.directions_bus_rounded,
                size: 18,
                color: AppColors.primary(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Front of vehicle',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              Text(
                '$freeCount of $total free',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < total; i++) ...[
                seatTile(i + 1),
                if (i % 4 == 1) const SizedBox(width: 24),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              legendDot(AppColors.surface(context), 'Free'),
              legendDot(OneUIColors.buttonGreen, 'Selected'),
              legendDot(AppColors.surfaceVariant(context), 'Taken'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider(context), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              switch (widget.type) {
                'hotel' => Icons.hotel_rounded,
                'guide' => Icons.person_rounded,
                'transport' => Icons.directions_bus_rounded,
                _ => Icons.location_on_rounded,
              },
              color: AppColors.primary(context),
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
                  style:  TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (_itemSubtitle.isNotEmpty)
                  Text(
                    _itemSubtitle,
                    style:  TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary(context),
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
                style:  TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary(context),
                ),
              ),
              Text(
                _priceLabel,
                style:  TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary(context),
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
          style:  TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary(context),
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
        color: AppColors.surfaceVariant(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
           Icon(
            Icons.people_rounded,
            size: 18,
            color: AppColors.primary(context),
          ),
          const SizedBox(width: 10),
           Expanded(
            child: Text(
              'Guests',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          IconButton(
            key: const Key('guests-decrease'),
            onPressed: _submitting || _guests <= 1
                ? null
                : () => setState(() => _guests--),
            icon: const Icon(Icons.remove_circle_outline_rounded),
            color: AppColors.primary(context),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(
            width: 24,
            child: Text(
              '$_guests',
              textAlign: TextAlign.center,
              style:  TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          IconButton(
            key: const Key('guests-increase'),
            onPressed: _submitting || _guests >= 20
                ? null
                : () => setState(() => _guests++),
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary(context),
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
        color: AppColors.primarySoft(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Estimated total',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:  TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              '৳${_fmtPrice(_estimate)}',
              key: const Key('booking-estimate'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style:  TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary(context),
              ),
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
