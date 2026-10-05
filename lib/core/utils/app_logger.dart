import 'dart:developer' as developer;

/// Lightweight app logger.
///
/// Uses [developer.log] so output shows up in Dart DevTools / flutter run
/// console instead of leaking raw prints in production code.
class AppLogger {
  AppLogger._();

  static void info(String message) => developer.log(message, name: 'INFO');

  static void warning(String message) => developer.log(message, name: 'WARN');

  static void error(String message, [Object? error, StackTrace? stackTrace]) =>
      developer.log(
        message,
        name: 'ERROR',
        error: error,
        stackTrace: stackTrace,
      );
}
