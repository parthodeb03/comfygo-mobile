import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  bool _loading = true;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    ]);

    if (!mounted) return;
    setState(() {
      _stats = results[0] as Map<String, dynamic>;
      _users = results[1] as List<User>;
      _bookings = results[2] as List<Booking>;
      _payments = results[3] as List<Payment>;
      _listings = results[4] as List<Hotel>;
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
          'will be marked as refunded.',
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
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats summary — real numbers
                Container(
                  padding: const EdgeInsets.all(16),
                  color: OneUIColors.surfaceLight,
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 12,
                    alignment: WrapAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.people_rounded,
                        value: '${_stats?['users'] ?? 0}',
                        label: 'Users',
                        color: OneUIColors.primaryLight,
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
                  color: OneUIColors.surfaceLight,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const [
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
            backgroundColor: OneUIColors.primarySoft,
            child: Text(
              user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(),
              style: const TextStyle(
                color: OneUIColors.primaryLight,
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
              color: OneUIColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              switch (b.type) {
                BookingType.hotel => Icons.hotel_rounded,
                BookingType.transport => Icons.directions_bus_rounded,
                BookingType.guide => Icons.person_rounded,
                BookingType.destination => Icons.location_on_rounded,
              },
              color: OneUIColors.primaryLight,
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
            '${p.method == PaymentMethod.card ? 'Card' : 'Cash'}'
            ' • ${_paymentStatusLabel(p.status)}'
            '${p.cardLastFour != null ? ' • *${p.cardLastFour}' : ''}',
            style: const TextStyle(fontSize: 12),
          ),
          trailing: PopupMenuButton<String>(
            key: Key('payment-menu-${p.id}'),
            onSelected: (value) {
              if (value == 'void') _voidPayment(p);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'void', child: Text('Void payment')),
            ],
            icon: const Icon(Icons.more_vert_rounded, size: 20),
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
              color: OneUIColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: OneUIColors.primaryLight,
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
            style: const TextStyle(
              fontSize: 13,
              color: OneUIColors.textSecondaryLight,
            ),
          ),
        ),
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: OneUIColors.textPrimaryLight,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: OneUIColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}
