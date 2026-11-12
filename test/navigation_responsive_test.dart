import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/comfy_ui.dart';
import 'package:comfygo/core/widgets/navigation_shell.dart';
import 'package:comfygo/core/widgets/travel_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() { // Phase 3 · Testing and Finalization (2 Nov – 22 Nov 2026): tests, defect fixes, accessibility, docs, release build.
  for (final width in [320.0, 840.0, 1440.0]) {
    testWidgets('Navigation adapts and follows the route at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        routes: [
          ShellRoute(
            builder: (_, _, child) => NavigationShell(child: child),
            routes: [
              for (final route in NavigationShell.routes)
                GoRoute(
                  path: route,
                  builder: (_, _) => TravelScaffold(
                    body: Builder(
                      builder: (context) => Center(
                        child: Text(
                          'Content width: ${MediaQuery.sizeOf(context).width}',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            theme: OneUITheme.lightTheme,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final wide = width >= 840;
      expect(find.byType(wide ? NavigationRail : CgBottomNav), findsOneWidget);

      // Profile is the fifth destination.
      if (wide) {
        await tester.tap(find.text('Profile'));
      } else {
        await tester.tap(find.byIcon(Icons.person_outline_rounded));
      }
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/profile');
      if (wide) {
        expect(
          tester
              .widget<NavigationRail>(find.byType(NavigationRail))
              .selectedIndex,
          4,
        );
      } else {
        expect(
          tester.widget<CgBottomNav>(find.byType(CgBottomNav)).currentIndex,
          4,
        );
      }

      // Home must be reachable from every width and every tab.
      if (wide) {
        await tester.tap(find.text('Home'));
      } else {
        await tester.tap(find.byIcon(Icons.home_outlined));
      }
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/');
      if (wide) {
        expect(
          tester
              .widget<NavigationRail>(find.byType(NavigationRail))
              .selectedIndex,
          0,
        );
      } else {
        expect(
          tester.widget<CgBottomNav>(find.byType(CgBottomNav)).currentIndex,
          0,
        );
      }

      // Saved is the fourth tab and is reachable from both layouts.
      if (wide) {
        await tester.tap(find.text('Saved'));
      } else {
        await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      }
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/saved');

      expect(tester.takeException(), isNull);
    });
  }
}
