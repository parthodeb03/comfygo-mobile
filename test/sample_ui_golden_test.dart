import 'dart:io';

import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/travel_widgets.dart';
import 'package:comfygo/features/destinations/screens/destination_detail_screen.dart';
import 'package:comfygo/features/home/screens/home_screen.dart';
import 'package:comfygo/models/destination_model.dart';
import 'package:comfygo/models/hotel_model.dart';
import 'package:comfygo/services/destination_service.dart';
import 'package:comfygo/services/hotel_service.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _destination = Destination(
  id: 7,
  name: 'Sylhet',
  description: 'Tea gardens, waterfalls, and river valleys.',
  location: 'Sylhet Division',
  division: 'Sylhet',
  images: const [],
  rating: 4.8,
  reviewCount: 42,
  price: 1500,
  activities: const [
    DestinationActivity(
      imageUrl: '',
      name: 'Tea Garden Tour',
      type: 'Sightseeing Tour',
      startTimes: ['9:00 AM', '2:00 PM'],
      rating: 5,
      price: 1200,
    ),
    DestinationActivity(
      imageUrl: '',
      name: 'Jaflong River Visit',
      type: 'Guided Experience',
      startTimes: ['10:00 AM', '3:00 PM'],
      rating: 4,
      price: 900,
    ),
  ],
  createdAt: DateTime(2026),
);

final _hotel = Hotel(
  id: 9,
  name: 'Tea Resort',
  description: 'A quiet stay in the hills.',
  location: 'Sreemangal',
  division: 'Sylhet',
  address: 'Sreemangal, Sylhet',
  images: const [],
  rating: 4.7,
  reviewCount: 20,
  pricePerNight: 4200,
  managerId: 1,
  amenities: const [],
  totalRooms: 20,
  availableRooms: 8,
  createdAt: DateTime(2026),
);

class _DestinationApi implements DestinationService {
  _DestinationApi(this.destination);
  final Destination destination;

  @override
  Future<Destination?> getDestinationById(int id) async => destination;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getDestinations ||
        invocation.memberName == #getFeaturedDestinations) {
      return Future<List<Destination>>.value([destination]);
    }
    return super.noSuchMethod(invocation);
  }
}

class _HotelApi implements HotelService {
  _HotelApi(this.hotel);
  final Hotel hotel;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #getHotels) {
      return Future<List<Hotel>>.value([hotel]);
    }
    return super.noSuchMethod(invocation);
  }
}

Future<void> _precacheSampleAssets(WidgetTester tester) async {
  final context = tester.element(find.byType(MaterialApp));
  await tester.runAsync(() async {
    await precacheImage(
      AssetImage(TravelPhotos.forDestination('Sylhet', 'Sylhet')),
      context,
    );
    await precacheImage(AssetImage(TravelPhotos.hotels), context);
  });
}

void main() {
  setUpAll(() async {
    final muli = FontLoader('Muli')
      ..addFont(rootBundle.load('assets/fonts/Muli-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Muli-Bold.ttf'));
    await muli.load();
    final icons = FontLoader('FontAwesomeSolid')
      ..addFont(rootBundle.load('assets/fonts/FontAwesomeSolid.otf'));
    await icons.load();
    final material = FontLoader('MaterialIcons')
      ..addFont(
        File(
          r'C:\flutter\bin\cache\artifacts\material_fonts\materialicons-regular.otf',
        ).readAsBytes().then(ByteData.sublistView),
      );
    await material.load();
    final bengali = FontLoader('Nirmala UI')
      ..addFont(
        File(r'C:\Windows\Fonts\Nirmala.ttf')
            .readAsBytes()
            .then(ByteData.sublistView),
      );
    await bengali.load();
    final emoji = FontLoader('Segoe UI Emoji')
      ..addFont(
        File(r'C:\Windows\Fonts\seguiemj.ttf')
            .readAsBytes()
            .then(ByteData.sublistView),
      );
    await emoji.load();
  });

  testWidgets('Home matches the sample carousel layout', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          destinationServiceProvider.overrideWithValue(
            _DestinationApi(_destination),
          ),
          hotelServiceProvider.overrideWithValue(_HotelApi(_hotel)),
        ],
        child: MaterialApp(
          theme: OneUITheme.lightTheme.copyWith(
            textTheme: OneUITheme.lightTheme.textTheme.apply(
              fontFamilyFallback: const ['Nirmala UI', 'Segoe UI Emoji'],
            ),
          ),
          home: Scaffold(
            backgroundColor: const Color(0xFFF3F5F7),
            body: const HomeScreen(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: 0,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: 30),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bookmark_border, size: 30),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: CircleAvatar(
                    radius: 15,
                    child: Icon(Icons.person, size: 18),
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await _precacheSampleAssets(tester);
    await tester.pumpAndSettle();
    expect(find.text('What would you like to find?'), findsOneWidget);
    expect(find.text('Top Destinations'), findsOneWidget);
    expect(find.text('Exclusive Hotels'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/comfygo_home.png'),
    );
  });

  testWidgets('Destination matches the sample hero and activity cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          destinationServiceProvider.overrideWithValue(
            _DestinationApi(_destination),
          ),
        ],
        child: MaterialApp(
          theme: OneUITheme.lightTheme.copyWith(
            textTheme: OneUITheme.lightTheme.textTheme.apply(
              fontFamilyFallback: const ['Nirmala UI', 'Segoe UI Emoji'],
            ),
          ),
          home: const DestinationDetailScreen(id: 7),
        ),
      ),
    );
    await _precacheSampleAssets(tester);
    await tester.pumpAndSettle();
    expect(find.text('Sylhet'), findsOneWidget);
    expect(find.text('Sylhet, Bangladesh'), findsOneWidget);
    expect(find.text('Tea Garden Tour'), findsOneWidget);
    expect(find.text('per pax'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await expectLater(
      find.byType(DestinationDetailScreen),
      matchesGoldenFile('goldens/comfygo_destination.png'),
    );
  });
  testWidgets('Destination controls search, sort, and show location', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          destinationServiceProvider.overrideWithValue(
            _DestinationApi(_destination),
          ),
        ],
        child: MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const DestinationDetailScreen(id: 7),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Search activities'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Jaflong');
    await tester.tap(find.widgetWithText(FilledButton, 'Search'));
    await tester.pumpAndSettle();
    expect(find.text('Jaflong River Visit'), findsOneWidget);
    expect(find.text('Tea Garden Tour'), findsNothing);

    await tester.tap(find.byTooltip('Sort activities'));
    await tester.pumpAndSettle();
    expect(find.text('Price: low to high'), findsOneWidget);
    await tester.tap(find.byTooltip('Show location'));
    await tester.pumpAndSettle();
    expect(find.text('Sylhet'), findsNWidgets(2));
    expect(find.text('Sylhet Division\nSylhet, Bangladesh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Back arrow returns to destinations from a direct detail link', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/destinations/7',
      routes: [
        GoRoute(
          path: '/destinations',
          builder: (_, _) => const Scaffold(body: Text('Destination list')),
        ),
        GoRoute(
          path: '/destinations/:id',
          builder: (_, state) => DestinationDetailScreen(
            id: int.parse(state.pathParameters['id']!),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          destinationServiceProvider.overrideWithValue(
            _DestinationApi(_destination),
          ),
        ],
        child: MaterialApp.router(
          theme: OneUITheme.lightTheme,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back to destinations'));
    await tester.pumpAndSettle();
    expect(find.text('Destination list'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
