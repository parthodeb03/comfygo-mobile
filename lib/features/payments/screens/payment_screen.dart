import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/models.dart';
import '../../../services/api_exception.dart';
import '../../../services/invoice_pdf.dart';
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
  final _walletController = TextEditingController();

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
    _walletController.dispose();
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
    if (number != '4242424242424242') {
      return 'Sandbox only: use 4242 4242 4242 4242';
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

  bool get _isWalletMethod =>
      _selectedMethod == 'bkash' || _selectedMethod == 'nagad';

  String? _validateWallet() {
    final number = _walletController.text.trim();
    if (!RegExp(r'^01\d{9}$').hasMatch(number)) {
      return 'Enter an 11-digit wallet number (01…)';
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
    } else if (_isWalletMethod) {
      final error = _validateWallet();
      if (error != null) {
        _showSnack(error);
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final payment = _selectedMethod == 'card'
          ? await ref
                .read(paymentServiceProvider)
                .createCardPayment(
                  bookingId: widget.bookingId,
                  amount: _amount,
                  cardNumber: _cardNumberController.text
                      .replaceAll(' ', '')
                      .trim(),
                  expiryDate: _expiryController.text.trim(),
                  cvv: _cvvController.text.trim(),
                  cardholderName: _cardholderController.text.trim(),
                )
          : _isWalletMethod
          ? await ref
                .read(paymentServiceProvider)
                .createWalletPayment(
                  bookingId: widget.bookingId,
                  amount: _amount,
                  method: _selectedMethod,
                  walletNumber: _walletController.text.trim(),
                )
          : await ref
                .read(paymentServiceProvider)
                .createCashPayment(
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
    if (mounted) showCgToast(context, message);
  }

  void _showSuccessDialog() {
    final isCard = _selectedMethod == 'card';
    final isWallet = _isWalletMethod;
    final booking = _booking;
    showDialog(
      context: context,
      builder: (dialogContext) {
        final c = CgColors.of(dialogContext);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CgRadii.card),
          ),
          icon: Icon(Icons.check_circle_rounded, color: c.primary, size: 36),
          title: Text(
            isCard || isWallet ? 'Payment Successful' : 'Payment Recorded',
            textAlign: TextAlign.center,
            style: CgType.t20.copyWith(color: c.text),
          ),
          content: Text(
            isCard
                ? 'Sandbox payment simulated successfully. '
                      'No card was charged.'
                : isWallet
                ? 'Sandbox '
                      '${_selectedMethod == 'bkash' ? 'bKash' : 'Nagad'} '
                      'payment simulated successfully. No money moved.'
                : 'Your cash payment has been recorded and will be '
                      'confirmed by our team.',
            textAlign: TextAlign.center,
            style: CgType.b14.copyWith(color: c.text2),
          ),
          actions: [
            if (booking != null)
              TextButton(
                key: const Key('dialog-download-invoice'),
                onPressed: () async {
                  try {
                    await InvoicePdf.share(booking);
                  } catch (_) {
                    // The dialog stays open; user can retry or close.
                  }
                },
                style: TextButton.styleFrom(foregroundColor: c.primary),
                child: const Text('Download Invoice'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.go('/bookings');
              },
              style: TextButton.styleFrom(foregroundColor: c.text2),
              child: const Text('View Bookings'),
            ),
          ],
        );
      },
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final payable = !_loadingBooking && _booking != null;

    return CgPageScaffold(
      bottom: !payable
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CgPillButton(
                      key: const Key('pay-button'),
                      loading: _isLoading,
                      onTap: _handlePayment,
                      child: Text(
                        _selectedMethod == 'card'
                            ? 'Pay ৳${_fmtPrice(_amount)}'
                            : _isWalletMethod
                            ? 'Pay with '
                                  '${_selectedMethod == 'bkash' ? 'bKash' : 'Nagad'}'
                            : 'Confirm Cash Payment',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 13,
                          color: c.text2,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Sandbox only — no real card is charged',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CgType.l12.copyWith(
                              fontSize: 11,
                              color: c.text2,
                            ),
                          ),
                        ),
                      ],
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
            title: 'Payment',
            subtitle: payable
                ? 'Booking #${_booking!.id} · '
                      '${_booking!.itemName.isEmpty ? 'Your trip' : _booking!.itemName}'
                : null,
            onBack: () => goBack(context),
          ),
          if (_loadingBooking)
            const CgLoadingState()
          else if (_booking == null)
            CgErrorState(
              message: 'The booking for this payment could not be loaded.',
              onRetry: _loadBooking,
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: CgCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: CgType.t16.copyWith(color: c.text),
                    ),
                    const SizedBox(height: 6),
                    CgInfoRow(
                      label: _booking!.itemName.isEmpty
                          ? 'Booking #${_booking!.id}'
                          : _booking!.itemName,
                      value: '#${_booking!.id}',
                    ),
                    CgInfoRow(label: 'Guests', value: '${_booking!.guests}'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Total',
                            style: CgType.b14.copyWith(color: c.text2),
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '৳${_fmtPrice(_amount)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CgType.t20.copyWith(color: c.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: CgSection(title: 'Payment Method'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _MethodCard(
                          key: const Key('method-card'),
                          label: 'Card',
                          icon: Icons.credit_card_rounded,
                          selected: _selectedMethod == 'card',
                          onTap: () =>
                              setState(() => _selectedMethod = 'card'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MethodCard(
                          key: const Key('method-bkash'),
                          label: 'bKash',
                          icon: Icons.account_balance_wallet_rounded,
                          selected: _selectedMethod == 'bkash',
                          onTap: () =>
                              setState(() => _selectedMethod = 'bkash'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _MethodCard(
                          key: const Key('method-nagad'),
                          label: 'Nagad',
                          icon: Icons.account_balance_wallet_outlined,
                          selected: _selectedMethod == 'nagad',
                          onTap: () =>
                              setState(() => _selectedMethod = 'nagad'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MethodCard(
                          key: const Key('method-cash'),
                          label: 'Cash',
                          icon: Icons.payments_rounded,
                          selected: _selectedMethod == 'cash',
                          onTap: () => setState(() => _selectedMethod = 'cash'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Card details ─────────────────────────────────────
            if (_selectedMethod == 'card') ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: CgSection(title: 'Card Details'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: CgTextField(
                  key: const Key('card-number'),
                  label: 'Card number',
                  controller: _cardNumberController,
                  icon: Icons.credit_card_rounded,
                  hint: '4242 4242 4242 4242 (sandbox)',
                  keyboardType: TextInputType.number,
                  enabled: !_isLoading,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CgTextField(
                        key: const Key('card-expiry'),
                        label: 'Expiry',
                        controller: _expiryController,
                        icon: Icons.event_rounded,
                        hint: 'MM/YY',
                        keyboardType: TextInputType.datetime,
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CgTextField(
                        key: const Key('card-cvv'),
                        label: 'CVV',
                        controller: _cvvController,
                        icon: Icons.lock_outline_rounded,
                        hint: '123',
                        obscure: true,
                        keyboardType: TextInputType.number,
                        enabled: !_isLoading,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: CgTextField(
                  key: const Key('card-holder'),
                  label: 'Cardholder Name',
                  controller: _cardholderController,
                  icon: Icons.person_outline_rounded,
                  hint: 'Name on the card',
                  enabled: !_isLoading,
                ),
              ),
            ],

            // ─── Wallet details ───────────────────────────────────
            if (_isWalletMethod) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: CgSection(
                  title:
                      '${_selectedMethod == 'bkash' ? 'bKash' : 'Nagad'} Wallet',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: CgTextField(
                  key: const Key('wallet-number'),
                  label: 'Wallet number',
                  controller: _walletController,
                  icon: Icons.phone_android_rounded,
                  hint: '01XXXXXXXXX (11 digits)',
                  keyboardType: TextInputType.phone,
                  enabled: !_isLoading,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _InfoNote(
                  icon: Icons.info_outline_rounded,
                  text:
                      'Sandbox simulation — you will get a transaction ID '
                      'instantly and no money moves.',
                ),
              ),
            ],

            // ─── Cash note ────────────────────────────────────────
            if (_selectedMethod == 'cash')
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _InfoNote(
                  icon: Icons.payments_outlined,
                  text:
                      'Pay with cash upon arrival. Please have the exact '
                      'amount ready.',
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected ? c.gMint : c.gCard,
          borderRadius: BorderRadius.circular(CgRadii.input),
          border: Border.all(
            color: selected ? c.accent : c.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? c.primary : c.text2,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CgType.b14.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? c.text : c.text2,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, size: 16, color: c.primary),
          ],
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: CgType.b14.copyWith(color: c.text2)),
          ),
        ],
      ),
    );
  }
}

String _fmtPrice(double value) {
  final s = value.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}
