import 'dart:io';
import 'dart:typed_data';

import 'package:comfygo/core/theme/theme.dart';
import 'package:comfygo/core/widgets/widgets.dart';
import 'package:comfygo/data/tourist_spots.dart';
import 'package:comfygo/features/admin/screens/admin_panel_screen.dart';
import 'package:comfygo/features/bookings/screens/booking_form_screen.dart';
import 'package:comfygo/features/profile/screens/edit_profile_screen.dart';
import 'package:comfygo/features/profile/screens/help_support_screen.dart';
import 'package:comfygo/features/spots/screens/spot_detail_screen.dart';
import 'package:comfygo/features/spots/screens/spots_screen.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/services/admin_service.dart';
import 'package:comfygo/services/booking_service.dart';
import 'package:comfygo/services/invoice_pdf.dart';
import 'package:comfygo/services/transport_service.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Transport _transport({int total = 40, int available = 30, int id = 1}) =>
    Transport(
      id: id,
      name: 'Test Express',
      type: 'bus',
      description: 'Test route',
      fromLocation: 'Dhaka',
      toLocation: 'Sylhet',
      departureTime: '10:00 PM',
      price: 1000,
      totalSeats: total,
      availableSeats: available,
      amenities: const ['AC'],
      createdAt: DateTime(2026),
    );

Booking _booking({double total = 15000}) => Booking(
  id: 42,
  touristId: 1,
  touristName: 'Rahim Uddin',
  type: BookingType.hotel,
  status: BookingStatus.confirmed,
  itemId: 1,
  itemName: "Cox's Bazar Sea View Hotel",
  checkIn: DateTime(2026, 10, 12),
  checkOut: DateTime(2026, 10, 15),
  guests: 2,
  totalPrice: total,
  createdAt: DateTime(2026, 9, 1),
);

class _TransportService implements TransportService {
  @override
  Future<Transport?> getTransportById(int id) async => _transport();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _BookingService implements BookingService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _AdminService implements AdminService {
  @override
  Future<Map<String, dynamic>> getStats() async => {
    'users': 12,
    'bookings': 7,
    'revenue': 42500,
    'active_packages': 3,
  };

  @override
  Future<List<User>> getUsers({
    int limit = 50,
    int page = 1,
    String? role,
    String? search,
  }) async => [];

  @override
  Future<List<Booking>> getAllBookings({
    int limit = 50,
    int page = 1,
    String? status,
    String? type,
  }) async => [
    _booking(),
    Booking(
      id: 43,
      touristId: 2,
      touristName: 'Karim',
      type: BookingType.transport,
      status: BookingStatus.pending,
      itemId: 1,
      itemName: 'Bus',
      checkIn: DateTime(2026, 11, 1),
      guests: 1,
      totalPrice: 1000,
      createdAt: DateTime(2026, 9, 2),
    ),
  ];

  @override
  Future<List<Payment>> getAllPayments({
    int limit = 50,
    String? method,
    int page = 1,
    String? status,
  }) async => [
    Payment(
      id: 1,
      bookingId: 42,
      userId: 1,
      amount: 15000,
      method: PaymentMethod.card,
      status: PaymentStatus.completed,
      createdAt: DateTime(2026, 9, 3),
    ),
  ];

  @override
  Future<List<Hotel>> getAllListings({
    bool? approved,
    int limit = 50,
    int page = 1,
    String? type,
  }) async => [];

  @override
  Future<List<UserPackage>> getUserPackages({
    int page = 1,
    int limit = 100,
  }) async => [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Tourist spots content (division-wise)', () {
    test('every division is covered and content is complete', () {
      expect(touristSpots.length, greaterThanOrEqualTo(16));
      for (final division in spotDivisions) {
        expect(
          spotsForDivision(division).isNotEmpty,
          isTrue,
          reason: 'No spots for division $division',
        );
      }
      final ids = <String>{};
      for (final spot in touristSpots) {
        expect(ids.add(spot.id), isTrue, reason: 'Duplicate id ${spot.id}');
        expect(spot.description.length, greaterThan(80));
        expect(spot.howToReach.length, greaterThan(60));
        expect(spot.bestTime, isNotEmpty);
        expect(spot.tips.length, greaterThanOrEqualTo(3));
        expect(
          File(spot.photo).existsSync(),
          isTrue,
          reason: 'Missing photo ${spot.photo}',
        );
        // All content must be clean English (no Bengali script).
        expect(
          RegExp(r'[ঀ-৿]')
              .hasMatch(spot.description + spot.howToReach + spot.name),
          isFalse,
          reason: 'Non-English text in ${spot.name}',
        );
      }
    });

    testWidgets('SpotDetailScreen shows how-to-go and tips', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const SpotDetailScreen(id: 'sundarbans'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('How to get there'), findsOneWidget);
      expect(find.text('Best time to visit'), findsOneWidget);
      expect(find.text('Travel tips'), findsOneWidget);
      expect(find.text('Find Places to Stay'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SpotsScreen renders division filter and spot cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: OneUITheme.lightTheme, home: const SpotsScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tourist Spots'), findsOneWidget);
      expect(find.widgetWithText(CGChip, 'Chittagong'), findsOneWidget);
      await tester.tap(find.widgetWithText(CGChip, 'Chittagong'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text("Cox's Bazar"));
      expect(find.text("Cox's Bazar"), findsOneWidget);
      expect(find.text('Sundarbans'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Booking is hotels + transport only', () {
    testWidgets('Destination booking form shows exploration message', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const BookingFormScreen(type: 'destination', itemId: 1),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Tourist spots are for exploring, not booking.'),
        findsOneWidget,
      );
      expect(find.text('Browse Hotels'), findsOneWidget);
      expect(find.text('Confirm Booking'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Transport booking form offers a seat map', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transportServiceProvider.overrideWithValue(_TransportService()),
            bookingServiceProvider.overrideWithValue(_BookingService()),
          ],
          child: MaterialApp(
            theme: OneUITheme.lightTheme,
            home: const BookingFormScreen(type: 'transport', itemId: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Choose your seats'), findsOneWidget);
      expect(find.text('1A'), findsOneWidget);
      expect(find.textContaining('0 selected'), findsOneWidget);

      // Select two free seats — the counter must update.
      await tester.tap(find.text('1A'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('1 selected'), findsOneWidget);

      await tester.tap(find.text('1B'));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.textContaining('2 selected'), findsOneWidget);

      // Occupied seats (marked with a cross) must not be selectable.
      final occupied = find.byIcon(Icons.close_rounded);
      if (occupied.evaluate().isNotEmpty) {
        await tester.tap(occupied.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.textContaining('2 selected'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  });

  group('Invoice PDF', () {
    test('formatBdt writes BDT with grouped thousands', () {
      expect(InvoicePdf.formatBdt(15000), 'BDT 15,000.00');
      expect(InvoicePdf.formatBdt(0), 'BDT 0.00');
      expect(InvoicePdf.formatBdt(1234567.5), 'BDT 1,234,567.50');
      expect(InvoicePdf.formatBdt(999), 'BDT 999.00');
      expect(InvoicePdf.formatBdt(-2500), '-BDT 2,500.00');
    });

    test('invoice number is stable and readable', () {
      expect(InvoicePdf.invoiceNumber(_booking()), 'CG-INV-000042');
    });

    test('generated PDF has a valid header and payload', () async {
      final bytes = await InvoicePdf.build(_booking());
      final uint = Uint8List.fromList(bytes);

      expect(uint.length, greaterThan(500));
      expect(String.fromCharCodes(uint.sublist(0, 5)), '%PDF-');
    });
  });

  group('Admin dashboard', () {
    testWidgets('Dashboard tab renders statistical views', (tester) async {
      tester.view.physicalSize = const Size(390, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [adminServiceProvider.overrideWithValue(_AdminService())],
          child: MaterialApp(
            theme: OneUITheme.lightTheme,
            home: const AdminPanelScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Bookings by service'), findsOneWidget);
      expect(find.text('Bookings by status'), findsOneWidget);
      await tester.drag(find.byType(ListView).first, const Offset(0, -700));
      await tester.pumpAndSettle();
      expect(find.text('Revenue summary'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Profile screens', () {
    testWidgets('Edit profile and help screens render', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OneUITheme.lightTheme,
            home: const EditProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Save Changes'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const HelpSupportScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Frequently asked questions'), findsOneWidget);
      expect(find.text('Contact us'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
