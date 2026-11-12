import 'package:comfygo/features/auth/screens/login_screen.dart';
import 'package:comfygo/features/auth/screens/signup_screen.dart';
import 'package:comfygo/features/bookings/screens/bookings_screen.dart';
import 'package:comfygo/features/destinations/screens/destinations_screen.dart';
import 'package:comfygo/features/destinations/screens/trip_detail_screen.dart';
import 'package:comfygo/features/home/screens/home_screen.dart';
import 'package:comfygo/features/onboarding/screens/intro_screen.dart';
import 'package:comfygo/features/profile/screens/profile_screen.dart';
import 'package:comfygo/data/comfy_destinations.dart';
import 'package:comfygo/features/saved/screens/saved_screen.dart';
import 'package:comfygo/models/booking_model.dart';
import 'package:comfygo/services/booking_service.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeBookingService implements BookingService { // Phase 3 · Testing and Finalization (2 Nov – 22 Nov 2026): tests, defect fixes, accessibility, docs, release build.
  @override
  Future<List<Booking>> getMyBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async => [
    Booking(
      id: 1,
      touristId: 1,
      touristName: 'Test User',
      type: BookingType.destination,
      status: BookingStatus.confirmed,
      itemId: 1,
      itemName: 'Sreemangal',
      checkIn: DateTime(2026, 11, 12),
      checkOut: DateTime(2026, 11, 14),
      guests: 2,
      totalPrice: 6400,
      createdAt: DateTime(2026, 11, 1),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('every bundled destination photo and illustration loads', () async {
    final paths = <String>{'assets/illustrations/intro_scene.svg'};
    for (final item in comfyDestinations) {
      paths.addAll(item.images);
    }
    for (final path in paths) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: 'Empty asset $path');
    }
  });

  final screens = <String, Widget>{
    'intro': const IntroScreen(),
    'login': const LoginScreen(),
    'signup': const SignupScreen(),
    'home': const HomeScreen(),
    'explore': const DestinationsScreen(),
    'saved': const SavedScreen(),
    'bookings': const BookingsScreen(),
    'profile': const ProfileScreen(),
    'detail': const TripDetailScreen(id: 1),
  };

  for (final size in const [Size(390, 844), Size(320, 640)]) {
    for (final entry in screens.entries) {
      testWidgets('${entry.key} renders at ${size.width}x${size.height}', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          ProviderScope(
            overrides: entry.key == 'bookings'
                ? [
                    bookingServiceProvider.overrideWithValue(
                      _FakeBookingService(),
                    ),
                  ]
                : const [],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(useMaterial3: true),
              home: entry.value,
            ),
          ),
        );
        if (entry.key == 'intro') {
          // The intro artwork floats forever, so settle one frame at a time.
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
        } else {
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final entry in screens.entries) {
    testWidgets('${entry.key} renders at 1.6 text scale', (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: entry.key == 'bookings'
              ? [
                  bookingServiceProvider.overrideWithValue(
                    _FakeBookingService(),
                  ),
                ]
              : const [],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.6)),
              child: child!,
            ),
            home: entry.value,
          ),
        ),
      );
      if (entry.key == 'intro') {
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      } else {
        await tester.pumpAndSettle();
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('home and detail survive scrolling', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -900));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: TripDetailScreen(id: 2))),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('dark theme renders home, profile and detail', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final screen in <Widget>[
      const HomeScreen(),
      const ProfileScreen(),
      const TripDetailScreen(id: 3),
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
            home: screen,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
