// ComfyGo Project Plan — Phase 3 · Testing and Finalization
// Provider, widget and flow tests from the Phase 3 plan.

import 'package:comfygo/features/destinations/screens/destinations_screen.dart';
import 'package:comfygo/features/profile/screens/profile_screen.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final role in UserRole.values) {
    testWidgets('Profile renders ${role.name} user details', (tester) async {
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
          child: MaterialApp(home: const ProfileScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
      expect(find.text('Dark mode'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
    });
  }

  for (final width in [360.0, 433.8, 900.0]) {
    for (final scale in [1.0, 1.5]) {
      testWidgets('Destination cards fit width $width at text scale $scale', (
        tester,
      ) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
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
        expect(find.text('Explore'), findsOneWidget);
        expect(find.text('Sreemangal'), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      });
    }
  }
}
