import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme.dart';
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
      body: NatureBackground.wrap(child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
            ),

            // ─── Filter pills ────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24 + MediaQuery.textScalerOf(context).scale(20),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  itemCount: _filters.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final value = _filters[index];
                    return CGChip(
                      label: value,
                      isSelected: _filter == value,
                      onTap: () {
                        setState(() => _filter = value);
                        _load();
                      },
                    );
                  },
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
      )),
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
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Icon(
              Icons.book_outlined,
              size: 48,
              color: AppColors.textHint(context),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style:  TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary(context),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              CGButton(
                label: actionLabel,
                width: 200,
                height: 24 + MediaQuery.textScalerOf(context).scale(20),
                onPressed: onAction,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(onPressed: onRetry, child: const Text('Try Again')),
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider(context), width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft(context),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:  Icon(
                  Icons.flight_takeoff_rounded,
                  color: AppColors.primary(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style:  TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.type} \u2022 ${widget.date}',
                      style:  TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CGStatusBadge(
                      label:
                          widget.status[0].toUpperCase() +
                          widget.status.substring(1),
                      color: _getStatusColor(widget.status),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.price,
                      style:  TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
      ),
    );
  }

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
        return Colors.grey;
    }
  }
}
