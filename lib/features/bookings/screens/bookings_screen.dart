import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/navigation.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _filter = 'All';

  void _load() => ref
      .read(bookingsProvider.notifier)
      .loadBookings(status: _filter == 'All' ? null : _filter.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(bookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: NatureBackground.wrap(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ─── Header ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RoundBackButton(onTap: () => goBack(context)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Bookings',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your plans, your memories, all in one place.',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Filter pills ────────────────────────────────
              // Wrap instead of a fixed-height horizontal list: the pills keep
              // their natural height, so labels are never clipped whatever the
              // text scale is.
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final value in _filters)
                        CGChip(
                          label: value,
                          isSelected: _filter == value,
                          activeColor: AppColors.brandGreen,
                          onTap: () {
                            setState(() => _filter = value);
                            _load();
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // ─── Bookings list ───────────────────────────────
              if (data.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              else if (data.error != null)
                SliverToBoxAdapter(
                  child: _buildEmpty('Unable to load bookings.', onRetry: _load),
                )
              else if (data.bookings.isEmpty)
                SliverToBoxAdapter(
                  child: _buildEmpty(
                    'No bookings yet. Start exploring destinations!',
                    actionLabel: 'Explore Destinations',
                    onAction: () => context.go('/destinations'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final booking = data.bookings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _BookingCard(
                          name: booking.itemName.isEmpty
                              ? 'Booking #${booking.id}'
                              : booking.itemName,
                          type: booking.type.name.toUpperCase(),
                          date:
                              '${booking.checkIn.day}/${booking.checkIn.month}/${booking.checkIn.year}',
                          price: '৳${booking.totalPrice.toStringAsFixed(0)}',
                          status: booking.status.name,
                          onTap: () => context.push('/bookings/${booking.id}'),
                        ),
                      );
                    }, childCount: data.bookings.length),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.greenSoft(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_outlined,
                size: 34,
                color: AppColors.accentGreen(context),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              CGButton(
                label: actionLabel,
                width: 230,
                height: 52,
                icon: Icons.explore_outlined,
                onPressed: onAction,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              CGButton(
                label: 'Try Again',
                width: 180,
                height: 48,
                isOutlined: true,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _filters = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];
}

class _RoundBackButton extends StatelessWidget {
  const _RoundBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.greenSoft(context),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          Icons.arrow_back_rounded,
          size: 20,
          color: AppColors.accentGreen(context),
          semanticLabel: 'Back',
        ),
      ),
    ),
  );
}

class _BookingCard extends StatefulWidget {
  final String name;
  final String type;
  final String date;
  final String price;
  final String status;
  final VoidCallback? onTap;

  const _BookingCard({
    required this.name,
    required this.type,
    required this.date,
    required this.price,
    required this.status,
    this.onTap,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.status);
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider(context), width: 0.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.greenSoft(context),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForType(widget.type),
                  color: AppColors.accentGreen(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // One flexible column: every label wraps instead of being
              // squeezed into a narrow side column (which clipped the text).
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _TypePill(label: widget.type),
                        Text(
                          widget.date,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusPill(
                          label:
                              widget.status[0].toUpperCase() +
                              widget.status.substring(1),
                          color: statusColor,
                        ),
                        Text(
                          widget.price,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accentGreen(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) => switch (type.toLowerCase()) {
    'hotel' => Icons.hotel_rounded,
    'transport' => Icons.directions_bus_rounded,
    'guide' => Icons.person_pin_circle_rounded,
    _ => Icons.flight_takeoff_rounded,
  };

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OneUIColors.statusPending;
      case 'confirmed':
        return OneUIColors.statusConfirmed;
      case 'cancelled':
        return OneUIColors.statusCancelled;
      case 'completed':
        return OneUIColors.statusCompleted;
      default:
        return OneUIColors.textHintLight;
    }
  }
}

/// Small pill for the booking type — fixed paddings, single line, so the
/// label renders completely at every text scale.
class _TypePill extends StatelessWidget {
  const _TypePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.primarySoft(context),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.primary(context),
      ),
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.45)),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}
