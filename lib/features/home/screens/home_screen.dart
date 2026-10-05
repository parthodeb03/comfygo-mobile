import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../../state/service_providers.dart';
import '../../../state/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final destinations = ref.watch(destinationsProvider);
    final hotels = ref.watch(hotelsProvider);
    final name = user?.fullName.trim().split(' ').first;
    return TravelScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${name == null || name.isEmpty ? 'Traveler' : name}!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Where to next?',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      readOnly: true,
                      onTap: () => context.go('/destinations'),
                      decoration: const InputDecoration(
                        hintText: 'Search destinations',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const TravelBanner(
                      title: 'A little closer to adventure.',
                      subtitle: 'Explore the coast, wander through tea gardens, and discover your favorite corner of Bangladesh.',
                      asset: TravelPhotos.home,
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final entry in [
                          ('Explore', '/destinations', Icons.explore_outlined),
                          ('Hotels', '/hotels', Icons.hotel_outlined),
                          (
                            'Transport',
                            '/transports',
                            Icons.directions_bus_outlined,
                          ),
                          ('Guides', '/guides', Icons.map_outlined),
                        ])
                          ActionChip(
                            avatar: Icon(entry.$3, size: 18),
                            label: Text(entry.$1),
                            onPressed: () => context.push(entry.$2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TravelSection(
                title: 'Top Destinations',
                subtitle: 'Make room for a new experience.',
                onSeeAll: () => context.go('/destinations'),
                child: destinations.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : destinations.error != null
                    ? TravelEmpty(
                        message: 'Unable to load destinations.',
                        onRetry: () => ref
                            .read(destinationsProvider.notifier)
                            .loadDestinations(),
                      )
                    : destinations.destinations.isEmpty
                    ? const TravelEmpty(
                        message: 'No destinations available yet',
                      )
                    : TravelGrid(
                        children: [
                          for (final item in destinations.destinations.take(6))
                            TravelCard(
                              title: item.name,
                              subtitle: item.division,
                              asset: TravelPhotos.forDestination(item.name),
                              imageUrl: item.images.isEmpty
                                  ? null
                                  : item.images.first,
                              price: '৳${item.price.toStringAsFixed(0)}',
                              onTap: () =>
                                  context.push('/destinations/${item.id}'),
                            ),
                        ],
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: TravelSection(
                title: 'Popular Hotels',
                subtitle: 'A comfortable stay, wherever you go.',
                onSeeAll: () => context.push('/hotels'),
                child: hotels.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hotels.error != null
                    ? TravelEmpty(
                        message: 'Unable to load hotels.',
                        onRetry: () =>
                            ref.read(hotelsProvider.notifier).loadHotels(),
                      )
                    : hotels.hotels.isEmpty
                    ? const TravelEmpty(message: 'No hotels available yet')
                    : TravelGrid(
                        children: [
                          for (final item in hotels.hotels.take(3))
                            TravelCard(
                              title: item.name,
                              subtitle: item.location,
                              asset: TravelPhotos.hotels,
                              imageUrl: item.images.isEmpty
                                  ? null
                                  : item.images.first,
                              price:
                                  '৳${item.pricePerNight.toStringAsFixed(0)}',
                              priceLabel: '/ night',
                              onTap: () => context.push('/hotels/${item.id}'),
                            ),
                        ],
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TravelBanner(
                      title: 'Your next chapter starts here.',
                      subtitle: 'Find a travel plan with the benefits that fit your journey.',
                      asset: TravelPhotos.journey,
                      eyebrow: 'TRAVEL YOUR WAY',
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context.push('/packages'),
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Explore travel plans'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
