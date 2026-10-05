import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';

class TransportsScreen extends ConsumerStatefulWidget {
  const TransportsScreen({super.key});

  @override
  ConsumerState<TransportsScreen> createState() => _TransportsScreenState();
}

class _TransportsScreenState extends ConsumerState<TransportsScreen> {
  final _search = TextEditingController();
  String _selected = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _load() => ref
      .read(transportsProvider.notifier)
      .loadTransports(
        search: _search.text.trim().isEmpty ? null : _search.text.trim(),
        type: _selected == 'All' ? null : _selected.toLowerCase(),
      );

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(transportsProvider);

    return Scaffold(
      backgroundColor: OneUIColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Transports'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search transports...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        _search.clear();
                        _load();
                      },
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24 + MediaQuery.textScalerOf(context).scale(20),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemCount: _types.length,
                  itemBuilder: (context, index) {
                    final value = _types[index];
                    return CGChip(
                      label: value,
                      isSelected: _selected == value,
                      onTap: () {
                        setState(() => _selected = value);
                        _load();
                      },
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (data.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (data.error != null || data.transports.isEmpty)
              SliverToBoxAdapter(
                child: _buildEmpty(
                  data.error != null
                      ? 'Unable to load transports.'
                      : 'No transports found.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = data.transports[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TransportCard(
                        from: item.fromLocation,
                        to: item.toLocation,
                        type: item.type.toUpperCase(),
                        operator: item.operatorName ?? item.name,
                        time:
                            '${item.departureTime}${item.arrivalTime != null ? ' → ${item.arrivalTime}' : ''}',
                        seats: '${item.availableSeats} seats',
                        price: '৳${item.price.toStringAsFixed(0)}',
                      ),
                    );
                  }, childCount: data.transports.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.directions_bus_rounded,
              size: 48,
              color: OneUIColors.textHintLight,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: OneUIColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _types = ['All', 'Bus', 'Train', 'Flight', 'Car'];
}

class _TransportCard extends StatelessWidget {
  final String from, to, type, operator, time, seats, price;

  const _TransportCard({
    required this.from,
    required this.to,
    required this.type,
    required this.operator,
    required this.time,
    required this.seats,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OneUIColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OneUIColors.dividerLight, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: OneUIColors.primarySoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: OneUIColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                operator,
                style: const TextStyle(
                  fontSize: 13,
                  color: OneUIColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                from,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OneUIColors.textPrimaryLight,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: OneUIColors.primaryLight,
                ),
              ),
              Text(
                to,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OneUIColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text(
                '$time • $seats',
                style: const TextStyle(
                  fontSize: 12,
                  color: OneUIColors.textSecondaryLight,
                ),
              ),
              Text(
                price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: OneUIColors.primaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
