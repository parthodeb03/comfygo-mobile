import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/services.dart';
import '../models/models.dart';
import '../services/favorite_service.dart';
import '../services/review_service.dart';
import '../services/invoice_pdf.dart';
import 'auth_provider.dart';

/// Destination Service Provider
final destinationServiceProvider = Provider<DestinationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DestinationService(apiClient);
});

/// Hotel Service Provider
final hotelServiceProvider = Provider<HotelService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HotelService(apiClient);
});

/// Transport Service Provider
final transportServiceProvider = Provider<TransportService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TransportService(apiClient);
});

/// Guide Service Provider
final guideServiceProvider = Provider<GuideService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GuideService(apiClient);
});

/// Booking Service Provider
final bookingServiceProvider = Provider<BookingService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BookingService(apiClient);
});

/// Payment Service Provider
final paymentServiceProvider = Provider<PaymentService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentService(apiClient);
});

final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FavoriteService(apiClient);
});

final reviewServiceProvider = Provider<ReviewService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReviewService(apiClient);
});

final invoicePdfServiceProvider = Provider<void Function(InvoicePdf)>((ref) {
  // InvoicePdf is a stateless callable class — provide the format function.
  return (InvoicePdf pdf) {
    // no-op: the UI calls static helpers directly on InvoicePdf.
  };
});

/// Package Service Provider
final packageServiceProvider = Provider<PackageService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PackageService(apiClient);
});

/// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminService(apiClient);
});

// ═══════════════════════════════════════════════════
// STATE NOTIFIERS FOR LIST DATA
// ═══════════════════════════════════════════════════

/// Destinations State
class DestinationsState {
  final List<Destination> destinations;
  final bool isLoading;
  final String? error;

  DestinationsState({
    this.destinations = const [],
    this.isLoading = false,
    this.error,
  });

  DestinationsState copyWith({
    List<Destination>? destinations,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DestinationsState(
      destinations: destinations ?? this.destinations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DestinationsNotifier extends StateNotifier<DestinationsState> {
  final DestinationService _service;

  DestinationsNotifier(this._service) : super(DestinationsState()) {
    loadDestinations();
  }

  Future<void> loadDestinations({String? search, String? division}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final destinations = await _service.getDestinations(
        search: search,
        division: division,
      );
      state = state.copyWith(destinations: destinations, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final destinationsProvider =
    StateNotifierProvider<DestinationsNotifier, DestinationsState>((ref) {
      return DestinationsNotifier(ref.watch(destinationServiceProvider));
    });

/// Hotels State
class HotelsState {
  final List<Hotel> hotels;
  final bool isLoading;
  final String? error;

  HotelsState({this.hotels = const [], this.isLoading = false, this.error});

  HotelsState copyWith({
    List<Hotel>? hotels,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return HotelsState(
      hotels: hotels ?? this.hotels,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class HotelsNotifier extends StateNotifier<HotelsState> {
  final HotelService _service;

  HotelsNotifier(this._service) : super(HotelsState()) {
    loadHotels();
  }

  Future<void> loadHotels({String? search, String? division}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final hotels = await _service.getHotels(
        search: search,
        division: division,
      );
      state = state.copyWith(hotels: hotels, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final hotelsProvider = StateNotifierProvider<HotelsNotifier, HotelsState>((
  ref,
) {
  return HotelsNotifier(ref.watch(hotelServiceProvider));
});

/// Transports State
class TransportsState {
  final List<Transport> transports;
  final bool isLoading;
  final String? error;

  TransportsState({
    this.transports = const [],
    this.isLoading = false,
    this.error,
  });

  TransportsState copyWith({
    List<Transport>? transports,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TransportsState(
      transports: transports ?? this.transports,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TransportsNotifier extends StateNotifier<TransportsState> {
  final TransportService _service;

  TransportsNotifier(this._service) : super(TransportsState()) {
    loadTransports();
  }

  Future<void> loadTransports({String? search, String? type}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final transports = await _service.getTransports(
        search: search,
        type: type,
      );
      state = state.copyWith(transports: transports, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final transportsProvider =
    StateNotifierProvider<TransportsNotifier, TransportsState>((ref) {
      return TransportsNotifier(ref.watch(transportServiceProvider));
    });

/// Guides State
class GuidesState {
  final List<Guide> guides;
  final bool isLoading;
  final String? error;

  GuidesState({this.guides = const [], this.isLoading = false, this.error});

  GuidesState copyWith({
    List<Guide>? guides,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GuidesState(
      guides: guides ?? this.guides,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class GuidesNotifier extends StateNotifier<GuidesState> {
  final GuideService _service;

  GuidesNotifier(this._service) : super(GuidesState()) {
    loadGuides();
  }

  Future<void> loadGuides({String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final guides = await _service.getGuides(search: search);
      state = state.copyWith(guides: guides, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final guidesProvider = StateNotifierProvider<GuidesNotifier, GuidesState>((
  ref,
) {
  return GuidesNotifier(ref.watch(guideServiceProvider));
});

/// Bookings State
class BookingsState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;

  BookingsState({this.bookings = const [], this.isLoading = false, this.error});

  BookingsState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return BookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class BookingsNotifier extends StateNotifier<BookingsState> {
  final BookingService _service;

  BookingsNotifier(this._service) : super(BookingsState()) {
    loadBookings();
  }

  Future<void> loadBookings({String? status}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final bookings = await _service.getMyBookings();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final bookingsProvider = StateNotifierProvider<BookingsNotifier, BookingsState>(
  (ref) {
    return BookingsNotifier(ref.watch(bookingServiceProvider));
  },
);

/// Packages State
class PackagesState {
  final List<Package> packages;
  final bool isLoading;
  final String? error;

  PackagesState({this.packages = const [], this.isLoading = false, this.error});

  PackagesState copyWith({
    List<Package>? packages,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PackagesState(
      packages: packages ?? this.packages,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class PackagesNotifier extends StateNotifier<PackagesState> {
  final PackageService _service;

  PackagesNotifier(this._service) : super(PackagesState()) {
    loadPackages();
  }

  Future<void> loadPackages() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final packages = await _service.getPackages();
      state = state.copyWith(packages: packages, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final packagesProvider = StateNotifierProvider<PackagesNotifier, PackagesState>(
  (ref) {
    return PackagesNotifier(ref.watch(packageServiceProvider));
  },
);
