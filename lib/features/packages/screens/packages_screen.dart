// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/package_model.dart';
import '../../../services/api_exception.dart';
import '../../../state/service_providers.dart';

class PackagesScreen extends ConsumerStatefulWidget { // Phase 1 · Foundation and UI (20 Sep – 4 Oct 2026): project setup, theme, routes, widgets, mock-data screens.
  const PackagesScreen({super.key});

  @override
  ConsumerState<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends ConsumerState<PackagesScreen> {
  PackageTier _selectedTier = PackageTier.basic;
  bool _isLoading = false;

  UserPackage? _currentPackage;
  bool _loadingCurrent = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentPackage();
  }

  Future<void> _loadCurrentPackage() async {
    setState(() => _loadingCurrent = true);
    final current = await ref.read(packageServiceProvider).getMyPackage();
    if (!mounted) return;
    setState(() {
      _currentPackage = current;
      _loadingCurrent = false;
    });
  }

  Package? _packageFor(PackageTier tier, List<Package> packages) {
    for (final p in packages) {
      if (p.tier == tier) return p;
    }
    return null;
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  /// Collect card details for a paid plan. Returns null when cancelled.
  Future<Map<String, String>?> _promptForCard(double price) async {
    final numberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final c = CgColors.of(dialogContext);
          return AlertDialog(
            backgroundColor: c.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CgRadii.card),
            ),
            title: Text(
              'Payment details',
              style: CgType.t20.copyWith(color: c.text),
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '৳${price.toStringAsFixed(2)} / month',
                    style: CgType.b14.copyWith(
                      fontWeight: FontWeight.w700,
                      color: c.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('sub-card-number'),
                    controller: numberController,
                    keyboardType: TextInputType.number,
                    style: CgType.b14.copyWith(color: c.text),
                    decoration: InputDecoration(
                      hintText: '4242 4242 4242 4242 (sandbox)',
                      hintStyle: CgType.b14.copyWith(color: c.text2),
                      prefixIcon: Icon(
                        Icons.credit_card_rounded,
                        size: 20,
                        color: c.text2,
                      ),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(CgRadii.input),
                      ),
                    ),
                    validator: (v) {
                      final digits = (v ?? '').replaceAll(' ', '');
                      if (digits != '4242424242424242') {
                        return 'Sandbox card: 4242 4242 4242 4242';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('sub-card-expiry'),
                          controller: expiryController,
                          keyboardType: TextInputType.datetime,
                          style: CgType.b14.copyWith(color: c.text),
                          decoration: InputDecoration(
                            hintText: 'MM/YY',
                            hintStyle: CgType.b14.copyWith(color: c.text2),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                CgRadii.input,
                              ),
                            ),
                          ),
                          validator: (v) {
                            final ok = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$')
                                .hasMatch((v ?? '').trim());
                            return ok ? null : 'MM/YY';
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          key: const Key('sub-card-cvv'),
                          controller: cvvController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          style: CgType.b14.copyWith(color: c.text),
                          decoration: InputDecoration(
                            hintText: 'CVV',
                            hintStyle: CgType.b14.copyWith(color: c.text2),
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                CgRadii.input,
                              ),
                            ),
                          ),
                          validator: (v) =>
                              RegExp(r'^\d{3,4}$').hasMatch((v ?? '').trim())
                              ? null
                              : 'CVV',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                style: TextButton.styleFrom(foregroundColor: c.text2),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                style: TextButton.styleFrom(foregroundColor: c.primary),
                child: const Text('Pay'),
              ),
            ],
          );
        },
      );
      if (result != true) return null;
      return {
        'card_number': numberController.text.replaceAll(' ', '').trim(),
        'expiry_date': expiryController.text.trim(),
        'cvv': cvvController.text.trim(),
      };
    } finally {
      numberController.dispose();
      expiryController.dispose();
      cvvController.dispose();
    }
  }

  Future<void> _handleSubscribe(List<Package> packages) async {
    if (_isLoading) return;
    final selected = _packageFor(_selectedTier, packages);
    if (selected == null) return;

    final hasActive = _currentPackage != null;
    final isSamePlan =
        hasActive && _currentPackage!.package.tier == selected.tier;

    // Basic + active plan → the button cancels the subscription instead
    if (hasActive && selected.tier == PackageTier.basic) {
      await _cancelCurrent();
      return;
    }

    if (isSamePlan) return;

    // Paid plans need card details
    Map<String, String>? card;
    if (selected.price > 0) {
      card = await _promptForCard(selected.price);
      if (card == null) return;
    }

    setState(() => _isLoading = true);
    try {
      final service = ref.read(packageServiceProvider);
      final result = hasActive
          ? await service.upgradePackage(
              newPackageId: selected.id,
              paymentMethod: 'card',
              cardNumber: card?['card_number'],
              expiryDate: card?['expiry_date'],
              cvv: card?['cvv'],
            )
          : await service.subscribeToPackage(
              packageId: selected.id,
              paymentMethod: selected.price > 0 ? 'card' : 'free',
              cardNumber: card?['card_number'],
              expiryDate: card?['expiry_date'],
              cvv: card?['cvv'],
            );

      if (!mounted) return;
      if (result == null) {
        _showSnack('Could not update your plan. Please try again.');
      } else {
        _showSnack(
          hasActive
              ? 'Upgraded to ${selected.name}!'
              : 'Subscribed to ${selected.name} plan!',
        );
        await _loadCurrentPackage();
      }
    } on ApiException catch (e) {
      if (mounted) _showSnack(e.message);
    } catch (_) {
      if (mounted) _showSnack('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelCurrent() async {
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
            'Cancel subscription?',
            style: CgType.t20.copyWith(color: c.text),
          ),
          content: Text(
            'You will lose your plan benefits immediately.',
            style: CgType.b14.copyWith(color: c.text2),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: c.text2),
              child: const Text('Keep Plan'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: CgColorConstants.danger,
              ),
              child: const Text('Cancel Plan'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);
    try {
      final ok = await ref.read(packageServiceProvider).cancelPackage();
      if (!mounted) return;
      if (ok) {
        _showSnack('Subscription cancelled');
        await _loadCurrentPackage();
      } else {
        _showSnack('Could not cancel the subscription');
      }
    } catch (_) {
      if (mounted) _showSnack('Connection error. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message) {
    if (mounted) showCgToast(context, message);
  }

  String get _buttonLabel {
    if (_currentPackage != null &&
        _currentPackage!.package.tier == _selectedTier) {
      return 'Current Plan';
    }
    if (_currentPackage != null && _selectedTier == PackageTier.basic) {
      return 'Cancel Current Plan';
    }
    if (_currentPackage != null) return 'Upgrade to ${_selectedTier.name}';
    return _selectedTier == PackageTier.basic
        ? 'Subscribe to Basic'
        : 'Subscribe to ${_selectedTier.name}';
  }

  bool get _buttonEnabled {
    if (_currentPackage != null &&
        _currentPackage!.package.tier == _selectedTier) {
      return false; // already on this plan
    }
    return true;
  }

  Color _tierColor(CgColors c, PackageTier tier) => switch (tier) {
    PackageTier.basic => c.primary,
    PackageTier.pro => const Color(0xFF2F8F72),
    PackageTier.premium => const Color(0xFF4A90C2),
    PackageTier.ultimate => c.accent,
  };

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    final packagesState = ref.watch(packagesProvider);
    final packages = packagesState.packages.isNotEmpty
        ? packagesState.packages.cast<Package>()
        : Package.predefinedPackages;

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
          child: Opacity(
            opacity: _buttonEnabled ? 1 : .5,
            child: CgPillButton(
              key: const Key('subscribe-button'),
              loading: _isLoading,
              onTap: !_buttonEnabled || _isLoading
                  ? null
                  : () => _handleSubscribe(packages),
              child: Text(
                _buttonLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          CgPageTitle(
            title: 'Choose Your Plan',
            subtitle:
                'Unlock premium features and save more on your travels. '
                'Sandbox payments only; no card is charged.',
            onBack: () => goBack(context),
          ),
          if (!_loadingCurrent && _currentPackage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
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
                      child: Icon(
                        Icons.card_membership_rounded,
                        size: 20,
                        color: c.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your plan: ${_currentPackage!.package.name}',
                            style: CgType.t16.copyWith(color: c.text),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Active until '
                            '${_fmtDate(_currentPackage!.endDate)}',
                            style: CgType.l12.copyWith(color: c.text2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (packagesState.isLoading)
            const CgLoadingState()
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                'Plans',
                style: CgType.t16.copyWith(fontSize: 18, color: c.text),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                children: [
                  for (var i = 0; i < packages.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == packages.length - 1 ? 0 : 12,
                      ),
                      child: _buildPackageCard(packages[i]),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'By subscribing, you agree to our Terms of Service',
                textAlign: TextAlign.center,
                style: CgType.l12.copyWith(
                  fontSize: 11,
                  color: c.text2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final c = CgColors.of(context);
    final isSelected = _selectedTier == package.tier;
    final color = _tierColor(c, package.tier);

    return GestureDetector(
      key: Key('package-${package.tier.name}'),
      onTap: () => setState(() => _selectedTier = package.tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: c.gCard,
          borderRadius: BorderRadius.circular(CgRadii.card),
          border: Border.all(
            color: isSelected ? color : c.line,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? c.cardShadow : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      CgTextPill(
                        label: package.name,
                        background: color.withValues(alpha: .12),
                        foreground: color,
                      ),
                      if (package.tier == PackageTier.ultimate)
                        CgTextPill(
                          label: 'BEST VALUE',
                          icon: Icons.workspace_premium_rounded,
                          background: c.accent.withValues(alpha: .16),
                          foreground: c.accent,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: isSelected ? color : c.line,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      package.price == 0
                          ? 'Free'
                          : '৳${package.price.toStringAsFixed(2)}',
                      maxLines: 1,
                      style: CgType.h1Bold.copyWith(
                        fontSize: 26,
                        color: color,
                      ),
                    ),
                  ),
                ),
                if (package.price > 0) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '/month',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CgType.l12.copyWith(color: c.text2),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _feature(
              package.bookingLimit == -1
                  ? 'Unlimited bookings per month'
                  : '${package.bookingLimit} bookings per month',
              color,
            ),
            if (package.discountPercentage > 0)
              _feature(
                '${package.discountPercentage.toStringAsFixed(0)}% discount '
                'on all bookings',
                color,
              ),
            if (package.priorityListing) _feature('Priority listing', color),
            if (package.featuredListing) _feature('Featured listing', color),
            if (package.vipSupport) _feature('VIP support', color),
            if (package.exclusivePackages)
              _feature('Exclusive packages', color),
          ],
        ),
      ),
    );
  }

  Widget _feature(String text, Color color) {
    final c = CgColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: CgType.l12.copyWith(color: c.text2)),
          ),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
