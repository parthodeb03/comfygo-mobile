import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:comfygo/core/widgets/travel_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/services/services.dart';
import 'package:comfygo/state/auth_provider.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:comfygo/features/admin/screens/admin_panel_screen.dart';
import 'package:comfygo/features/auth/screens/forgot_password_screen.dart';
import 'package:comfygo/features/auth/screens/login_screen.dart';
import 'package:comfygo/features/auth/screens/signup_screen.dart';
import 'package:comfygo/features/bookings/screens/booking_detail_screen.dart';
import 'package:comfygo/features/bookings/screens/bookings_screen.dart';
import 'package:comfygo/features/destinations/screens/destination_detail_screen.dart';
import 'package:comfygo/features/destinations/screens/destinations_screen.dart';
import 'package:comfygo/features/guides/screens/guide_detail_screen.dart';
import 'package:comfygo/features/guides/screens/guides_screen.dart';
import 'package:comfygo/features/home/screens/home_screen.dart';
import 'package:comfygo/features/hotels/screens/hotel_detail_screen.dart';
import 'package:comfygo/features/hotels/screens/hotels_screen.dart';
import 'package:comfygo/features/packages/screens/packages_screen.dart';
import 'package:comfygo/features/payments/screens/payment_screen.dart';
import 'package:comfygo/features/profile/screens/profile_screen.dart';
import 'package:comfygo/features/transports/screens/transports_screen.dart';

final sample = <String, dynamic>{
  'id': 1,
  'name': 'A beautiful place with a longer name',
  'description': 'Discover beautiful scenery and memorable experiences with your friends and family on your next journey.',
  'location': 'Chittagong Hill Tracts',
  'division': 'Chittagong',
  'address': 'Bangladesh',
  'created_at': '2026-09-17',
  'manager_id': 1,
  'user_id': 1,
  'specialization': 'Trekking and local adventures',
  'departure_time': '10:30 AM',
  'from_location': 'Dhaka',
  'to_location': 'Chittagong',
  'type': 'hotel',
  'status': 'confirmed',
  'tourist_id': 1,
  'item_id': 1,
  'item_name': 'A scenic stay for your next adventure',
  'check_in': '2026-10-10',
  'price': 1500,
  'price_per_night': 3500,
  'daily_rate': 2000,
  'total_price': 7500,
};

class _Destinations implements DestinationService {
  @override
  dynamic noSuchMethod(Invocation i) => Future<List<Destination>>.value([
    Destination.fromJson(sample),
    Destination.fromJson({...sample, 'id': 2}),
  ]);
}

class _Hotels implements HotelService {
  @override
  dynamic noSuchMethod(Invocation i) =>
      Future<List<Hotel>>.value([Hotel.fromJson(sample)]);
}

class _Guides implements GuideService {
  @override
  dynamic noSuchMethod(Invocation i) =>
      Future<List<Guide>>.value([Guide.fromJson(sample)]);
}

class _Transports implements TransportService {
  @override
  dynamic noSuchMethod(Invocation i) => Future<List<Transport>>.value([
    Transport.fromJson({...sample, 'type': 'bus'}),
  ]);
}

class _Bookings implements BookingService {
  @override
  dynamic noSuchMethod(Invocation i) =>
      Future<List<Booking>>.value([Booking.fromJson(sample)]);
}

class _Packages implements PackageService {
  @override
  dynamic noSuchMethod(Invocation i) =>
      Future<List<Package>>.value(Package.predefinedPackages);
}

void main() {
  const capture = bool.fromEnvironment('CAPTURE_DESIGN');
  setUpAll(() async {
    if (capture) {
      final loader = FontLoader('Roboto');
      loader.addFont(
        File(const String.fromEnvironment('DESIGN_FONT'))
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)),
      );
      await loader.load();
      final icons = FontLoader('MaterialIcons');
      icons.addFont(
        File(const String.fromEnvironment('DESIGN_ICONS'))
            .readAsBytes()
            .then((bytes) => ByteData.sublistView(bytes)),
      );
      await icons.load();
    }
  });
  final screens = <String, Widget>{
    'AdminPanelScreen': const AdminPanelScreen(),
    'ForgotPasswordScreen': const ForgotPasswordScreen(),
    'LoginScreen': const LoginScreen(),
    'SignupScreen': const SignupScreen(),
    'BookingDetailScreen': const BookingDetailScreen(id: 1),
    'BookingsScreen': const BookingsScreen(),
    'DestinationDetailScreen': const DestinationDetailScreen(id: 1),
    'DestinationsScreen': const DestinationsScreen(),
    'GuideDetailScreen': const GuideDetailScreen(id: 1),
    'GuidesScreen': const GuidesScreen(),
    'HomeScreen': const HomeScreen(),
    'HotelDetailScreen': const HotelDetailScreen(id: 1),
    'HotelsScreen': const HotelsScreen(),
    'PackagesScreen': const PackagesScreen(),
    'PaymentScreen': const PaymentScreen(bookingId: 1),
    'ProfileScreen': const ProfileScreen(),
    'TransportsScreen': const TransportsScreen(),
  };
  for (final config in [
    (320.0, 1.0, 900.0, false),
    (390.0, 1.0, 900.0, false),
    (768.0, 1.0, 900.0, false),
    (1440.0, 1.0, 900.0, false),
    (320.0, 1.6, 900.0, false),
    (844.0, 1.0, 390.0, false),
    (390.0, 1.0, 900.0, true),
  ]) {
    for (final entry in screens.entries) {
      testWidgets(
        '${entry.key} at ${config.$1}px text ${config.$2} height ${config.$3} dark ${config.$4}',
        (tester) async {
          SharedPreferences.setMockInitialValues({});
          tester.view.physicalSize = Size(config.$1, config.$3);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final originalError = FlutterError.onError;
          FlutterError.onError = (details) {
            debugPrint(details.toString());
            originalError?.call(details);
          };
          addTearDown(() => FlutterError.onError = originalError);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                currentUserProvider.overrideWithValue(
                  User(
                    id: 1,
                    email: 'traveler@example.com',
                    fullName: 'A Bangladesh Traveler',
                    phone: '',
                    role: UserRole.admin,
                    createdAt: DateTime(2026),
                    nationality: 'Bangladeshi',
                  ),
                ),
                destinationServiceProvider.overrideWithValue(_Destinations()),
                hotelServiceProvider.overrideWithValue(_Hotels()),
                guideServiceProvider.overrideWithValue(_Guides()),
                transportServiceProvider.overrideWithValue(_Transports()),
                bookingServiceProvider.overrideWithValue(_Bookings()),
                packageServiceProvider.overrideWithValue(_Packages()),
              ],
              child: MaterialApp(
                theme: config.$4 ? OneUITheme.darkTheme : OneUITheme.lightTheme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.linear(config.$2)),
                  child: child!,
                ),
                home: RepaintBoundary(
                  key: const ValueKey('design-preview'),
                  child: entry.value,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: 'Initial layout');
          if (capture) {
            await tester.runAsync(() async {
              for (final asset in [
                TravelPhotos.home,
                TravelPhotos.explore,
                TravelPhotos.bandarban,
                TravelPhotos.forest,
                TravelPhotos.journey,
              ]) {
                await precacheImage(
                  AssetImage(asset),
                  tester.element(find.byType(MaterialApp)),
                );
              }
            });
            await tester.pumpAndSettle();
            final boundary = tester.renderObject<RenderRepaintBoundary>(
              find.byKey(const ValueKey('design-preview')),
            );
            await tester.runAsync(() async {
              final image = await boundary.toImage();
              final bytes = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              final folder = Directory('build/design-previews')
                ..createSync(recursive: true);
              await File(
                '${folder.path}/${entry.key}-${config.$1}-${config.$4}.png',
              ).writeAsBytes(bytes!.buffer.asUint8List());
              image.dispose();
            });
          }
          final scrollables = find.byType(Scrollable);
          if (scrollables.evaluate().isNotEmpty) {
            final state = tester.state<ScrollableState>(scrollables.first);
            if (state.position.axis == Axis.vertical) {
              for (
                var step = 0;
                step < 30 &&
                    state.position.pixels < state.position.maxScrollExtent;
                step++
              ) {
                state.position.jumpTo(
                  (state.position.pixels + 500).clamp(
                    0,
                    state.position.maxScrollExtent,
                  ),
                );
                await tester.pumpAndSettle();
                expect(
                  tester.takeException(),
                  isNull,
                  reason: 'Scrolled layout',
                );
              }
            }
          }
        },
      );
    }
  }
}
