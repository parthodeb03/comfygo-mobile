/// Backend integration tests — exercises the REAL frontend service layer
/// against the live FastAPI backend at http://localhost:8000.
///
/// Run with the backend up:  uvicorn app.main:app --port 8000
library;

import 'dart:io';

import 'package:comfygo/services/api_client.dart';
import 'package:comfygo/services/auth_service.dart';
import 'package:comfygo/services/destination_service.dart';
import 'package:comfygo/services/guide_service.dart';
import 'package:comfygo/services/hotel_service.dart';
import 'package:comfygo/services/package_service.dart';
import 'package:comfygo/services/transport_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ApiClient apiClient;

  setUpAll(() {
    // flutter_test replaces the HTTP client with one that always returns 400.
    // These tests talk to the REAL backend, so restore the real client.
    HttpOverrides.global = null;

    // Platform channels used by ApiClient's interceptor stack
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dev.fluttercommunity.plus/connectivity'),
          (call) async {
            if (call.method == 'check') return <String>['wifi'];
            return null;
          },
        );
    apiClient = ApiClient();
  });

  group(
    'Live backend integration',
    () {
      group('Backend connectivity', () {
        test('backend health check succeeds', () async {
          final healthy = await apiClient.checkHealth();
          expect(
            healthy,
            isTrue,
            reason: 'Backend must be running at http://localhost:8000/health',
          );
        });
      });

      group('Public data endpoints (frontend service → backend)', () {
        test('destinations load and parse into models', () async {
          final service = DestinationService(apiClient);
          final items = await service.getDestinations();
          expect(
            items,
            isNotEmpty,
            reason: 'Seed data should have destinations',
          );
          for (final d in items) {
            expect(d.name, isNotEmpty);
            expect(d.price, greaterThan(0));
            expect(d.id, greaterThan(0));
          }
        });

        test('destination search filter works', () async {
          final service = DestinationService(apiClient);
          final items = await service.getDestinations(search: 'cox');
          expect(
            items,
            isNotEmpty,
            reason: "Search for 'cox' should match Cox's Bazar",
          );
        });

        test('destination by id returns full detail', () async {
          final service = DestinationService(apiClient);
          final item = await service.getDestinationById(1);
          expect(item, isNotNull);
          expect(item!.name, isNotEmpty);
          expect(item.description, isNotEmpty);
        });

        test('featured destinations endpoint works', () async {
          final service = DestinationService(apiClient);
          final items = await service.getFeaturedDestinations();
          expect(items, isNotEmpty);
        });

        test('hotels load and parse', () async {
          final service = HotelService(apiClient);
          final items = await service.getHotels();
          expect(items, isNotEmpty);
          for (final h in items) {
            expect(h.name, isNotEmpty);
            expect(h.pricePerNight, greaterThan(0));
            expect(
              h.images,
              isA<List<String>>(),
              reason: 'images field must exist for the UI fallback chain',
            );
          }
        });

        test('transports load and parse', () async {
          final service = TransportService(apiClient);
          final items = await service.getTransports();
          expect(items, isNotEmpty);
        });

        test('guides load and parse', () async {
          final service = GuideService(apiClient);
          final items = await service.getGuides();
          expect(items, isNotEmpty);
          expect(items.first.profileImage, isNotEmpty);
        });

        test('packages load and parse', () async {
          final service = PackageService(apiClient);
          final items = await service.getPackages();
          expect(items, isNotEmpty);
          expect(
            items.length,
            greaterThanOrEqualTo(4),
            reason: 'README lists Basic/Pro/Premium/Ultimate tiers',
          );
        });
      });

      group('Authentication flow', () {
        test('user login succeeds and returns user + token', () async {
          final service = AuthService(apiClient);
          final result = await service.login(
            email: 'ahmed@email.com',
            password: 'password123',
          );
          expect(result.isSuccess, isTrue, reason: result.message);
          expect(result.token, isNotNull);
          expect(result.user?.email, 'ahmed@email.com');
        });

        test('profile fetch works with the stored token', () async {
          final service = AuthService(apiClient);
          final login = await service.login(
            email: 'ahmed@email.com',
            password: 'password123',
          );
          expect(login.isSuccess, isTrue);

          final profile = await service.getProfile();
          expect(profile.isSuccess, isTrue, reason: profile.message);
          expect(profile.user?.email, 'ahmed@email.com');
        });

        test('wrong password fails with a user-facing message', () async {
          final service = AuthService(apiClient);
          final result = await service.login(
            email: 'ahmed@email.com',
            password: 'definitely-wrong',
          );
          expect(result.isSuccess, isFalse);
          expect(result.message, isNotNull);
        });
      });
    },
    skip: Platform.environment['RUN_BACKEND_INTEGRATION'] == 'true' ? false : 'Set RUN_BACKEND_INTEGRATION=true with FastAPI running on localhost:8000.',
  );
}
