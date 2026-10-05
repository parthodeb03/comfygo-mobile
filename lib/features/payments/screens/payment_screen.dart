import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../services/api_exception.dart';
import '../../../state/service_providers.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final int bookingId;

  const PaymentScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'card';
  bool _isLoading = false;

  Booking? _booking;
  bool _loadingBooking = true;

  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardholderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  Future<void> _loadBooking() async {
    setState(() => _loadingBooking = true);
    final booking = await ref
        .read(bookingServiceProvider)
        .getBookingById(widget.bookingId);
    if (!mounted) return;
    setState(() {
      _booking = booking;
      _loadingBooking = false;
    });
  }

  double get _amount => _booking?.totalPrice ?? 0;

  // ── Validation ──────────────────────────────────────────────────────────

  String? _validateCard() {
    final number = _cardNumberController.text.replaceAll(' ', '').trim();
    if (number.isEmpty || number.length < 13 || number.length > 19) {
      return 'Enter a valid card number';
    }
    if (number.replaceAll(RegExp(r'\d'), '').isNotEmpty) {
      return 'Card number must contain only digits';
    }
    final expiry = _expiryController.text.trim();
    final expiryMatch = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiry);
    if (!expiryMatch) return 'Expiry must be in MM/YY format';
    if (!RegExp(r'^\d{3,4}$').hasMatch(_cvvController.text.trim())) {
      return 'CVV must be 3 or 4 digits';
    }
    if (_cardholderController.text.trim().isEmpty) {
      return 'Enter the cardholder name';
    }
    return null;
  }

  // ── Payment ─────────────────────────────────────────────────────────────

  Future<void> _handlePayment() async {
    if (_isLoading || _booking == null) return;

    if (_selectedMethod == 'card') {
      final error = _validateCard();
      if (error != null) {
        _showSnack(error);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final payment = _selectedMethod == 'card'
          ? await ref.read(paymentServiceProvider).createCardPayment(
                bookingId: widget.bookingId,
                amount: _amount,
                cardNumber: _cardNumberController.text
                    .replaceAll(' ', '')
                    .trim(),
                expiryDate: _expiryController.text.trim(),
                cvv: _cvvController.text.trim(),
                cardholderName: _cardholderController.text.trim(),
              )
          : await ref.read(paymentServiceProvider).createCashPayment(
                bookingId: widget.bookingId,
                amount: _amount,
              );

      if (!mounted) return;

      if (payment == null) {
        _showSnack('Payment could not be processed. Please try again.');
      } else {
        // Keep the bookings list in sync (card payments confirm the booking)
        ref.read(bookingsProvider.notifier).loadBookings();
        _showSuccessDialog();
      }
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message);
    } catch (_) {
      if (mounted) _showSnack('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  void _showSuccessDialog() {
    final isCard = _selectedMethod == 'card';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isCard ? 'Payment Successful' : 'Payment Recorded'),
        content: Text(
          isCard
              ? 'Your payment has been processed successfully.'
              : 'Your cash payment has been recorded and will be '
                    'confirmed by our team.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/bookings');
            },
            child: const Text('View Bookings'),
          ),
        ],
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Payment'),
      ),
      body: _loadingBooking
          ? const Center(child: CircularProgressIndicator())
          : _booking == null
          ? TravelEmpty(
              message: 'The booking for this payment could not be loaded.',
              onRetry: _loadBooking,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order summary — real booking data
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: OneUIColors.primarySoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: OneUIColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                          _booking!.itemName.isEmpty
                              ? 'Booking #${_booking!.id}'
                              : _booking!.itemName,
                          '',
                        ),
                        _buildSummaryRow('Booking ID', '#${_booking!.id}'),
                        _buildSummaryRow(
                          'Guests',
                          '${_booking!.guests}',
                        ),
                        const Divider(height: 20),
                        _buildSummaryRow(
                          'Total',
                          '৳${_fmtPrice(_amount)}',
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Payment method
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: OneUIColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMethodCard(
                          'card',
                          'Card',
                          Icons.credit_card_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMethodCard(
                          'cash',
                          'Cash',
                          Icons.payments_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Card details
                  if (_selectedMethod == 'card') ...[
                    const Text(
                      'Card Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: OneUIColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GlassInput(
                      key: const Key('card-number'),
                      controller: _cardNumberController,
                      hintText: 'Card Number',
                      prefixIcon: Icons.credit_card_rounded,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GlassInput(
                            key: const Key('card-expiry'),
                            controller: _expiryController,
                            hintText: 'MM/YY',
                            keyboardType: TextInputType.datetime,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GlassInput(
                            key: const Key('card-cvv'),
                            controller: _cvvController,
                            hintText: 'CVV',
                            obscureText: true,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GlassInput(
                      key: const Key('card-holder'),
                      controller: _cardholderController,
                      hintText: 'Cardholder Name',
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                  ],

                  if (_selectedMethod == 'cash') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: OneUIColors.statusPending.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: OneUIColors.statusPending,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pay with cash upon arrival. Please have the exact amount ready.',
                              style: TextStyle(
                                fontSize: 14,
                                color: OneUIColors.textSecondaryLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  CGButton(
                    key: const Key('pay-button'),
                    label: _selectedMethod == 'card'
                        ? 'Pay ৳${_fmtPrice(_amount)}'
                        : 'Confirm Cash Payment',
                    isLoading: _isLoading,
                    onPressed: _handlePayment,
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: OneUIColors.textHintLight,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Secure payment powered by SSL',
                          style: TextStyle(
                            fontSize: 12,
                            color: OneUIColors.textHintLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 6,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: OneUIColors.textSecondaryLight,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold
                    ? OneUIColors.primaryLight
                    : OneUIColors.textPrimaryLight,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMethodCard(String method, String label, IconData icon) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      key: Key('method-$method'),
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? OneUIColors.primarySoft
              : OneUIColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? OneUIColors.primaryLight
                : OneUIColors.dividerLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? OneUIColors.primaryLight
                  : OneUIColors.textSecondaryLight,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? OneUIColors.primaryLight
                    : OneUIColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
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
