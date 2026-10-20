import 'dart:io';
import 'dart:math' as math;

import 'package:comfygo/core/theme/design_tokens.dart';
import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/one_ui_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _luminance(Color color) {
  double channel(double value) {
    return value <= 0.04045
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('light theme is Material 3 and reads from tokens', () {
    final theme = OneUITheme.lightTheme;
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, ComfyColors.primaryLight);
    expect(theme.colorScheme.onPrimary, ComfyColors.onPrimaryLight);
    expect(theme.scaffoldBackgroundColor, ComfyColors.backgroundLight);
  });

  test('dark theme is designed, not an inverted light theme', () {
    final theme = OneUITheme.darkTheme;
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, ComfyColors.primaryDark);
    expect(theme.colorScheme.onPrimary, ComfyColors.onPrimaryDark);
    expect(theme.scaffoldBackgroundColor, ComfyColors.backgroundDark);
    expect(
      contrast(ComfyColors.textHintDark, ComfyColors.surfaceVariantDark),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('typography uses Playfair, DM Sans and the Bengali fallback', () {
    final theme = OneUITheme.lightTheme;
    expect(theme.textTheme.displayLarge?.fontFamily, ComfyType.displayFamily);
    expect(theme.textTheme.bodyMedium?.fontFamily, ComfyType.bodyFamily);
    expect(
      theme.textTheme.bodyMedium?.fontFamilyFallback,
      contains('HindSiliguri'),
    );
    expect(
      theme.textTheme.displayLarge?.fontFamilyFallback,
      contains('HindSiliguri'),
    );
  });

  test('all status and tier pairs meet WCAG AA for normal text', () {
    final pairs = <String, (Color, Color)>{
      'pending light': (
        ComfyColors.statusPendingLight,
        ComfyColors.statusPendingBgLight,
      ),
      'confirmed light': (
        ComfyColors.statusConfirmedLight,
        ComfyColors.statusConfirmedBgLight,
      ),
      'completed light': (
        ComfyColors.statusCompletedLight,
        ComfyColors.statusCompletedBgLight,
      ),
      'cancelled light': (
        ComfyColors.statusCancelledLight,
        ComfyColors.statusCancelledBgLight,
      ),
      'pending dark': (
        ComfyColors.statusPendingDark,
        ComfyColors.statusPendingBgDark,
      ),
      'confirmed dark': (
        ComfyColors.statusConfirmedDark,
        ComfyColors.statusConfirmedBgDark,
      ),
      'completed dark': (
        ComfyColors.statusCompletedDark,
        ComfyColors.statusCompletedBgDark,
      ),
      'cancelled dark': (
        ComfyColors.statusCancelledDark,
        ComfyColors.statusCancelledBgDark,
      ),
      'basic light': (ComfyColors.tierBasicLight, ComfyColors.tierBasicBgLight),
      'pro light': (ComfyColors.tierProLight, ComfyColors.tierProBgLight),
      'premium light': (
        ComfyColors.tierPremiumLight,
        ComfyColors.tierPremiumBgLight,
      ),
      'ultimate light': (
        ComfyColors.tierUltimateLight,
        ComfyColors.tierUltimateBgLight,
      ),
      'basic dark': (ComfyColors.tierBasicDark, ComfyColors.tierBasicBgDark),
      'pro dark': (ComfyColors.tierProDark, ComfyColors.tierProBgDark),
      'premium dark': (
        ComfyColors.tierPremiumDark,
        ComfyColors.tierPremiumBgDark,
      ),
      'ultimate dark': (
        ComfyColors.tierUltimateDark,
        ComfyColors.tierUltimateBgDark,
      ),
    };

    for (final entry in pairs.entries) {
      final ratio = contrast(entry.value.$1, entry.value.$2);
      expect(
        ratio,
        greaterThanOrEqualTo(4.5),
        reason: '${entry.key} is only ${ratio.toStringAsFixed(2)}:1',
      );
    }
  });

  test('all bundled font files exist and are non-empty', () {
    const fonts = <String>[
      'assets/fonts/PlayfairDisplay-Regular.ttf',
      'assets/fonts/PlayfairDisplay-SemiBold.ttf',
      'assets/fonts/PlayfairDisplay-Bold.ttf',
      'assets/fonts/DMSans-Regular.ttf',
      'assets/fonts/DMSans-Medium.ttf',
      'assets/fonts/DMSans-Bold.ttf',
      'assets/fonts/HindSiliguri-Regular.ttf',
      'assets/fonts/HindSiliguri-SemiBold.ttf',
      'assets/fonts/HindSiliguri-Bold.ttf',
    ];
    for (final font in fonts) {
      final file = File(font);
      expect(file.existsSync(), isTrue, reason: 'Missing $font');
      expect(file.lengthSync(), greaterThan(1000), reason: 'Empty $font');
    }
  });

  testWidgets('Bengali place names and the taka sign render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OneUITheme.lightTheme,
        home: const Scaffold(
          body: Center(child: Text('ঢাকা  সিলেট  ৳ 12,500')),
        ),
      ),
    );
    expect(find.text('ঢাকা  সিলেট  ৳ 12,500'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('booking status badge is at least 48dp and labeled', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: OneUITheme.lightTheme,
        home: const Scaffold(
          body: Center(child: OneUIBookingStatusChip(status: 'confirmed')),
        ),
      ),
    );
    final size = tester.getSize(find.byType(OneUIStatusChip));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
