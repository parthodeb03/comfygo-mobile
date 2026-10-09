import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/travel_widgets.dart';
import '../../../models/destination_model.dart';
import '../../../models/hotel_model.dart';
import '../../../state/service_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selected = 0;
  static const _icons = [
    IconData(0xf072, fontFamily: 'FontAwesomeSolid'),
    IconData(0xf236, fontFamily: 'FontAwesomeSolid'),
    IconData(0xf554, fontFamily: 'FontAwesomeSolid'),
    IconData(0xf206, fontFamily: 'FontAwesomeSolid'),
  ];

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationsProvider);
    final hotels = ref.watch(hotelsProvider);
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: .20,
            child: Image.asset(TravelPhotos.home, fit: BoxFit.cover),
          ),
        ),
        Positioned.fill(
          child: ColoredBox(color: Colors.white.withValues(alpha: .82)),
        ),
        SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 30),
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 120),
                child: Text(
                  'What would you like to find?',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < _icons.length; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() => _selected = i);
                        final route = switch (i) {
                          0 => '/transports',
                          1 => '/hotels',
                          2 => '/guides',
                          _ => '/destinations',
                        };
                        context.go(route);
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selected == i
                              ? const Color(0xFFD8ECF1)
                              : const Color(0xFFE7EBEE),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          _icons[i],
                          size: 25,
                          color: _selected == i
                              ? const Color(0xFF3EBACE)
                              : const Color(0xFFB4C1C4),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              _DestinationCarousel(
                items: destinations.destinations,
                loading: destinations.isLoading,
                error: destinations.error,
                retry: () =>
                    ref.read(destinationsProvider.notifier).loadDestinations(),
              ),
              const SizedBox(height: 20),
              _HotelCarousel(
                items: hotels.hotels,
                loading: hotels.isLoading,
                error: hotels.error,
                retry: () => ref.read(hotelsProvider.notifier).loadHotels(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DestinationCarousel extends StatelessWidget {
  const _DestinationCarousel({
    required this.items,
    required this.loading,
    required this.error,
    required this.retry,
  });
  final List<Destination> items;
  final bool loading;
  final String? error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Header(
        title: 'Top Destinations',
        onTap: () => context.go('/destinations'),
      ),
      SizedBox(
        height: 300,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
                child: TextButton(onPressed: retry, child: const Text('Retry')),
              )
            : items.isEmpty
            ? const Center(child: Text('No destinations available'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final cardWidth = (MediaQuery.sizeOf(context).width * .64)
                      .clamp(210.0, 280.0);
                  final photoSize = cardWidth - 30;
                  final imagePath = item.images.isEmpty
                      ? TravelPhotos.forDestination(item.name, item.division)
                      : item.images.first;
                  return GestureDetector(
                    onTap: () => context.push('/destinations/${item.id}'),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      width: cardWidth,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            bottom: 5,
                            child: Container(
                              width: cardWidth - 10,
                              height: 120,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F0E8),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.bottomLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.activities?.length ?? 0} activities',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      item.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Hero(
                                  tag: imagePath,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: SizedBox(
                                      width: photoSize,
                                      height: photoSize,
                                      child: TravelPhoto(
                                        url: item.images.isEmpty
                                            ? null
                                            : item.images.first,
                                        asset: TravelPhotos.forDestination(
                                          item.name,
                                          item.division,
                                        ),
                                        label: item.name,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 10,
                                  right: 8,
                                  bottom: 10,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            IconData(
                                              0xf124,
                                              fontFamily: 'FontAwesomeSolid',
                                            ),
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              item.division,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
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
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ],
  );
}

class _HotelCarousel extends StatelessWidget {
  const _HotelCarousel({
    required this.items,
    required this.loading,
    required this.error,
    required this.retry,
  });
  final List<Hotel> items;
  final bool loading;
  final String? error;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _Header(title: 'Exclusive Hotels', onTap: () => context.push('/hotels')),
      SizedBox(
        height: 300,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? Center(
                child: TextButton(onPressed: retry, child: const Text('Retry')),
              )
            : items.isEmpty
            ? const Center(child: Text('No hotels available'))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final cardWidth = (MediaQuery.sizeOf(context).width * .72)
                      .clamp(230.0, 310.0);
                  final photoWidth = cardWidth - 20;
                  return GestureDetector(
                    onTap: () => context.push('/hotels/${item.id}'),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      width: cardWidth,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          Positioned(
                            bottom: 5,
                            child: Container(
                              width: cardWidth,
                              height: 120,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Color(0xFFF3EBDD),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '\u09F3${item.pricePerNight.toStringAsFixed(0)} / night',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: photoWidth,
                                height: 180,
                                child: TravelPhoto(
                                  url: item.images.isEmpty
                                      ? null
                                      : item.images.first,
                                  asset: TravelPhotos.hotels,
                                  label: item.name,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    ],
  );
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onTap,
          child: const FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'See All',
              style: TextStyle(
                color: Color(0xFF3EBACE),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
