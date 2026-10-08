import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';
import '../../../models/package_model.dart';
import '../../../services/api_exception.dart';

class PackagesScreen extends ConsumerStatefulWidget {
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
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Payment details'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '৳${price.toStringAsFixed(2)} / month',
                  style:  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const Key('sub-card-number'),
                  controller: numberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '4242 4242 4242 4242 (sandbox)',
                    prefixIcon: Icon(Icons.credit_card_rounded, size: 20),
                    isDense: true,
                    border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          hintText: 'MM/YY',
                          isDense: true,
                          border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          hintText: 'CVV',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => RegExp(r'^\d{3,4}$')
                                .hasMatch((v ?? '').trim())
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(true);
                }
              },
              child: const Text('Pay'),
            ),
          ],
        ),
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
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel subscription?'),
        content: const Text('You will lose your plan benefits immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep Plan'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Cancel Plan',
              style: TextStyle(color: OneUIColors.error),
            ),
          ),
        ],
      ),
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

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final packagesState = ref.watch(packagesProvider);
    final packages = packagesState.packages.isNotEmpty
        ? packagesState.packages.cast<Package>()
        : Package.predefinedPackages;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Packages'),
      ),
      body: NatureBackground.wrap(child: packagesState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                   Text(
                    'Choose Your Plan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock premium features and save more on your travels. Sandbox payments only; no card is charged.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary(context),
                    ),
                  ),

                  if (!_loadingCurrent && _currentPackage != null) ...[
                    const SizedBox(height: 16),
                    _buildCurrentPlanBanner(),
                  ],

                  const SizedBox(height: 24),

                  // Package cards
                  for (final package in packages) ...[
                    _buildPackageCard(package),
                    const SizedBox(height: 12),
                  ],

                  const SizedBox(height: 24),

                  // Subscribe button
                  CGButton(
                    key: const Key('subscribe-button'),
                    label: _buttonLabel,
                    isLoading: _isLoading,
                    onPressed: !_buttonEnabled || _isLoading
                        ? null
                        : () => _handleSubscribe(packages),
                  ),

                  const SizedBox(height: 12),

                   Center(
                    child: Text(
                      'By subscribing, you agree to our Terms of Service',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint(context),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            )),
    );
  }

  Widget _buildCurrentPlanBanner() {
    final current = _currentPackage!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getTierColor(current.package.tier).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTierColor(current.package.tier),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_membership_rounded,
            color: _getTierColor(current.package.tier),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your plan: ${current.package.name}',
                  style:  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                Text(
                  'Active until ${_fmtDate(current.endDate)}',
                  style:  TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(Package package) {
    final isSelected = _selectedTier == package.tier;
    final color = _getTierColor(package.tier);

    return GestureDetector(
      key: Key('package-${package.tier.name}'),
      onTap: () => setState(() => _selectedTier = package.tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.05)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppColors.divider(context),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    package.name,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (package.tier == PackageTier.ultimate) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.end,
              runSpacing: 8,
              children: [
                Text(
                  package.price == 0
                      ? 'Free'
                      : '৳${package.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                if (package.price > 0) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '/month',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            _buildFeatureRow(
              '${package.bookingLimit == -1 ? "Unlimited" : package.bookingLimit} bookings per month',
              color,
            ),
            if (package.discountPercentage > 0)
              _buildFeatureRow(
                '${package.discountPercentage.toStringAsFixed(0)}% discount on all bookings',
                color,
              ),
            if (package.priorityListing) _buildFeatureRow('Priority listing', color),
            if (package.featuredListing) _buildFeatureRow('Featured listing', color),
            if (package.vipSupport) _buildFeatureRow('VIP support', color),
            if (package.exclusivePackages)
              _buildFeatureRow('Exclusive packages', color),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:  TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTierColor(PackageTier tier) {
    switch (tier) {
      case PackageTier.basic:
        return OneUIColors.tierBasic;
      case PackageTier.pro:
        return OneUIColors.tierPro;
      case PackageTier.premium:
        return OneUIColors.tierPremium;
      case PackageTier.ultimate:
        return OneUIColors.tierUltimate;
    }
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
