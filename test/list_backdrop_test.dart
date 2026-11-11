// ComfyGo Project Plan — Phase 3 · Testing and Finalization
// Provider, widget and flow tests from the Phase 3 plan.

import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/comfy_ui.dart';
import 'package:comfygo/features/destinations/screens/destinations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Explore paints the gradient backdrop under trip cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const DestinationsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Sreemangal'), findsNWidgets(2));
    expect(find.byType(CgTripCard), findsNWidgets(4));

    final backdrop = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(CgBackground),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = backdrop.decoration as BoxDecoration;
    // The backdrop photo is tinted by the shared wash gradient so trip cards
    // and text stay readable on top of it.
    expect(decoration.gradient, CgBackground.washFor(false));
    // The photo itself is layered underneath the wash.
    final backdropImages = tester.widgetList<Image>(
      find.descendant(
        of: find.byType(CgBackground),
        matching: find.byType(Image),
      ),
    );
    String? assetNameOf(ImageProvider provider) {
      while (provider is ResizeImage) {
        provider = provider.imageProvider;
      }
      return provider is AssetImage ? provider.assetName : null;
    }

    expect(
      backdropImages.any(
        (img) => assetNameOf(img.image) == kCgBackdropAsset,
      ),
      isTrue,
      reason: 'The shared backdrop photo should sit under the wash',
    );
    expect(tester.takeException(), isNull);
  });
}
