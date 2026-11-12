// Golden coverage for the reference landing / sign-in / sign-up screens.
import 'dart:async';
import 'dart:io';

import 'package:comfygo/features/auth/screens/login_screen.dart';
import 'package:comfygo/features/auth/screens/signup_screen.dart';
import 'package:comfygo/features/auth/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled families so the golden files show real typography instead
/// of the test placeholder font.
Future<void> _loadFonts() async { // Phase 3 · Testing and Finalization (2 Nov – 22 Nov 2026): tests, defect fixes, accessibility, docs, release build.
  const families = <String, List<String>>{
    'PlayfairDisplay': [
      'PlayfairDisplay-Regular.ttf',
      'PlayfairDisplay-SemiBold.ttf',
      'PlayfairDisplay-Bold.ttf',
    ],
    'DMSans': ['DMSans-Regular.ttf', 'DMSans-Medium.ttf', 'DMSans-Bold.ttf'],
    'HindSiliguri': ['HindSiliguri-Regular.ttf'],
  };

  for (final entry in families.entries) {
    final loader = FontLoader(entry.key);
    for (final file in entry.value) {
      loader.addFont(rootBundle.load('assets/fonts/$file'));
    }
    await loader.load();
  }

  // Material icons so the back affordance renders instead of a placeholder box.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    final icons = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (icons.existsSync()) {
      await (FontLoader('MaterialIcons')..addFont(
            Future.value(ByteData.sublistView(icons.readAsBytesSync())),
          ))
          .load();
    }
  }
}

/// Decodes the landing collage photos up front; otherwise a golden captured
/// straight after `pump` shows the cards before their images have loaded.
Future<void> _precacheCollage(WidgetTester tester) async {
  const assets = [
    'assets/images/Coxs Bazar/Coxs_Bazar.jfif',
    'assets/images/Sundarban/Sundarbans.jfif',
    'assets/images/Srimangal/Srimangal_1.jfif',
  ];

  await tester.runAsync(() async {
    for (final asset in assets) {
      final stream = AssetImage(asset).resolve(ImageConfiguration.empty);
      final loaded = Completer<void>();
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (image, synchronousCall) {
          stream.removeListener(listener);
          if (!loaded.isCompleted) loaded.complete();
        },
        onError: (error, stackTrace) {
          stream.removeListener(listener);
          if (!loaded.isCompleted) loaded.completeError(error, stackTrace);
        },
      );
      stream.addListener(listener);
      await loaded.future;
    }
  });
}

void main() {
  setUpAll(_loadFonts);

  Future<void> snap(WidgetTester tester, String name, Widget screen) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('landing page golden', (tester) async {
    await _precacheCollage(tester);
    await snap(tester, 'auth_welcome', const WelcomeScreen());
  });

  testWidgets('sign in golden', (tester) async {
    await snap(tester, 'auth_signin', const LoginScreen());
  });

  testWidgets('sign up golden', (tester) async {
    await snap(tester, 'auth_signup', const SignupScreen());
  });
}
