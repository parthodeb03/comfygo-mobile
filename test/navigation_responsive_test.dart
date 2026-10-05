import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:comfygo/core/widgets/navigation_shell.dart';
import 'package:comfygo/core/widgets/travel_widgets.dart';
import 'package:comfygo/core/theme/theme.dart';

void main() {
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
        MaterialApp.router(theme: OneUITheme.lightTheme, routerConfig: router),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(width >= 840 ? NavigationRail : NavigationBar),
        findsOneWidget,
      );
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/profile');
      if (width >= 840) {
        expect(
          tester
              .widget<NavigationRail>(find.byType(NavigationRail))
              .selectedIndex,
          3,
        );
      } else {
        expect(
          tester
              .widget<NavigationBar>(find.byType(NavigationBar))
              .selectedIndex,
          3,
        );
      }
      expect(tester.takeException(), isNull);
    });
  }
}
