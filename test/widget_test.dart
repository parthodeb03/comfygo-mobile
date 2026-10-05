import 'package:comfygo/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences for ThemeNotifier
    SharedPreferences.setMockInitialValues({});

    // ComfyGoApp requires a ProviderScope (normally added in main())
    await tester.pumpWidget(
      const ProviderScope(
        child: ComfyGoApp(),
      ),
    );

    // Pump a frame to let providers initialize (avoid pumpAndSettle:
    // the loading screen spinner never settles)
    await tester.pump(const Duration(seconds: 1));

    // Just verify the app builds without crashing
    expect(find.byType(ComfyGoApp), findsOneWidget);
  });
}
