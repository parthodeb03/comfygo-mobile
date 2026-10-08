import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/features/destinations/screens/destinations_screen.dart';
import 'package:comfygo/features/profile/screens/profile_screen.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/services/services.dart';
import 'package:comfygo/state/auth_provider.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DestinationService implements DestinationService {
  @override
  Future<List<Destination>> getDestinations({
    int page = 1,
    int limit = 20,
    String? search,
    String? division,
  }) async => [
    Destination(
      id: 1,
      name: 'A scenic destination',
      description: 'Explore beautiful landscapes and local culture on a relaxing trip with plenty of memorable activities and sights to enjoy.',
      location: 'A long location name',
      division: 'Chittagong',
      images: [],
      rating: 4.8,
      reviewCount: 12,
      price: 1500,
      createdAt: DateTime(2026),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final role in UserRole.values) {
    testWidgets('Profile renders ${role.name} role and nationality', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserProvider.overrideWithValue(
              User(
                id: 1,
                email: 'test@example.com',
                fullName: 'Test User',
                phone: '',
                role: role,
                nationality: 'Bangladeshi',
                createdAt: DateTime(2026),
              ),
            ),
          ],
          child: MaterialApp(
            theme: OneUITheme.lightTheme,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Bangladeshi'), findsOneWidget);
      final labels = {
        UserRole.tourist: 'Tourist',
        UserRole.guide: 'Guide',
        UserRole.hotelManager: 'Hotel Manager',
        UserRole.admin: 'Administrator',
      };
      expect(find.text(labels[role]!), findsOneWidget);
    });
  }

  for (final width in [360.0, 433.8, 900.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('Destination card fits width $width at text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              destinationServiceProvider.overrideWithValue(
                _DestinationService(),
              ),
            ],
            child: MaterialApp(
              theme: OneUITheme.lightTheme,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const DestinationsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Select\ndestination'), findsOneWidget);
        expect(find.text('A scenic destination'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
