import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/features/guides/screens/guides_screen.dart';
import 'package:comfygo/features/spots/screens/spots_screen.dart';
import 'package:comfygo/features/transports/screens/transports_screen.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/services/services.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Minimal payload that satisfies every list model used by these screens.
final sample = <String, dynamic>{
  'id': 1,
  'name': 'A beautiful place',
  'description': 'Scenery and memorable experiences on your next journey.',
  'location': 'Chittagong',
  'division': 'Chittagong',
  'address': 'Bangladesh',
  'created_at': '2026-09-17',
  'manager_id': 1,
  'user_id': 1,
  'specialization': 'Trekking and local adventures',
  'departure_time': '10:30 AM',
  'from_location': 'Dhaka',
  'to_location': 'Chittagong',
  'type': 'bus',
  'status': 'confirmed',
  'tourist_id': 1,
  'item_id': 1,
  'item_name': 'A scenic stay',
  'check_in': '2026-10-10',
  'price': 1500,
  'price_per_night': 3500,
  'daily_rate': 2000,
  'total_price': 7500,
};

class _Transports implements TransportService {
  @override
  dynamic noSuchMethod(Invocation i) =>
      Future<List<Transport>>.value([Transport.fromJson(sample)]);

  @override
  Future<Transport?> getTransportById(int id) async =>
      Transport.fromJson(sample);
}

class _Guides implements GuideService {
  @override
  dynamic noSuchMethod(Invocation i) =>
      Future<List<Guide>>.value([Guide.fromJson(sample)]);

  @override
  Future<Guide?> getGuideById(int id) async => Guide.fromJson(sample);
}

Future<void> _pumpRouter(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        transportServiceProvider.overrideWithValue(_Transports()),
        guideServiceProvider.overrideWithValue(_Guides()),
      ],
      child: MaterialApp.router(
        theme: OneUITheme.lightTheme,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

GoRouter _routerFor(String location, GoRouterWidgetBuilder screen) {
  return GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Home stub'))),
      ),
      GoRoute(path: location, builder: screen),
    ],
  );
}

void main() {
  testWidgets('Back returns home when the screen has no history (transports)', (
    tester,
  ) async {
    // Reached with context.go('/transports') — nothing to pop.
    final router = _routerFor(
      '/transports',
      (_, _) => const TransportsScreen(),
    );
    addTearDown(router.dispose);
    await _pumpRouter(tester, router);
    expect(find.text('Home stub'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Home stub'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Back returns home when the screen has no history (guides)', (
    tester,
  ) async {
    final router = _routerFor('/guides', (_, _) => const GuidesScreen());
    addTearDown(router.dispose);
    await _pumpRouter(tester, router);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Home stub'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Back pops the pushed route when history exists', (tester) async {
    final router = _routerFor(
      '/transports',
      (_, _) => const TransportsScreen(),
    );
    addTearDown(router.dispose);
    await _pumpRouter(tester, router);

    // Push the screen on top of home, then come back.
    router.go('/');
    await tester.pumpAndSettle();
    expect(find.text('Home stub'), findsOneWidget);

    router.push('/transports');
    await tester.pumpAndSettle();
    expect(find.text('Home stub'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Home stub'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Tourist spots back arrow returns home without history', (
    tester,
  ) async {
    final router = _routerFor('/spots', (_, _) => const SpotsScreen());
    addTearDown(router.dispose);
    await _pumpRouter(tester, router);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Home stub'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
