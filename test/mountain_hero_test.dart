// Widget coverage for the mountain backdrop used by the reset-password flow.
import 'package:comfygo/features/auth/screens/forgot_password_screen.dart';
import 'package:comfygo/features/auth/widgets/mountain_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() { // Phase 3 · Testing and Finalization (2 Nov – 22 Nov 2026): tests, defect fixes, accessibility, docs, release build.
  testWidgets('forgot password shows the full-screen mountain background', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: ForgotPasswordScreen())),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CgMountainBackground), findsOneWidget);
    expect(find.byType(CgGlassPanel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
