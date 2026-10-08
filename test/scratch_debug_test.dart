import 'package:comfygo/core/theme/one_ui_theme.dart';
import 'package:comfygo/features/admin/screens/admin_panel_screen.dart';
import 'package:comfygo/models/models.dart';
import 'package:comfygo/services/admin_service.dart';
import 'package:comfygo/state/service_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _AdminPreviewService implements AdminService {
  @override
  Future<Map<String, dynamic>> getStats() async => {
    'users': 0,
    'bookings': 0,
    'revenue': 0,
    'active_packages': 0,
  };

  @override
  Future<List<User>> getUsers({
    String? search,
    String? role,
    int page = 1,
    int limit = 20,
  }) async => [];

  @override
  Future<List<Booking>> getAllBookings({
    String? status,
    String? type,
    int page = 1,
    int limit = 20,
  }) async => [];

  @override
  Future<List<Payment>> getAllPayments({
    String? status,
    String? method,
    int page = 1,
    int limit = 20,
  }) async => [];

  @override
  Future<List<Hotel>> getAllListings({
    String? type,
    bool? approved,
    int page = 1,
    int limit = 20,
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
  testWidgets('admin dashboard loads with service data and tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adminServiceProvider.overrideWithValue(_AdminPreviewService()),
        ],
        child: MaterialApp(
          theme: OneUITheme.lightTheme,
          home: const AdminPanelScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Users'), findsWidgets);
    expect(find.text('Bookings'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
