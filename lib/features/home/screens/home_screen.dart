import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/widgets.dart';
import '../../../data/tourist_spots.dart';
import '../../../state/service_providers.dart';
import '../../../state/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _homeDivisions = [
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Khulna',
    'Rajshahi',
    'Barisal',
    'Rangpur',
    'Mymensingh',
  ];

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
                          ('Spots', '/spots', Icons.landscape_outlined),
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
                title: 'Explore by division',
                subtitle: 'Eight divisions, countless stories.',
                onSeeAll: () => context.go('/destinations'),
                child: SizedBox(
                  height: 116,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _homeDivisions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final division = _homeDivisions[index];
                      return TravelDivisionCard(
                        label: division,
                        asset: TravelPhotos.forDivision(division),
                        showCheck: false,
                        onTap: () =>
                            context.go('/destinations?division=$division'),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TravelSection(
                title: 'Featured tourist spots',
                subtitle: 'Where to go, how to get there, what to know.',
                onSeeAll: () => context.go('/spots'),
                child: Column(
                  children: [
                    for (final spot in [
                      touristSpots[0],
                      touristSpots[7],
                      touristSpots[12],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TravelRowCard(
                          title: spot.name,
                          subtitle: spot.tagline,
                          meta: '${spot.division} Division',
                          leadingIcon: Icons.place_rounded,
                          asset: spot.photo,
                          heroTag: 'spot_${spot.id}',
                          onTap: () => context.push('/spots/${spot.id}'),
                        ),
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
                              asset: TravelPhotos.forDestination(
                                item.name,
                                item.division,
                              ),
                              imageUrl: item.images.isEmpty
                                  ? null
                                  : item.images.first,
                              price: '৳${item.price.toStringAsFixed(0)}',
                              heroTag: 'destination_image_${item.id}',
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
                              heroTag: 'hotel_image_${item.id}',
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
