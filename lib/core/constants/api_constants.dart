/// API Configuration Constants
class ApiConstants {
  ApiConstants._();

  // Base URL - change this to your backend URL
  //
  // Physical Android device: run `adb reverse tcp:8000 tcp:8000` on your PC,
  //   then use http://localhost:8000 here.
  //   Alternatively, use your PC's local IP (e.g. http://192.168.1.x:8000).
  //
  // iOS / Android emulator: use http://localhost:8000
  static const String baseUrl = 'http://localhost:8000';

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
