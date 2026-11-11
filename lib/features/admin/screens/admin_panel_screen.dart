// ComfyGo Project Plan — Phase 1 · Foundation and UI
// Screen structure and layout from Phase 1; data wiring and validation from Phase 2.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/comfy_design.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/comfy_page.dart';
import '../../../core/widgets/comfy_ui.dart';
import '../../../models/models.dart';
import '../../../state/service_providers.dart';

class AdminPanelScreen extends ConsumerStatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  ConsumerState<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends ConsumerState<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Map<String, dynamic>? _stats;
  List<User>? _users;
  List<Booking>? _bookings;
  List<Payment>? _payments;
  List<Hotel>? _listings;
  List<UserPackage>? _userPackages;

  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final admin = ref.read(adminServiceProvider);

    // AdminService already swallows transport errors (returns empty results),
    // so one broken call can never blank the whole panel.
    final results = await Future.wait([
      admin.getStats(),
      admin.getUsers(limit: 100),
      admin.getAllBookings(limit: 100),
      admin.getAllPayments(limit: 100),
      admin.getAllListings(limit: 100),
      admin.getUserPackages(limit: 100),
    ]);

    if (!mounted) return;
    setState(() {
      _stats = results[0] as Map<String, dynamic>;
      _users = results[1] as List<User>;
      _bookings = results[2] as List<Booking>;
      _payments = results[3] as List<Payment>;
      _listings = results[4] as List<Hotel>;
      _userPackages = results[5] as List<UserPackage>;
      _loading = false;
    });
  }

  // ── Actions ─────────────────────────────────────────────────────────────

  Future<void> _approveListing(Hotel hotel) async {
    if (_acting) return;
    setState(() => _acting = true);
    final ok = await ref.read(adminServiceProvider).approveListing(hotel.id);
    if (!mounted) return;
    setState(() => _acting = false);
    _showSnack(ok ? 'Listing approved' : 'Could not approve the listing');
    if (ok) await _loadAll();
  }

  Future<void> _removeListing(Hotel hotel) async {
    if (_acting) return;
    final confirmed = await _confirm(
      title: 'Remove listing?',
      message: '"${hotel.name}" will be permanently removed.',
      actionLabel: 'Remove',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _acting = true);
    final ok = await ref.read(adminServiceProvider).removeListing(hotel.id);
    if (!mounted) return;
    setState(() => _acting = false);
    _showSnack(ok ? 'Listing removed' : 'Could not remove the listing');
    if (ok) await _loadAll();
  }

  Future<void> _voidPayment(Payment payment) async {
    if (_acting) return;
    final confirmed = await _confirm(
      title: 'Void payment?',
      message:
          'Payment #${payment.id} of ৳${payment.amount.toStringAsFixed(0)} '
          'will be voided and retained in the audit history.',
      actionLabel: 'Void',
    );
    if (confirmed != true || !mounted) return;

    setState(() => _acting = true);
    final result = await ref
        .read(adminServiceProvider)
        .voidPayment(payment.id, reason: 'Voided by admin');
    if (!mounted) return;
    setState(() => _acting = false);
    _showSnack(
      result != null ? 'Payment voided' : 'Could not void the payment',
    );
    if (result != null) await _loadAll();
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String actionLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final c = CgColors.of(dialogContext);
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CgRadii.card),
          ),
          title: Text(title, style: CgType.t20.copyWith(color: c.text)),
          content: Text(message, style: CgType.b14.copyWith(color: c.text2)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(foregroundColor: c.text2),
              child: const Text('Keep'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: CgColorConstants.danger,
              ),
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }

  void _showSnack(String message) {
    if (mounted) showCgToast(context, message);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgPageScaffold(
      child: Column(
        children: [
          CgPageTitle(
            title: 'Admin Panel',
            subtitle: 'Users, bookings, payments and listings',
            onBack: () => goBack(context),
            trailing: CgIconAction(
              key: const Key('admin-refresh'),
              icon: Icons.refresh_rounded,
              semanticLabel: 'Refresh',
              onTap: _loading ? null : _loadAll,
            ),
          ),
          if (_loading)
            const Expanded(child: CgLoadingState())
          else
            Expanded(
              child: Column(
                children: [
                  // ─── Stats ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.people_rounded,
                                value: '${_stats?['users'] ?? 0}',
                                label: 'Users',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.book_rounded,
                                value: '${_stats?['bookings'] ?? 0}',
                                label: 'Bookings',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.payments_rounded,
                                value: '৳${_fmtRevenue(_stats?['revenue'])}',
                                label: 'Revenue',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.card_membership_rounded,
                                value: '${_stats?['active_packages'] ?? 0}',
                                label: 'Plans',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ─── Tabs ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: c.mint,
                        borderRadius: BorderRadius.circular(CgRadii.pill),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          gradient: c.gMain,
                          borderRadius: BorderRadius.circular(CgRadii.pill),
                        ),
                        labelColor: c.onPrimary,
                        unselectedLabelColor: c.text2,
                        labelStyle: CgType.l12.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        unselectedLabelStyle: CgType.l12.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                        ),
                        tabs: const [
                          Tab(height: 38, text: 'Dashboard'),
                          Tab(height: 38, text: 'Users'),
                          Tab(height: 38, text: 'Bookings'),
                          Tab(height: 38, text: 'Payments'),
                          Tab(height: 38, text: 'Listings'),
                          Tab(height: 38, text: 'Packages'),
                        ],
                      ),
                    ),
                  ),

                  // ─── Tab content ──────────────────────────────
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildDashboardTab(),
                        _buildUsersTab(),
                        _buildBookingsTab(),
                        _buildPaymentsTab(),
                        _buildListingsTab(),
                        _buildPackagesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Dashboard (statistical view) ──────────────────────────────────

  Widget _buildDashboardTab() {
    final c = CgColors.of(context);
    final bookings = _bookings ?? <Booking>[];
    final payments = _payments ?? <Payment>[];

    final statusData = [
      (
        'Pending',
        bookings.where((b) => b.status == BookingStatus.pending).length,
        const Color(0xFFFFC107),
      ),
      (
        'Confirmed',
        bookings.where((b) => b.status == BookingStatus.confirmed).length,
        const Color(0xFF4CAF50),
      ),
      (
        'Completed',
        bookings.where((b) => b.status == BookingStatus.completed).length,
        const Color(0xFF2F8F72),
      ),
      (
        'Cancelled',
        bookings.where((b) => b.status == BookingStatus.cancelled).length,
        const Color(0xFFF44336),
      ),
    ];

    final typeData = [
      (
        'Hotels',
        bookings.where((b) => b.type == BookingType.hotel).length,
        const Color(0xFF2F8F72),
      ),
      (
        'Transport',
        bookings.where((b) => b.type == BookingType.transport).length,
        const Color(0xFF4A90C2),
      ),
      (
        'Guides',
        bookings.where((b) => b.type == BookingType.guide).length,
        const Color(0xFFF2A93B),
      ),
      (
        'Tours',
        bookings.where((b) => b.type == BookingType.destination).length,
        const Color(0xFF8E7CC3),
      ),
    ];

    final revenue = ((_stats?['revenue'] as num?) ?? 0).toDouble();
    final completedPayments = payments
        .where((p) => p.status == PaymentStatus.completed)
        .toList();
    final completedTotal = completedPayments.fold<double>(
      0,
      (sum, p) => sum + p.amount,
    );
    final averagePayment = completedPayments.isEmpty
        ? 0.0
        : completedTotal / completedPayments.length;
    final successRate = payments.isEmpty
        ? 0.0
        : completedPayments.length / payments.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        _dashboardCard(
          title: 'Bookings by service',
          subtitle: 'Distribution across booking types',
          child: Column(
            children: [
              SizedBox(
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(150, 150),
                      painter: _DonutPainter(
                        values: [
                          for (final entry in typeData)
                            entry.$2.toDouble(),
                        ],
                        colors: [for (final entry in typeData) entry.$3],
                        emptyColor: c.line,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${bookings.length}',
                          style: CgType.h1Bold.copyWith(
                            fontSize: 26,
                            color: c.text,
                          ),
                        ),
                        Text(
                          'bookings',
                          style: CgType.l12.copyWith(color: c.text2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              for (final entry in typeData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: entry.$3,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.$1,
                          style: CgType.l12.copyWith(
                            fontSize: 13,
                            color: c.text,
                          ),
                        ),
                      ),
                      Text(
                        '${entry.$2}',
                        style: CgType.l12.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: c.text,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _dashboardCard(
          title: 'Bookings by status',
          subtitle: 'Live funnel from pending to completed',
          child: Column(
            children: [
              for (final entry in statusData)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 78,
                        child: Text(
                          entry.$1,
                          style: CgType.l12.copyWith(
                            fontSize: 12.5,
                            color: c.text2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            children: [
                              Container(height: 16, color: c.mint),
                              FractionallySizedBox(
                                widthFactor: bookings.isEmpty
                                    ? 0
                                    : (entry.$2 / bookings.length).clamp(
                                        0.0,
                                        1.0,
                                      ),
                                child: Container(
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: entry.$3,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 34,
                        child: Text(
                          '${entry.$2}',
                          textAlign: TextAlign.end,
                          style: CgType.l12.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: c.text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _dashboardCard(
          title: 'Revenue summary',
          subtitle: 'From completed payments',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '৳${_fmtRevenue(revenue)}',
                style: CgType.h1Bold.copyWith(fontSize: 28, color: c.primary),
              ),
              const SizedBox(height: 10),
              CgInfoRow(
                label: 'Payments received',
                value: '${completedPayments.length} of ${payments.length}',
              ),
              CgInfoRow(
                label: 'Average payment',
                value: '৳${_fmtRevenue(averagePayment)}',
              ),
              CgInfoRow(
                label: 'Success rate',
                value: '${(successRate * 100).round()}%',
              ),
              CgInfoRow(
                label: 'Active subscriptions',
                value: '${_stats?['active_packages'] ?? 0}',
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final c = CgColors.of(context);
    return CgCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: CgType.t16.copyWith(color: c.text)),
          const SizedBox(height: 2),
          Text(subtitle, style: CgType.l12.copyWith(color: c.text2)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final users = _users;
    if (users == null || users.isEmpty) {
      return const CgEmptyState(
        icon: Icons.people_outline_rounded,
        message: 'No users found.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: users.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final user = users[index];
        return CgTile(
          title: user.fullName,
          subtitle: '${_roleLabel(user.role)} · ${user.email}',
          leading: Text(
            user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
            style: CgType.t16.copyWith(color: CgColors.of(context).primary),
          ),
          trailingText: _roleLabel(user.role),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    final bookings = _bookings;
    if (bookings == null || bookings.isEmpty) {
      return const CgEmptyState(
        icon: Icons.receipt_long_outlined,
        message: 'No bookings found.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = bookings[index];
        return CgTile(
          icon: switch (b.type) {
            BookingType.hotel => Icons.hotel_rounded,
            BookingType.transport => Icons.directions_bus_rounded,
            BookingType.guide => Icons.person_rounded,
            BookingType.destination => Icons.place_rounded,
          },
          title: b.itemName.isEmpty ? 'Booking #${b.id}' : b.itemName,
          subtitle: '${b.touristName} · ৳${_fmtRevenue(b.totalPrice)}',
          trailingText: _statusLabel(b.status),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    final payments = _payments;
    if (payments == null || payments.isEmpty) {
      return const CgEmptyState(
        icon: Icons.payments_outlined,
        message: 'No payments found.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: payments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = payments[index];
        final canVoid =
            p.status != PaymentStatus.voided &&
            p.status != PaymentStatus.refunded;
        return CgTile(
          icon: Icons.payments_rounded,
          title: '৳${_fmtRevenue(p.amount)}',
          subtitle:
              '${_paymentMethodLabel(p.method)} · '
              '${_paymentStatusLabel(p.status)}'
              '${p.cardLastFour != null ? ' · *${p.cardLastFour}' : ''}',
          trailing: canVoid
              ? CgIconAction(
                  icon: Icons.block_rounded,
                  semanticLabel: 'Void payment',
                  color: CgColorConstants.danger,
                  onTap: () => _voidPayment(p),
                )
              : null,
        );
      },
    );
  }

  Widget _buildListingsTab() {
    final listings = _listings;
    if (listings == null || listings.isEmpty) {
      return const CgEmptyState(
        icon: Icons.business_outlined,
        message: 'No listings found.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      itemCount: listings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final l = listings[index];
        return CgTile(
          icon: Icons.business_rounded,
          title: l.name,
          subtitle:
              'Hotel · ${l.location}${l.isApproved ? '' : ' · awaiting approval'}',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!l.isApproved)
                CgIconAction(
                  key: Key('approve-listing-${l.id}'),
                  icon: Icons.check_rounded,
                  semanticLabel: 'Approve listing',
                  onTap: _acting ? null : () => _approveListing(l),
                ),
              const SizedBox(width: 6),
              CgIconAction(
                key: Key('remove-listing-${l.id}'),
                icon: Icons.delete_outline_rounded,
                semanticLabel: 'Remove listing',
                color: CgColorConstants.danger,
                onTap: _acting ? null : () => _removeListing(l),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackagesTab() {
    final c = CgColors.of(context);
    final packagesState = ref.watch(packagesProvider);
    final packages = packagesState.packages.isNotEmpty
        ? packagesState.packages
        : Package.predefinedPackages;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          '${_stats?['active_packages'] ?? 0} active subscriptions',
          style: CgType.b14.copyWith(color: c.text2),
        ),
        if ((_userPackages ?? []).isNotEmpty) ...[
          const SizedBox(height: 16),
          CgSection(title: 'Recent subscriptions'),
          const SizedBox(height: 8),
          for (var i = 0; i < _userPackages!.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == _userPackages!.length - 1 ? 0 : 10,
              ),
              child: CgTile(
                icon: Icons.person_outline_rounded,
                title:
                    '${_userPackages![i].package.name} · '
                    'User #${_userPackages![i].userId}',
                subtitle:
                    '${_statusLabel(_userPackages![i].status)} · ends '
                    '${_userPackages![i].endDate.toLocal().toString().split(' ').first}',
              ),
            ),
        ],
        const SizedBox(height: 20),
        CgSection(title: 'Available tiers'),
        const SizedBox(height: 8),
        for (var i = 0; i < packages.length; i++)
          Padding(
            padding: EdgeInsets.only(
              bottom: i == packages.length - 1 ? 0 : 10,
            ),
            child: CgTile(
              icon: Icons.card_membership_rounded,
              title:
                  '${packages[i].name} · '
                  '${packages[i].price == 0 ? 'Free' : '৳${packages[i].price.toStringAsFixed(2)}'}/mo',
              subtitle: packages[i].bookingLimit == -1
                  ? 'Unlimited bookings · '
                        '${packages[i].discountPercentage.toStringAsFixed(0)}% off'
                  : '${packages[i].bookingLimit} bookings/mo · '
                        '${packages[i].discountPercentage.toStringAsFixed(0)}% off',
            ),
          ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  static String _statusLabel(Enum status) {
    final name = status.name;
    return name[0].toUpperCase() + name.substring(1);
  }

  static String _paymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
        return 'Card';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bkash:
        return 'bKash';
      case PaymentMethod.nagad:
        return 'Nagad';
    }
  }

  static String _paymentStatusLabel(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.voided:
        return 'Voided';
    }
  }

  static String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.tourist:
        return 'Tourist';
      case UserRole.guide:
        return 'Guide';
      case UserRole.hotelManager:
        return 'Hotel Manager';
      case UserRole.admin:
        return 'Admin';
    }
  }

  static String _fmtRevenue(dynamic value) {
    final amount = (value is num ? value : 0).toDouble().round().toString();
    final b = StringBuffer();
    for (var i = 0; i < amount.length; i++) {
      if (i > 0 && (amount.length - i) % 3 == 0) b.write(',');
      b.write(amount[i]);
    }
    return b.toString();
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = CgColors.of(context);
    return CgCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: c.gMint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: c.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: CgType.t16.copyWith(color: c.text),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CgType.l12.copyWith(
                    fontSize: 11,
                    color: c.text2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Donut chart painter for the dashboard's booking-type distribution.
class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final Color emptyColor;

  const _DonutPainter({
    required this.values,
    required this.colors,
    required this.emptyColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    final stroke = 26.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    if (total <= 0) {
      paint.color = emptyColor;
      canvas.drawCircle(
        size.center(Offset.zero),
        (size.shortestSide - stroke) / 2,
        paint,
      );
      return;
    }

    final rect = Offset.zero & size;
    const gap = 0.04;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * math.pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        rect.deflate(stroke / 2),
        start + gap,
        math.max(0.001, sweep - gap * 2),
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter oldDelegate) =>
      oldDelegate.values != values ||
      oldDelegate.colors != colors ||
      oldDelegate.emptyColor != emptyColor;
}
