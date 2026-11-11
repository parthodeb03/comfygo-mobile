// ComfyGo Project Plan — Phase 3 · Testing and Finalization
// Provider, widget and flow tests from the Phase 3 plan.

import 'dart:io';

import 'package:comfygo/core/theme/comfy_design.dart';
import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/travel_widgets.dart';
import 'package:comfygo/features/home/screens/home_screen.dart';
import 'package:comfygo/features/profile/screens/profile_screen.dart';
import 'package:comfygo/state/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    expect(lightScaffold.backgroundColor, CgColors.light.bg);

    await tester.ensureVisible(find.text('Dark mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();

    expect(container.read(themeProvider).isDarkMode, isTrue);
    Scaffold darkScaffold = tester.widget<Scaffold>(
      find.byType(Scaffold).first,
    );
    expect(darkScaffold.backgroundColor, CgColors.dark.bg);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Category chips filter the Home trip cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Category'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Mountain'), findsOneWidget);
    expect(find.text('Bandarban'), findsNWidgets(2));
    expect(find.text('Sundarbans'), findsNWidgets(2));

    await tester.tap(find.text('Mountain'));
    await tester.pumpAndSettle();
    expect(find.text('Bandarban'), findsNWidgets(2));
    expect(find.text('Sundarbans'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
