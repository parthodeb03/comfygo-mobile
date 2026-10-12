import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/travel_widgets.dart';
import 'package:comfygo/features/destinations/screens/destinations_screen.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/services/services.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

final _sample = <String, dynamic>{
  'id': 1,
  'name': 'Sundarbans',
  'description': 'Mangrove forest and river cruises.',
  'location': 'Khulna Division',
  'division': 'Khulna',
  'address': 'Khulna, Bangladesh',
  'created_at': '2026-09-17',
  'images': <String>[],
  'rating': 4.6,
  'review_count': 12,
  'price': 15000,
};

class _Destinations implements DestinationService {
  @override
  dynamic noSuchMethod(Invocation i) =>
      Future<List<Destination>>.value([Destination.fromJson(_sample)]);

  @override
  Future<Destination?> getDestinationById(int id) async =>
      Destination.fromJson(_sample);
}

void main() {
  testWidgets('List screens paint the photo backdrop under a green gradient', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          destinationServiceProvider.overrideWithValue(_Destinations()),
        ],
        child: MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const RepaintBoundary(
            key: ValueKey('backdrop'),
            child: DestinationsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The backdrop asset must be decoded before the capture, otherwise the
    // photo layer is still blank in the frame.
    await tester.runAsync(() async {
      await precacheImage(
        const AssetImage(TravelPhotos.listGreen),
        tester.element(find.byType(MaterialApp)),
      );
    });
    await tester.pumpAndSettle();

    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('backdrop')),
    );
    late ByteData raw;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final codec = await ui.instantiateImageCodec(png!.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final decoded = frame.image;
      raw = (await decoded.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      final out = File('test_artifacts/list_backdrop_destinations.png')
        ..createSync(recursive: true);
      out.writeAsBytesSync(png.buffer.asUint8List());
      decoded.dispose();
      image.dispose();
    });

    final pixels = raw.buffer.asUint8List();
    var r = 0.0, g = 0.0, b = 0.0, count = 0.0;
    var sumSq = 0.0;
    for (var i = 0; i + 3 < pixels.length; i += 4 * 97) {
      final pr = pixels[i].toDouble();
      final pg = pixels[i + 1].toDouble();
      final pb = pixels[i + 2].toDouble();
      r += pr;
      g += pg;
      b += pb;
      sumSq +=
          (0.299 * pr + 0.587 * pg + 0.114 * pb) *
          (0.299 * pr + 0.587 * pg + 0.114 * pb);
      count += 1;
    }
    final meanR = r / count, meanG = g / count, meanB = b / count;
    final meanLuma = 0.299 * meanR + 0.587 * meanG + 0.114 * meanB;
    final variance = sumSq / count - meanLuma * meanLuma;

    // ignore: avoid_print
    print(
      'backdrop mean RGB=(${meanR.toStringAsFixed(1)}, '
      '${meanG.toStringAsFixed(1)}, ${meanB.toStringAsFixed(1)}) '
      'luma=${meanLuma.toStringAsFixed(1)} variance=${variance.toStringAsFixed(1)}',
    );

    // The flat theme background is #F3F5F7 (243,245,247); the photo backdrop
    // is visibly darker and greener than that.
    expect(meanB, lessThan(238), reason: 'backdrop should not be flat white');
    expect(meanG, greaterThanOrEqualTo(meanR), reason: 'backdrop is greenish');
    expect(meanG, greaterThanOrEqualTo(meanB), reason: 'backdrop is greenish');
    expect(variance, greaterThan(200), reason: 'photo texture must show');
    expect(tester.takeException(), isNull);
  });
}
