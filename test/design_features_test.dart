import 'dart:io';

import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/travel_widgets.dart';
import 'package:comfygo/features/destinations/screens/destinations_screen.dart';
import 'package:comfygo/features/profile/screens/profile_screen.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/services/services.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:comfygo/state/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingDestinationService implements DestinationService {
  String? lastDivision;

  @override
  Future<List<Destination>> getDestinations({
    int page = 1,
    int limit = 20,
    String? search,
    String? division,
  }) async {
    lastDivision = division;
    return [
      Destination(
        id: 1,
        name: 'Sundarbans',
        description: "The world's largest mangrove forest.",
        location: 'Khulna Division',
        division: 'Khulna',
        images: [],
        rating: 4.8,
        reviewCount: 245,
        price: 15000,
        createdAt: DateTime(2026),
      ),
      Destination(
        id: 2,
        name: 'Bandarban',
        description: 'Home to the highest peaks of Bangladesh.',
        location: 'Chittagong Hill Tracts',
        division: 'Chittagong',
        images: [],
        rating: 4.5,
        reviewCount: 134,
        price: 12000,
        createdAt: DateTime(2026),
      ),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Bangladesh photo assets (division-wise & spot-wise)', () {
    test('every division photo exists on disk', () {
      expect(TravelPhotos.divisionPhotos.values.toSet().length, 8);
      for (final asset in TravelPhotos.divisionPhotos.values) {
        expect(
          File(asset).existsSync(),
          isTrue,
          reason: 'Missing division asset: $asset',
        );
      }
    });

    test('every spot photo exists on disk', () {
      expect(TravelPhotos.spotPhotos.length, greaterThanOrEqualTo(20));
      for (final entry in TravelPhotos.spotPhotos) {
        expect(
          File(entry.value).existsSync(),
          isTrue,
          reason: 'Missing spot asset: ${entry.value}',
        );
      }
    });

    test('spot photo wins over division photo', () {
      expect(
        TravelPhotos.forDestination('Sundarbans', 'Khulna'),
        TravelPhotos.spotSundarbans,
      );
      expect(
        TravelPhotos.forDestination("Cox's Bazar", 'Chittagong'),
        TravelPhotos.spotCoxsBazar,
      );
      expect(
        TravelPhotos.forDestination('Sylhet Tea Gardens', 'Sylhet'),
        TravelPhotos.spotSrimangal,
      );
      expect(
        TravelPhotos.forDestination('Bandarban', 'Chittagong'),
        TravelPhotos.spotBandarban,
      );
      expect(
        TravelPhotos.forDestination('Paharpur Buddhist Vihara', 'Rajshahi'),
        TravelPhotos.spotPaharpur,
      );
    });

    test('unknown spot falls back to its division photo', () {
      expect(
        TravelPhotos.forDestination('A quiet village', 'Rangpur'),
        TravelPhotos.divRangpur,
      );
      expect(
        TravelPhotos.forDestination('Unknown', 'Mymensingh'),
        TravelPhotos.divMymensingh,
      );
      expect(TravelPhotos.forDivision('Dhaka'), TravelPhotos.divDhaka);
      expect(TravelPhotos.forDivision('Barisal'), TravelPhotos.divBarisal);
      expect(
        TravelPhotos.forDivision('Chittagong'),
        TravelPhotos.divChittagong,
      );
      expect(TravelPhotos.forDivision(null), TravelPhotos.explore);
    });
  });

  testWidgets('Dark mode toggle in Profile switches the theme', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, ref, _) {
            final mode = ref.watch(themeProvider).themeMode;
            return MaterialApp(
              theme: OneUITheme.lightTheme,
              darkTheme: OneUITheme.darkTheme,
              themeMode: mode,
              home: const ProfileScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(ProfileScreen)),
    );
    expect(container.read(themeProvider).isDarkMode, isFalse);

    Scaffold lightScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    expect(lightScaffold.backgroundColor, OneUIColors.backgroundLight);

    await tester.ensureVisible(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(container.read(themeProvider).isDarkMode, isTrue);
    Scaffold darkScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    expect(darkScaffold.backgroundColor, OneUIColors.backgroundDark);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Destination category pills filter cards', (tester) async {
    final service = _RecordingDestinationService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [destinationServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const DestinationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Select\ndestination'), findsOneWidget);
    expect(find.text('Hills'), findsOneWidget);
    await tester.tap(find.text('Hills'));
    await tester.pumpAndSettle();
    expect(find.text('Bandarban'), findsOneWidget);
    expect(find.text('Sundarbans'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
