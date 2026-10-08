/// API Configuration Constants
class ApiConstants {
  ApiConstants._();

  // Base URL — override at build/run time when needed:
  //   flutter run --dart-define=API_BASE_URL=http://localhost:8000
  //
  // Android emulator host alias; use a LAN address for a physical phone.
  //
  // With a USB-connected phone you can instead keep localhost and run:
  //   adb reverse tcp:8000 tcp:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  // API Prefix
  static const String apiPrefix = '/api/v1';

  // Auth Endpoints
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';
  static const String resetPassword = '$apiPrefix/auth/reset-password';
  static const String refreshToken = '$apiPrefix/auth/refresh';
  static const String profile = '$apiPrefix/auth/profile';

  // Destinations
  static const String destinations = '$apiPrefix/destinations';

  // Hotels
  static const String hotels = '$apiPrefix/hotels';

  // Transports
  static const String transports = '$apiPrefix/transports';

  // Guides
  static const String guides = '$apiPrefix/guides';

  // Bookings
  static const String bookings = '$apiPrefix/bookings';

  // Payments
  static const String payments = '$apiPrefix/payments';

  // Packages
  static const String packages = '$apiPrefix/packages';
  static const String userPackages = '$apiPrefix/user-packages';

  // Admin
  static const String adminUsers = '$apiPrefix/admin/users';
  static const String adminBookings = '$apiPrefix/admin/bookings';
  static const String adminPayments = '$apiPrefix/admin/payments';
  static const String adminListings = '$apiPrefix/admin/listings';
  static const String adminPackages = '$apiPrefix/admin/packages';
  static const String adminStats = '$apiPrefix/admin/stats';
}
