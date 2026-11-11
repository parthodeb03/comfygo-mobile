// ComfyGo Project Plan — Phase 3 · Testing and Finalization
// Widget coverage for the reference landing / sign-in / sign-up screens.
import 'package:comfygo/features/auth/screens/login_screen.dart';
import 'package:comfygo/features/auth/screens/signup_screen.dart';
import 'package:comfygo/core/router/app_router.dart';
import 'package:comfygo/features/auth/screens/welcome_screen.dart';
import 'package:comfygo/features/auth/widgets/reference_art.dart';
import 'package:comfygo/features/auth/widgets/reference_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  Size size = const Size(390, 844),
  double textScale = 1,
  bool dark = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: dark ? Brightness.dark : Brightness.light,
        ),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: screen,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('landing page', () {
    testWidgets('shows the reference copy and both actions', (tester) async {
      await _pump(tester, const WelcomeScreen());

      expect(find.text('Travel and share moments with us'), findsOneWidget);
      expect(
        find.text(
          'Share the moments that matter, connect with fellow travellers and '
          'turn every journey into a story.',
        ),
        findsOneWidget,
      );
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.byType(CgCollage), findsOneWidget);
      expect(find.text('Sreemangal, Sylhet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone and 1.6x text', (tester) async {
      await _pump(
        tester,
        const WelcomeScreen(),
        size: const Size(320, 640),
        textScale: 1.6,
      );
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('sign in', () {
    testWidgets('shows the reference form', (tester) async {
      await _pump(tester, const LoginScreen());

      expect(find.text('ComfyGo'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      // The field hint repeats the label, hence `findsWidgets`.
      expect(find.text('Password'), findsWidgets);
      expect(find.text('Sign in'), findsOneWidget);
      expect(find.text('Create an account'), findsOneWidget);
      expect(find.byType(CgRefField), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects an invalid email before calling the API', (
      tester,
    ) async {
      await _pump(tester, const LoginScreen());

      await tester.enterText(find.byType(TextField).first, 'not-an-email');
      await tester.tap(find.text('Sign in'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fits a small phone and 1.6x text', (tester) async {
      await _pump(
        tester,
        const LoginScreen(),
        size: const Size(320, 640),
        textScale: 1.6,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('sign up', () {
    testWidgets('shows every field, role and the terms row', (tester) async {
      await _pump(tester, const SignupScreen());

      expect(find.text('Create account'), findsNWidgets(2));
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Mobile number'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.byType(CgRefField), findsNWidgets(4));
      expect(find.byType(CgRefChip), findsNWidgets(3));
      expect(find.text('Tourist'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);
      expect(find.text('Hotel manager'), findsOneWidget);
      expect(
        find.textContaining('I agree to the', findRichText: true),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('validates an empty form', (tester) async {
      await _pump(tester, const SignupScreen());

      final submit = find.widgetWithText(CgRefButton, 'Create account');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(find.text('Enter your full name'), findsOneWidget);
      expect(
        find.text('Enter a valid Bangladesh mobile number'),
        findsOneWidget,
      );
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(find.text('Please accept the terms to continue'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('role chips can be selected', (tester) async {
      await _pump(tester, const SignupScreen());

      final guideChip = find.widgetWithText(CgRefChip, 'Guide');
      await tester.ensureVisible(guideChip);
      await tester.pumpAndSettle();
      await tester.tap(guideChip);
      await tester.pumpAndSettle();

      final guide = tester.widget<CgRefChip>(
        find.widgetWithText(CgRefChip, 'Guide'),
      );
      final tourist = tester.widget<CgRefChip>(
        find.widgetWithText(CgRefChip, 'Tourist'),
      );
      expect(guide.selected, isTrue);
      expect(tourist.selected, isFalse);
    });

    testWidgets('fits a small phone and 1.6x text', (tester) async {
      await _pump(
        tester,
        const SignupScreen(),
        size: const Size(320, 640),
        textScale: 1.6,
      );
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  test('landing route is registered before sign in', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    final paths = router.configuration.routes
        .whereType<GoRoute>()
        .map((route) => route.path)
        .toList();

    expect(paths, contains('/welcome'));
    expect(paths.indexOf('/welcome'), lessThan(paths.indexOf('/login')));
  });

  testWidgets('auth screens render in dark mode', (tester) async {
    for (final screen in <Widget>[
      const WelcomeScreen(),
      const LoginScreen(),
      const SignupScreen(),
    ]) {
      await _pump(tester, screen, dark: true);
      expect(tester.takeException(), isNull);
    }
  });
}
