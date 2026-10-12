import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove listing?'),
        content: Text('"${hotel.name}" will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(color: OneUIColors.error),
            ),
          ),
        ],
      ),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Void payment?'),
        content: Text(
          'Payment #${payment.id} of ৳${payment.amount.toStringAsFixed(0)} '
          'will be voided and retained in the audit history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Void',
              style: TextStyle(color: OneUIColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _acting = true);
    final result = await ref
        .read(adminServiceProvider)
        .voidPayment(payment.id, reason: 'Voided by admin');
    if (!mounted) return;
    setState(() => _acting = false);
    _showSnack(result != null ? 'Payment voided' : 'Could not void the payment');
    if (result != null) await _loadAll();
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
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            key: const Key('admin-refresh'),
            tooltip: 'Refresh',
            onPressed: _loading ? null : _loadAll,
            icon: const Icon(Icons.refresh_rounded, size: 22),
          ),
        ],
      ),
      body: NatureBackground.wrap(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats summary — real numbers
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.surface(context),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.people_rounded,
                        value: '${_stats?['users'] ?? 0}',
                        label: 'Users',
                        color: AppColors.primary(context),
                      ),
                      _StatItem(
                        icon: Icons.book_rounded,
                        value: '${_stats?['bookings'] ?? 0}',
                        label: 'Bookings',
                        color: const Color(0xFF4CAF50),
                      ),
                      _StatItem(
                        icon: Icons.attach_money_rounded,
                        value: '৳${_fmtRevenue(_stats?['revenue'])}',
                        label: 'Revenue',
                        color: const Color(0xFFFFB300),
                      ),
                      _StatItem(
                        icon: Icons.card_membership_rounded,
                        value: '${_stats?['active_packages'] ?? 0}',
                        label: 'Plans',
                        color: const Color(0xFF7E57C2),
                      ),
                    ],
                  ),
                ),

                // Tab bar
                Container(
                  color: AppColors.surface(context),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'Users'),
                      Tab(text: 'Bookings'),
                      Tab(text: 'Payments'),
                      Tab(text: 'Listings'),
                      Tab(text: 'Packages'),
                    ],
                  ),
                ),

                // Tab content
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
            )),
    );
  }

  // ── Dashboard (statistical view) ──────────────────────────────────

  Widget _buildDashboardTab() {
    final bookings = _bookings ?? <Booking>[];
    final payments = _payments ?? <Payment>[];
    final revenue = ((_stats?['revenue'] as num?) ?? 0).toDouble();

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
        const Color(0xFF1B7A4F),
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
        const Color(0xFF1B7A4F),
      ),
      (
        'Transport',
        bookings.where((b) => b.type == BookingType.transport).length,
        AppColors.brandGreen,
      ),
      (
        'Guides',
        bookings.where((b) => b.type == BookingType.guide).length,
        const Color(0xFFFF8F50),
      ),
      (
        'Tours',
        bookings.where((b) => b.type == BookingType.destination).length,
        const Color(0xFF7E57C2),
      ),
    ];

    final completedPayments =
        payments.where((p) => p.status == PaymentStatus.completed).toList();
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
      padding: const EdgeInsets.all(20),
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
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${bookings.length}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        Text(
                          'bookings',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                      Text(
                        '${entry.$2}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            children: [
                              Container(
                                height: 16,
                                color: AppColors.surfaceVariant(context),
                              ),
                              FractionallySizedBox(
                                widthFactor: bookings.isEmpty
                                    ? 0
                                    : (entry.$2 / bookings.length)
                                          .clamp(0.0, 1.0),
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
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _dashboardCard(
          title: 'Revenue summary',
          subtitle: 'From completed payments',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '৳${_fmtRevenue(revenue)}',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary(context),
                ),
              ),
              const SizedBox(height: 14),
              _dashboardStatRow(
                'Payments received',
                '${completedPayments.length} of ${payments.length}',
              ),
              _dashboardStatRow(
                'Average payment',
                '৳${_fmtRevenue(averagePayment)}',
              ),
              _dashboardStatRow('Success rate', '${(successRate * 100).round()}%'),
              _dashboardStatRow(
                'Active subscriptions',
                '${_stats?['active_packages'] ?? 0}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _dashboardCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _dashboardStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final users = _users;
    if (users == null || users.isEmpty) {
      return const TravelEmpty(message: 'No users found.');
    }
    return ListView.separated(
      itemCount: users.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
      itemBuilder: (context, index) {
        final user = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primarySoft(context),
            child: Text(
              user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
              style:  TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          title: Text(
            user.fullName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${_roleLabel(user.role)} • ${user.email}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: const Icon(Icons.more_vert_rounded, size: 20),
        );
      },
    );
  }

  Widget _buildBookingsTab() {
    final bookings = _bookings;
    if (bookings == null || bookings.isEmpty) {
      return const TravelEmpty(message: 'No bookings found.');
    }
    return ListView.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
      itemBuilder: (context, index) {
        final b = bookings[index];
        final statusLabel = b.status.name;
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              switch (b.type) {
                BookingType.hotel => Icons.hotel_rounded,
                BookingType.transport => Icons.directions_bus_rounded,
                BookingType.guide => Icons.person_rounded,
                BookingType.destination => Icons.location_on_rounded,
              },
              color: AppColors.primary(context),
              size: 20,
            ),
          ),
          title: Text(
            b.itemName.isEmpty ? 'Booking #${b.id}' : b.itemName,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${b.touristName} • ৳${_fmtRevenue(b.totalPrice)}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: CGStatusBadge(
            label: statusLabel[0].toUpperCase() + statusLabel.substring(1),
            color: _getStatusColor(statusLabel),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    final payments = _payments;
    if (payments == null || payments.isEmpty) {
      return const TravelEmpty(message: 'No payments found.');
    }
    return ListView.separated(
      itemCount: payments.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
      itemBuilder: (context, index) {
        final p = payments[index];
        final isCompleted = p.status == PaymentStatus.completed;
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isCompleted ? OneUIColors.success : OneUIColors.statusPending)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.payment_rounded,
              color: isCompleted
                  ? OneUIColors.success
                  : OneUIColors.statusPending,
              size: 20,
            ),
          ),
          title: Text(
            '৳${_fmtRevenue(p.amount)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${_paymentMethodLabel(p.method)}'
            ' • ${_paymentStatusLabel(p.status)}'
            '${p.cardLastFour != null ? ' • *${p.cardLastFour}' : ''}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: p.status == PaymentStatus.voided ||
                  p.status == PaymentStatus.refunded
              ? null
              : TextButton.icon(
                  onPressed: () => _voidPayment(p),
                  icon: const Icon(Icons.block_rounded, size: 17),
                  label: const Text('Void'),
                  style: TextButton.styleFrom(
                    foregroundColor: OneUIColors.error,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildListingsTab() {
    final listings = _listings;
    if (listings == null || listings.isEmpty) {
      return const TravelEmpty(message: 'No listings found.');
    }
    return ListView.separated(
      itemCount: listings.length,
      separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
      itemBuilder: (context, index) {
        final l = listings[index];
        return ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child:  Icon(
              Icons.business_rounded,
              color: AppColors.primary(context),
              size: 20,
            ),
          ),
          title: Text(
            l.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            'Hotel • ${l.location}'
            '${l.isApproved ? '' : ' • awaiting approval'}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!l.isApproved)
                IconButton(
                  key: Key('approve-listing-${l.id}'),
                  tooltip: 'Approve',
                  onPressed: _acting ? null : () => _approveListing(l),
                  icon: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: OneUIColors.success,
                  ),
                ),
              IconButton(
                key: Key('remove-listing-${l.id}'),
                tooltip: 'Remove',
                onPressed: _acting ? null : () => _removeListing(l),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: OneUIColors.error,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPackagesTab() {
    final packagesState = ref.watch(packagesProvider);
    final packages = packagesState.packages.isNotEmpty
        ? packagesState.packages
        : Package.predefinedPackages;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '${_stats?['active_packages'] ?? 0} active subscriptions',
            style:  TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        if ((_userPackages ?? []).isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Recent subscriptions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _userPackages!.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
            itemBuilder: (context, index) {
              final subscription = _userPackages![index];
              final color = _getTierColor(subscription.package.tier);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.12),
                  child: Icon(Icons.person_outline_rounded, color: color, size: 20),
                ),
                title: Text('${subscription.package.name} ? User #${subscription.userId}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text('${subscription.status.name} ? ends ${subscription.endDate.toLocal().toString().split(' ').first}', style: const TextStyle(fontSize: 12)),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 18, 16, 4),
            child: Text('Available tiers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: packages.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 64),
          itemBuilder: (context, index) {
            final p = packages[index];
            final color = _getTierColor(p.tier);
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.card_membership_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(
                '${p.name} - ${p.price == 0 ? 'Free' : '৳${p.price.toStringAsFixed(2)}'}/mo',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                p.bookingLimit == -1
                    ? 'Unlimited bookings • ${p.discountPercentage.toStringAsFixed(0)}% off'
                    : '${p.bookingLimit} bookings/mo • ${p.discountPercentage.toStringAsFixed(0)}% off',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
            );
          },
        ),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OneUIColors.statusPending;
      case 'confirmed':
        return OneUIColors.statusConfirmed;
      case 'completed':
        return OneUIColors.statusCompleted;
      case 'cancelled':
        return OneUIColors.statusCancelled;
      default:
        return Colors.grey;
    }
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

  static Color _getTierColor(PackageTier tier) {
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style:  TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
          ),
        ),
        Text(
          label,
          style:  TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}


/// Donut chart painter for the dashboard's booking-type distribution.
class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  const _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<double>(0, (a, b) => a + b);
    final stroke = 26.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    if (total <= 0) {
      paint.color = const Color(0xFFE1EAE2);
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
      oldDelegate.values != values || oldDelegate.colors != colors;
}
